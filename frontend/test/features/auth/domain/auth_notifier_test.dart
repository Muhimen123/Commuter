import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:frontend/features/auth/domain/auth_notifier.dart';
import 'package:frontend/features/auth/domain/auth_user.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  AuthUser? currentUser;
  Object? errorToThrow;
  final StreamController<AuthUser?> _authChangesController =
      StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> get authStateChanges => _authChangesController.stream;

  @override
  Future<AuthUser?> restoreSession() async {
    if (errorToThrow != null) throw errorToThrow!;
    return currentUser;
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    final user = AuthUser(
      id: 'test-user-123',
      fullName: 'Jane Doe',
      email: email,
      phoneNumber: '+880 1401234567',
      createdAt: DateTime.utc(2025, 1, 1),
      updatedAt: DateTime.utc(2025, 1, 1),
    );
    currentUser = user;
    _authChangesController.add(user);
    return user;
  }

  @override
  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    final user = AuthUser(
      id: 'test-new-user-456',
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      createdAt: DateTime.utc(2025, 1, 1),
      updatedAt: DateTime.utc(2025, 1, 1),
    );
    currentUser = user;
    _authChangesController.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    if (errorToThrow != null) throw errorToThrow!;
    currentUser = null;
    _authChangesController.add(null);
  }

  @override
  Future<void> sendPasswordResetOtp({required String email}) async {
    if (errorToThrow != null) throw errorToThrow!;
    if (email == 'nonexistent@example.com') {
      throw Exception('No account found with this email address.');
    }
  }

  @override
  Future<void> verifyPasswordResetOtp({
    required String email,
    required String token,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    if (token != '123456') {
      throw Exception('Invalid verification code');
    }
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<AuthUser> updateProfile({
    required String fullName,
    String? phoneNumber,
    String? password,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    final base = currentUser ??
        AuthUser(
          id: 'test-user-123',
          fullName: 'Original Name',
          email: 'test@example.com',
          phoneNumber: '+880 1401234567',
          createdAt: DateTime.utc(2025, 1, 1),
          updatedAt: DateTime.utc(2025, 1, 1),
        );
    final updated = base.copyWith(
      fullName: fullName,
      phoneNumber: phoneNumber ?? base.phoneNumber,
    );
    currentUser = updated;
    _authChangesController.add(updated);
    return updated;
  }

  void dispose() {
    _authChangesController.close();
  }
}

void main() {
  group('AuthNotifier', () {
    late ProviderContainer container;
    late FakeAuthRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
    });

    tearDown(() {
      fakeRepo.dispose();
      container.dispose();
    });

    test('initial state restores null when signed out', () async {
      final state = await container.read(authProvider.future);
      expect(state, isNull);
    });

    test('initial state restores user when session exists', () async {
      final existingUser = AuthUser(
        id: 'existing-id',
        fullName: 'Existing User',
        email: 'user@example.com',
        phoneNumber: '+1234567890',
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
      );
      fakeRepo.currentUser = existingUser;

      final restoredContainer = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );

      final state = await restoredContainer.read(authProvider.future);
      expect(state, equals(existingUser));
      restoredContainer.dispose();
    });

    test('signUp transitions to loading then stores real AuthUser', () async {
      final future = container.read(authProvider.notifier).signUp(
            fullName: 'Jane Doe',
            email: 'jane@example.com',
            phoneNumber: '+880 1401234567',
            password: 'password123',
          );

      expect(container.read(authProvider).isLoading, isTrue);

      await future;

      final state = container.read(authProvider);
      expect(state.hasValue, isTrue);

      final user = state.value!;
      expect(user.id, equals('test-new-user-456'));
      expect(user.fullName, equals('Jane Doe'));
      expect(user.email, equals('jane@example.com'));
      expect(user.phoneNumber, equals('+880 1401234567'));
    });

    test('signIn transitions to loading then stores AuthUser', () async {
      final future = container.read(authProvider.notifier).signIn(
            email: 'jane@example.com',
            password: 'password123',
          );

      expect(container.read(authProvider).isLoading, isTrue);

      await future;

      final state = container.read(authProvider);
      expect(state.hasValue, isTrue);

      final user = state.value!;
      expect(user.id, equals('test-user-123'));
      expect(user.email, equals('jane@example.com'));
    });

    test('signOut clears the user back to null', () async {
      await container.read(authProvider.notifier).signIn(
            email: 'jane@example.com',
            password: 'password123',
          );
      expect(container.read(authProvider).value, isNotNull);

      await container.read(authProvider.notifier).signOut();

      final state = container.read(authProvider);
      expect(state.hasValue, isTrue);
      expect(state.value, isNull);
    });

    test('captures error on failure', () async {
      fakeRepo.errorToThrow = Exception('Invalid credentials');

      await container.read(authProvider.notifier).signIn(
            email: 'wrong@example.com',
            password: 'badpassword',
          );

      final state = container.read(authProvider);
      expect(state.hasError, isTrue);
      expect(state.error.toString(), contains('Invalid credentials'));
    });

    test('sendPasswordResetOtp calls repository and throws for unknown email', () async {
      expect(
        () => container
            .read(authProvider.notifier)
            .sendPasswordResetOtp('test@example.com'),
        returnsNormally,
      );

      expect(
        () => container
            .read(authProvider.notifier)
            .sendPasswordResetOtp('nonexistent@example.com'),
        throwsA(isA<Exception>()),
      );
    });

    test('verifyPasswordResetOtp validates token and throws on invalid token', () async {
      expect(
        () => container.read(authProvider.notifier).verifyPasswordResetOtp(
              email: 'test@example.com',
              token: '123456',
            ),
        returnsNormally,
      );

      expect(
        () => container.read(authProvider.notifier).verifyPasswordResetOtp(
              email: 'test@example.com',
              token: '000000',
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('updatePassword calls repository', () async {
      expect(
        () => container
            .read(authProvider.notifier)
            .updatePassword('newPassword123'),
        returnsNormally,
      );
    });

    test('updateProfile updates user state and repository', () async {
      await container.read(authProvider.notifier).signIn(
            email: 'test@example.com',
            password: 'password123',
          );

      await container.read(authProvider.notifier).updateProfile(
            fullName: 'Sameen Abrar',
            phoneNumber: '+880 1711122233',
          );

      final state = container.read(authProvider);
      expect(state.hasValue, isTrue);
      final user = state.value!;
      expect(user.fullName, equals('Sameen Abrar'));
      expect(user.phoneNumber, equals('+880 1711122233'));
    });
  });
}