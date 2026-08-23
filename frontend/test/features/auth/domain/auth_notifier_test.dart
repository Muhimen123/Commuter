import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/domain/auth_notifier.dart';

void main() {
  group('AuthNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is signed out (null)', () {
      final state = container.read(authProvider);
      expect(state.hasValue, isTrue);
      expect(state.value, isNull);
    });

    test('signUp transitions to loading then stores a dummy AuthUser', () async {
      final future =
          container.read(authProvider.notifier).signUp(
                fullName: 'Jane Doe',
                email: 'jane@example.com',
                phoneNumber: '+880 1401234567',
              );

      // Immediately after calling signUp, state should be loading.
      expect(container.read(authProvider).isLoading, isTrue);

      await future;

      // After completion, state should hold the signed-up user.
      final state = container.read(authProvider);
      expect(state.hasValue, isTrue);

      final user = state.value!;
      expect(user.id, equals('00000000-0000-0000-0000-000000000001'));
      expect(user.fullName, equals('Jane Doe'));
      expect(user.email, equals('jane@example.com'));
      expect(user.phoneNumber, equals('+880 1401234567'));
      expect(user.profilePhotoUrl, isNull);
      expect(user.locationPermissionGranted, isFalse);
      expect(user.contactsPermissionGranted, isFalse);
      expect(user.createdAt, isNotNull);
      expect(user.updatedAt, isNotNull);
    });

    test('signOut clears the user back to null', () {
      final notifier = container.read(authProvider.notifier);
      notifier.signOut();

      final state = container.read(authProvider);
      expect(state.hasValue, isTrue);
      expect(state.value, isNull);
    });
  });
}