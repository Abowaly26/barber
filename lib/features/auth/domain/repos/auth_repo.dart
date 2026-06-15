import 'package:dartz/dartz.dart';
import '../../../../core/entities/user_entity.dart';
import '../../../../core/errors/failures.dart';

/// Repository interface for authentication operations
/// Defines all authentication-related methods that must be implemented
abstract class AuthRepo {
  /// Sign in with email and password
  ///
  /// Returns:
  /// - Right(UserEntity) on success
  /// - Left(Failure) on error
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with phone number (sends OTP)
  ///
  /// Returns:
  /// - Right(verificationId) on success
  /// - Left(Failure) on error
  Future<Either<Failure, String>> signInWithPhone({
    required String phoneNumber,
  });

  /// Verify OTP code received on phone
  ///
  /// Returns:
  /// - Right(UserEntity) on success
  /// - Left(Failure) on error
  Future<Either<Failure, UserEntity>> verifyOTP({
    required String verificationId,
    required String smsCode,
  });

  /// Sign in with Google account
  ///
  /// Returns:
  /// - Right(UserEntity) on success
  /// - Left(Failure) on error
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Create new user account with email and password
  ///
  /// Returns:
  /// - Right(UserEntity) on success
  /// - Left(Failure) on error
  Future<Either<Failure, UserEntity>> createUserWithEmail({
    required String email,
    required String password,
    required String name,
  });

  /// Sign out the current user
  ///
  /// Returns:
  /// - Right(void) on success
  /// - Left(Failure) on error
  Future<Either<Failure, void>> signOut();

  /// Get currently logged in user
  ///
  /// Returns:
  /// - UserEntity if user is logged in
  /// - null if no user is logged in
  UserEntity? getCurrentUser();

  /// Save user data to Firestore
  ///
  /// Used after authentication to store user profile
  Future<Either<Failure, void>> saveUserData({required UserEntity user});

  /// Get user data from Firestore by user ID
  ///
  /// Returns:
  /// - Right(UserEntity) on success
  /// - Left(Failure) on error
  Future<Either<Failure, UserEntity>> getUserData({required String userId});

  /// Update user profile data
  ///
  /// Returns:
  /// - Right(void) on success
  /// - Left(Failure) on error
  Future<Either<Failure, void>> updateUserProfile({required UserEntity user});

  /// Check if email is already registered
  ///
  /// Returns:
  /// - Right(true) if email exists
  /// - Right(false) if email doesn't exist
  /// - Left(Failure) on error
  Future<Either<Failure, bool>> checkEmailExists(String email);

  /// Send password reset email
  ///
  /// Returns:
  /// - Right(void) on success
  /// - Left(Failure) on error
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
}
