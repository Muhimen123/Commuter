import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/features/auth/domain/auth_user.dart';

/// Riverpod provider for authentication state.
///
/// Holds `null` when signed out, an [AuthUser] when signed in.
/// Loading / error states are provided by [AsyncValue] for free.
final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthUser?>(
  AuthNotifier.new,
);

/// Key used to store the serialised [AuthUser] in secure storage.
const _kUserKey = 'auth_user';

final _uuidRegExp = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

class AuthNotifier extends AsyncNotifier<AuthUser?> {
  @override
  FutureOr<AuthUser?> build() {
    // Restore session from secure storage.
    // flutter_secure_storage requires a WidgetsBinding / platform channel, so
    // we read it lazily rather than blocking the initial frame.
    _restoreSession();
    return null; // returned immediately; _restoreSession will update state.
  }

  /// Tries to load a previously persisted user session.
  ///
  /// If one exists it is emitted as the current auth state so the user
  /// stays signed in across app restarts.
  Future<void> _restoreSession() async {
    try {
      const storage = FlutterSecureStorage();
      final stored = await storage.read(key: _kUserKey);

      if (stored != null && stored.isNotEmpty) {
        final user = AuthUser.fromJson(jsonDecode(stored) as Map<String, dynamic>);
        if (!_uuidRegExp.hasMatch(user.id)) {
          debugPrint('Discarding persisted session: invalid user id "${user.id}"');
          await storage.delete(key: _kUserKey);
          state = const AsyncData(null);
          return;
        }
        state = AsyncData(user);
      }
    } catch (_) {
      state = const AsyncData(null);
    }
  }

  /// Persists the current [AuthUser] to secure storage.
  Future<void> _persist(AuthUser user) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: _kUserKey, value: jsonEncode(user.toJson()));
  }

  /// Simulates a sign-up call.
  ///
  /// After a brief artificial delay the notifier emits an [AuthUser] with
  /// a dummy id and the supplied profile fields. The user is persisted so the
  /// session survives app restarts.
  Future<void> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    state = const AsyncLoading();

    // Simulate network round-trip
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();

    final user = AuthUser(
      id: '00000000-0000-0000-0000-000000000001',
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      locationPermissionGranted: false,
      contactsPermissionGranted: false,
      createdAt: now,
      updatedAt: now,
    );

    await _persist(user);
    state = AsyncData(user);
  }

  /// Clears the current session (signs the user out).
  Future<void> signOut() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: _kUserKey);
    state = const AsyncData(null);
  }
}