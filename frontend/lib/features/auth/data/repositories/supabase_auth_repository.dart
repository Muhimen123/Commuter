import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../domain/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository();
});

const String _kUserKey = 'auth_user';
const String _kSessionTokenKey = 'auth_session_token';
const String _kDummyUserId = '00000000-0000-0000-0000-000000000001';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;
  final FlutterSecureStorage _storage;

  SupabaseAuthRepository({
    SupabaseClient? client,
    FlutterSecureStorage? storage,
  })  : _client = client ?? Supabase.instance.client,
        _storage = storage ?? const FlutterSecureStorage();

  @override
  Stream<AuthUser?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((data) async {
      final session = data.session;
      if (session == null) {
        await _clearLocalStorage();
        return null;
      }
      return _fetchUserFromDb(session.user.id);
    });
  }

  @override
  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone_number': phoneNumber,
      },
    );

    final authUser = response.user;
    if (authUser == null) {
      throw const AuthException('Sign up failed: No user returned');
    }

    final now = DateTime.now().toUtc();
    final user = AuthUser(
      id: authUser.id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      locationPermissionGranted: false,
      contactsPermissionGranted: false,
      createdAt: now,
      updatedAt: now,
    );

    // Ensure user record exists in public.users and user_settings before login
    await _ensureUserInDb(user);

    // Ensure user must log in through the login page by signing out any auto-session
    try {
      await _client.auth.signOut();
    } catch (_) {}
    await _clearLocalStorage();

    return user;
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final authUser = response.user;
    if (authUser == null) {
      throw const AuthException('Login failed: Invalid credentials');
    }

    // Fetch user profile from public.users table or fallback to metadata
    AuthUser? user = await _fetchUserFromDb(authUser.id);
    if (user == null) {
      user = AuthUser(
        id: authUser.id,
        fullName: (authUser.userMetadata?['full_name'] ??
            email.split('@').first) as String,
        email: email,
        phoneNumber:
            (authUser.userMetadata?['phone_number'] ?? '') as String,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      // Ensure the row exists in public.users before inserting into auth_sessions
      await _ensureUserInDb(user);
    }

    // Enforce single-device login: revoke older sessions and register current device session
    final sessionToken = response.session?.refreshToken ??
        'session_${authUser.id}_${DateTime.now().millisecondsSinceEpoch}';
    await _recordDeviceSession(user.id, sessionToken);
    await _persist(user, sessionToken);

    return user;
  }

  @override
  Future<void> signOut() async {
    final sessionToken = await _storage.read(key: _kSessionTokenKey);
    final userId = _client.auth.currentUser?.id;

    // Revoke the session in auth_sessions table
    if (sessionToken != null || userId != null) {
      try {
        final nowIso = DateTime.now().toUtc().toIso8601String();
        if (sessionToken != null) {
          await _client
              .from('auth_sessions')
              .update({'revoked_at': nowIso})
              .eq('refresh_token', sessionToken);
        } else if (userId != null) {
          await _client
              .from('auth_sessions')
              .update({'revoked_at': nowIso})
              .eq('user_id', userId)
              .isFilter('revoked_at', null);
        }
      } catch (e) {
        debugPrint('Error revoking device session in auth_sessions: $e');
      }
    }

    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Error during supabase signOut: $e');
    }

    await _clearLocalStorage();
  }

  @override
  Future<AuthUser?> restoreSession() async {
    try {
      // First clean up any leftover dummy user artifact from secure storage
      final storedUser = await _storage.read(key: _kUserKey);
      if (storedUser != null && storedUser.contains(_kDummyUserId)) {
        await _clearLocalStorage();
        return null;
      }

      final currentSession = _client.auth.currentSession;
      final storedToken = await _storage.read(key: _kSessionTokenKey);

      // If no valid active session in Supabase Auth, clear local storage and do NOT auto login
      if (currentSession == null) {
        await _clearLocalStorage();
        return null;
      }

      if (storedToken != null) {
        // Verify in DB whether this device session was revoked by another login
        try {
          final sessionRows = await _client
              .from('auth_sessions')
              .select()
              .eq('refresh_token', storedToken);

          if (sessionRows.isNotEmpty &&
              sessionRows.first['revoked_at'] != null) {
            // Revoked remotely! Log out locally.
            await signOut();
            return null;
          }
        } catch (e) {
          debugPrint('Error verifying session revocation status: $e');
        }

        final user = await _fetchUserFromDb(currentSession.user.id);
        if (user != null) {
          await _persist(user, storedToken);
          return user;
        }
      }

      final authUser = currentSession.user;
      final fallbackUser = AuthUser(
        id: authUser.id,
        fullName: (authUser.userMetadata?['full_name'] ??
            authUser.email?.split('@').first ??
            '') as String,
        email: authUser.email ?? '',
        phoneNumber:
            (authUser.userMetadata?['phone_number'] ?? '') as String,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _ensureUserInDb(fallbackUser);
      return fallbackUser;
    } catch (e) {
      debugPrint('Error restoring auth session: $e');
      await _clearLocalStorage();
    }
    return null;
  }

  Future<void> _ensureUserInDb(AuthUser user) async {
    try {
      await _client
          .from('users')
          .upsert(user.toDbMap(passwordHash: 'supabase_auth'));
      await _client.from('user_settings').upsert({
        'user_id': user.id,
      });
    } catch (e) {
      debugPrint('Error inserting user to users/user_settings table: $e');
    }
  }

  Future<void> _clearLocalStorage() async {
    try {
      await _storage.delete(key: _kUserKey);
      await _storage.delete(key: _kSessionTokenKey);
    } catch (_) {}
  }

  Future<AuthUser?> _fetchUserFromDb(String userId) async {
    try {
      final rows = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .limit(1);
      if (rows.isNotEmpty) {
        return AuthUser.fromJson(rows.first);
      }
    } catch (e) {
      debugPrint('Error fetching user row: $e');
    }
    return null;
  }

  Future<void> _recordDeviceSession(
      String userId, String sessionToken) async {
    try {
      final now = DateTime.now().toUtc();
      // Revoke any previous active session for this user to ensure single active device
      await _client
          .from('auth_sessions')
          .update({'revoked_at': now.toIso8601String()})
          .eq('user_id', userId)
          .isFilter('revoked_at', null);

      // Insert new session record
      final expiresAt = now.add(const Duration(days: 30));
      await _client.from('auth_sessions').insert({
        'user_id': userId,
        'refresh_token': sessionToken,
        'device_info': 'Flutter Mobile App',
        'issued_at': now.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'revoked_at': null,
      });
    } catch (e) {
      debugPrint('Error recording session in auth_sessions table: $e');
    }
  }

  Future<void> _persist(AuthUser user, String sessionToken) async {
    try {
      await _storage.write(key: _kUserKey, value: jsonEncode(user.toJson()));
      await _storage.write(key: _kSessionTokenKey, value: sessionToken);
    } catch (e) {
      debugPrint('Error persisting auth user securely: $e');
    }
  }
}
