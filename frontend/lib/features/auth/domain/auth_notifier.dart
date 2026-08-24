import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_user.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthUser?>(AuthNotifier.new);

const _kUserKey = 'auth_user';

class AuthNotifier extends AsyncNotifier<AuthUser?> {
  @override
  FutureOr<AuthUser?> build() {
    _restoreSession();
    return null;
  }

  Future<void> _restoreSession() async {
    try {
      const storage = FlutterSecureStorage();
      final stored = await storage.read(key: _kUserKey);
      if (stored != null && stored.isNotEmpty) {
        final user = AuthUser.fromJson(jsonDecode(stored) as Map<String, dynamic>);
        state = AsyncData(user);
      }
    } catch (_) {
      state = const AsyncData(null);
    }
  }

  Future<void> _persist(AuthUser user) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: _kUserKey, value: jsonEncode(user.toJson()));
  }

  /// MOCK SIGN IN: Use this for real-time testing.
  /// dev@commuter.app -> User 1 (Sharer)
  /// guardian@commuter.app -> User 2 (Guardian)
  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    await Future.delayed(const Duration(milliseconds: 500));

    AuthUser user;
    if (email == 'dev@commuter.app') {
      user = AuthUser(
        id: '00000000-0000-0000-0000-000000000001',
        fullName: 'Commuter Dev User',
        email: email,
        phoneNumber: '+880 1711111111',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else if (email == 'guardian@commuter.app') {
      user = AuthUser(
        id: '00000000-0000-0000-0000-000000000002',
        fullName: 'Guardian Simulation',
        email: email,
        phoneNumber: '+880 1999999999',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else {
      state = AsyncError('User not found in mock system', StackTrace.current);
      return;
    }

    await _persist(user);
    state = AsyncData(user);
  }

  Future<void> signUp({required String fullName, required String email, required String phoneNumber}) async {
    state = const AsyncLoading();
    final user = AuthUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // random id
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _persist(user);
    state = AsyncData(user);
  }

  Future<void> signOut() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: _kUserKey);
    state = const AsyncData(null);
  }
}
