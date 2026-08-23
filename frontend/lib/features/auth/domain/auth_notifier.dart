import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/domain/auth_user.dart';

/// Riverpod provider for authentication state.
///
/// Holds `null` when signed out, an [AuthUser] when signed in.
/// Loading / error states are provided by [AsyncValue] for free.
final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthUser?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthUser?> {
  @override
  AuthUser? build() => null;

  /// Simulates a sign-up call.
  ///
  /// After a brief artificial delay the notifier emits an [AuthUser] with
  /// a dummy id and the supplied profile fields.  When a real backend is
  /// wired in, swap this method body for an API call that returns the
  /// server-issued user.
  Future<void> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    state = const AsyncLoading();

    // Simulate network round-trip
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();

    state = AsyncData(
      AuthUser(
        id: '00000000-0000-0000-0000-000000000001',
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        locationPermissionGranted: false,
        contactsPermissionGranted: false,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Clears the current session (signs the user out).
  void signOut() {
    state = const AsyncData(null);
  }
}