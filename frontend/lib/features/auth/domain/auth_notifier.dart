import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:frontend/features/auth/domain/auth_user.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

/// Riverpod provider for authentication state.
///
/// Holds `null` when signed out, an [AuthUser] when signed in.
/// Loading / error states are provided by [AsyncValue].
final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthUser?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<AuthUser?> {
  late final AuthRepository _repository;

  @override
  FutureOr<AuthUser?> build() async {
    _repository = ref.read(authRepositoryProvider);
    // Listen to repository auth state changes if supported
    final sub = _repository.authStateChanges.listen((user) {
      state = AsyncData(user);
    });
    ref.onDispose(sub.cancel);

    return _repository.restoreSession();
  }

  /// Signs in an existing user using email and password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _repository.signIn(
        email: email,
        password: password,
      );
      return user;
    });
  }

  /// Signs up a new user and persists their session.
  Future<void> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _repository.signUp(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      return user;
    });
  }

  /// Clears the current session (signs the user out and revokes active device session).
  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.signOut();
      return null;
    });
  }

  /// Refreshes or restores the active session manually.
  Future<void> restoreSession() async {
    final user = await _repository.restoreSession();
    state = AsyncData(user);
  }
}