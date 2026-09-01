import '../auth_user.dart';

abstract class AuthRepository {
  /// Signs up a new user with credentials and profile details.
  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  });

  /// Signs in an existing user with email and password.
  ///
  /// Enforces single-device login by revoking prior active sessions in the database.
  Future<AuthUser> signIn({
    required String email,
    required String password,
  });

  /// Signs the current user out, revoking their active device session.
  Future<void> signOut();

  /// Restores a previously saved session if it exists and has not been revoked.
  Future<AuthUser?> restoreSession();

  /// Sends a password reset OTP to the provided [email].
  Future<void> sendPasswordResetOtp({required String email});

  /// Verifies the OTP code for password reset.
  Future<void> verifyPasswordResetOtp({
    required String email,
    required String token,
  });

  /// Updates the user's password with [newPassword].
  Future<void> updatePassword({required String newPassword});

  /// Updates user profile details in the database and active session.
  Future<AuthUser> updateProfile({
    required String fullName,
    String? phoneNumber,
    String? password,
  });

  /// Stream of authentication state changes.
  Stream<AuthUser?> get authStateChanges;
}
