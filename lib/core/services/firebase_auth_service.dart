import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../errors/failures.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left(
          FirebaseFailure('Sign in failed - user not found'),
        );
      }

      log(
        '✅ Firebase Auth: Successfully signed in user: ${credential.user!.email}',
      );
      return Right(credential.user!);
    } on FirebaseAuthException catch (e, stackTrace) {
      log(
        '❌ FirebaseAuthException in signInWithEmail: ${e.code} - ${e.message}',
      );
      return Left(_handleFirebaseAuthException(e, stackTrace));
    } catch (e, stackTrace) {
      log('❌ Unexpected error in signInWithEmail: ${e.toString()}');
      return Left(
        UnknownFailure('An unexpected error occurred during sign in', stackTrace),
      );
    }
  }

  Future<Either<Failure, User>> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left(
          FirebaseFailure('Account creation failed - user not created'),
        );
      }

      log(
        '✅ Firebase Auth: Created new account for user: ${credential.user!.email}',
      );
      return Right(credential.user!);
    } on FirebaseAuthException catch (e, stackTrace) {
      log(
        '❌ FirebaseAuthException in createUserWithEmailAndPassword: ${e.code} - ${e.message}',
      );
      return Left(_handleFirebaseAuthException(e, stackTrace));
    } catch (e, stackTrace) {
      log(
        '❌ Unexpected error in createUserWithEmailAndPassword: ${e.toString()}',
      );
      return Left(
        UnknownFailure('An unexpected error occurred during account creation', stackTrace),
      );
    }
  }

  Future<Either<Failure, String>> signInWithPhone({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException) onVerificationFailed,
  }) async {
    try {
      String? verificationIdResult;
      Failure? errorResult;

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          log('📱 Firebase Auth: Automatic phone verification completed');
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          log(
            '❌ Firebase Auth: Phone verification failed - ${e.code}: ${e.message}',
          );
          errorResult = _handleFirebaseAuthException(e);
          onVerificationFailed(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          log('✅ Firebase Auth: Verification code sent to $phoneNumber');
          verificationIdResult = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          log('⏱️ Firebase Auth: Auto-retrieval timeout expired');
          verificationIdResult = verificationId;
        },
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (errorResult != null) {
        return Left(errorResult!);
      }

      if (verificationIdResult != null) {
        return Right(verificationIdResult!);
      }

      return const Left(
        FirebaseFailure('Failed to send verification code - verification ID not obtained'),
      );
    } catch (e, stackTrace) {
      log('❌ Unexpected error in signInWithPhone: ${e.toString()}');
      return Left(
        UnknownFailure('An unexpected error occurred while sending verification code', stackTrace),
      );
    }
  }

  Future<Either<Failure, User>> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        return const Left(
          FirebaseFailure('Code verification failed - user not found'),
        );
      }

      log(
        '✅ Firebase Auth: OTP code verified successfully for user: ${userCredential.user!.phoneNumber}',
      );
      return Right(userCredential.user!);
    } on FirebaseAuthException catch (e, stackTrace) {
      log('❌ FirebaseAuthException in verifyOTP: ${e.code} - ${e.message}');
      return Left(_handleFirebaseAuthException(e, stackTrace));
    } catch (e, stackTrace) {
      log('❌ Unexpected error in verifyOTP: ${e.toString()}');
      return Left(
        UnknownFailure('An unexpected error occurred during code verification', stackTrace),
      );
    }
  }

  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return const Left(FirebaseFailure('Google sign in was cancelled'));
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        return const Left(
          FirebaseFailure('Google sign in failed - user not found'),
        );
      }

      log(
        '✅ Firebase Auth: Signed in with Google: ${userCredential.user!.email}',
      );
      return Right(userCredential.user!);
    } on FirebaseAuthException catch (e, stackTrace) {
      log(
        '❌ FirebaseAuthException in signInWithGoogle: ${e.code} - ${e.message}',
      );
      return Left(_handleFirebaseAuthException(e, stackTrace));
    } on PlatformException catch (e, stackTrace) {
      log('❌ PlatformException in signInWithGoogle: ${e.code} - ${e.message}');
      if (e.code == 'sign_in_failed') {
        return Left(
          FirebaseFailure(
            'Google sign in failed. Make sure SHA-1 is configured in Firebase Console.',
            stackTrace,
          ),
        );
      }
      return Left(
        FirebaseFailure(e.message ?? 'Google sign in failed', stackTrace),
      );
    } catch (e, stackTrace) {
      log('❌ Unexpected error in signInWithGoogle: ${e.toString()}');
      return Left(
        UnknownFailure(
          'An unexpected error occurred during Google sign in',
          stackTrace,
        ),
      );
    }
  }

  Future<Either<Failure, void>> signOut() async {
    try {
      await _auth.signOut();

      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      log('✅ Firebase Auth: Successfully signed out');
      return const Right(null);
    } catch (e, stackTrace) {
      log('❌ Unexpected error in signOut: ${e.toString()}');
      return Left(
        UnknownFailure('An unexpected error occurred during sign out', stackTrace),
      );
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      log('✅ Firebase Auth: Password reset email sent to $email');
      return const Right(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      log(
        '❌ FirebaseAuthException in sendPasswordResetEmail: ${e.code} - ${e.message}',
      );
      return Left(_handleFirebaseAuthException(e, stackTrace));
    } catch (e, stackTrace) {
      log('❌ Unexpected error in sendPasswordResetEmail: ${e.toString()}');
      return Left(
        UnknownFailure(
          'An unexpected error occurred while sending password reset email',
          stackTrace,
        ),
      );
    }
  }

  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(UnauthorizedFailure('No user signed in'));
      }

      if (user.emailVerified) {
        return const Left(ValidationFailure('Email is already verified'));
      }

      await user.sendEmailVerification();
      log('✅ Firebase Auth: Verification email sent to ${user.email}');
      return const Right(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      log(
        '❌ FirebaseAuthException in sendEmailVerification: ${e.code} - ${e.message}',
      );
      return Left(_handleFirebaseAuthException(e, stackTrace));
    } catch (e, stackTrace) {
      log('❌ Unexpected error in sendEmailVerification: ${e.toString()}');
      return Left(
        UnknownFailure('An unexpected error occurred while sending verification email', stackTrace),
      );
    }
  }

  Future<Either<Failure, void>> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(UnauthorizedFailure('No user signed in'));
      }

      await user.reload();
      log('✅ Firebase Auth: User data reloaded');
      return const Right(null);
    } catch (e, stackTrace) {
      log('❌ Unexpected error in reloadUser: ${e.toString()}');
      return Left(
        UnknownFailure(
          'An unexpected error occurred while reloading user data',
          stackTrace,
        ),
      );
    }
  }

  Future<Either<Failure, void>> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(UnauthorizedFailure('No user signed in'));
      }

      await user.updateDisplayName(displayName);
      await user.reload();
      log('✅ Firebase Auth: Display name updated to $displayName');
      return const Right(null);
    } catch (e, stackTrace) {
      log('❌ Unexpected error in updateDisplayName: ${e.toString()}');
      return Left(
        UnknownFailure('An unexpected error occurred while updating name', stackTrace),
      );
    }
  }

  Future<Either<Failure, void>> updatePhotoURL(String photoURL) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(UnauthorizedFailure('No user signed in'));
      }

      await user.updatePhotoURL(photoURL);
      await user.reload();
      log('✅ Firebase Auth: User photo updated');
      return const Right(null);
    } catch (e, stackTrace) {
      log('❌ Unexpected error in updatePhotoURL: ${e.toString()}');
      return Left(
        UnknownFailure('An unexpected error occurred while updating photo', stackTrace),
      );
    }
  }

  Future<Either<Failure, void>> deleteUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(UnauthorizedFailure('No user signed in'));
      }

      await user.delete();
      log('✅ Firebase Auth: User account deleted');
      return const Right(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      log('❌ FirebaseAuthException in deleteUser: ${e.code} - ${e.message}');
      return Left(_handleFirebaseAuthException(e, stackTrace));
    } catch (e, stackTrace) {
      log('❌ Unexpected error in deleteUser: ${e.toString()}');
      return Left(
        UnknownFailure('An unexpected error occurred while deleting account', stackTrace),
      );
    }
  }

  Failure _handleFirebaseAuthException(
    FirebaseAuthException e, [
    StackTrace? stackTrace,
  ]) {
    switch (e.code) {
      case 'user-not-found':
        return FirebaseFailure(
          'No account found with this email',
          stackTrace,
        );
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return FirebaseFailure('Incorrect password', stackTrace);
      case 'user-disabled':
        return FirebaseFailure('This account has been disabled', stackTrace);
      case 'too-many-requests':
        return FirebaseFailure(
          'Too many attempts. Please try again later',
          stackTrace,
        );

      case 'email-already-in-use':
        return FirebaseFailure('Email is already in use', stackTrace);
      case 'weak-password':
        return ValidationFailure('Password is too weak', stackTrace);
      case 'invalid-email':
        return ValidationFailure('Invalid email', stackTrace);
      case 'operation-not-allowed':
        return FirebaseFailure('Operation not allowed', stackTrace);

      case 'invalid-phone-number':
        return ValidationFailure('Invalid phone number', stackTrace);
      case 'invalid-verification-code':
        return ValidationFailure('Invalid verification code', stackTrace);
      case 'invalid-verification-id':
        return FirebaseFailure('Invalid verification ID', stackTrace);
      case 'session-expired':
        return FirebaseFailure(
          'Session expired. Please try again',
          stackTrace,
        );

      case 'network-request-failed':
        return NetworkFailure('Internet connection error', stackTrace);

      case 'requires-recent-login':
        return UnauthorizedFailure(
          'This operation requires recent login. Please sign in again',
          stackTrace,
        );

      default:
        return FirebaseFailure(
          e.message ?? 'Authentication error occurred',
          stackTrace,
        );
    }
  }
}
