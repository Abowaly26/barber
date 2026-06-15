import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/entities/user_entity.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/repos/auth_repo.dart';

/// Implementation of AuthRepo interface
/// Handles all authentication operations using Firebase services
class AuthRepoImpl implements AuthRepo {
  final FirebaseAuthService firebaseAuthService;
  final FirestoreService firestoreService;

  AuthRepoImpl({
    required this.firebaseAuthService,
    required this.firestoreService,
  });

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final result = await firebaseAuthService.signInWithEmail(
      email: email,
      password: password,
    );

    return result.fold((failure) => Left(failure), (user) async {
      // Get user data from Firestore
      final userDataResult = await getUserData(userId: user.uid);

      return userDataResult.fold((failure) {
        // If user data doesn't exist in Firestore, create it from Firebase user
        final userEntity = UserModel.fromFirebaseUser(user).toEntity();
        saveUserData(user: userEntity);
        return Right(userEntity);
      }, (userEntity) => Right(userEntity));
    });
  }

  @override
  Future<Either<Failure, String>> signInWithPhone({
    required String phoneNumber,
  }) async {
    Failure? errorResult;

    final result = await firebaseAuthService.signInWithPhone(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        log('✅ OTP code sent to $phoneNumber');
      },
      onVerificationFailed: (error) {
        log('❌ Phone verification failed: ${error.message}');
        errorResult = FirebaseFailure(
          error.message ?? 'فشل التحقق من رقم الهاتف',
        );
      },
    );

    return result.fold((failure) => Left(failure), (verificationId) {
      if (errorResult != null) {
        return Left(errorResult!);
      }
      return Right(verificationId);
    });
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    final result = await firebaseAuthService.verifyOTP(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    return result.fold((failure) => Left(failure), (user) async {
      // Get user data from Firestore
      final userDataResult = await getUserData(userId: user.uid);

      return userDataResult.fold((failure) {
        // If user data doesn't exist in Firestore, create it from Firebase user
        final userEntity = UserModel.fromFirebaseUser(user).toEntity();
        saveUserData(user: userEntity);
        return Right(userEntity);
      }, (userEntity) => Right(userEntity));
    });
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    final result = await firebaseAuthService.signInWithGoogle();

    return result.fold((failure) => Left(failure), (user) async {
      // Get user data from Firestore
      final userDataResult = await getUserData(userId: user.uid);

      return userDataResult.fold((failure) {
        // If user data doesn't exist in Firestore, create it from Firebase user
        final userEntity = UserModel.fromFirebaseUser(user).toEntity();
        saveUserData(user: userEntity);
        return Right(userEntity);
      }, (userEntity) => Right(userEntity));
    });
  }

  @override
  Future<Either<Failure, UserEntity>> createUserWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final result = await firebaseAuthService.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    return result.fold((failure) => Left(failure), (user) async {
      // Update display name
      await firebaseAuthService.updateDisplayName(name);

      // Create UserEntity
      final userEntity = UserEntity(
        id: user.uid,
        name: name,
        email: email,
        phoneNumber: user.phoneNumber,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save user data to Firestore
      final saveResult = await saveUserData(user: userEntity);

      return saveResult.fold(
        (failure) => Left(failure),
        (_) => Right(userEntity),
      );
    });
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    return await firebaseAuthService.signOut();
  }

  @override
  UserEntity? getCurrentUser() {
    final user = firebaseAuthService.getCurrentUser();

    if (user == null) return null;

    return UserModel.fromFirebaseUser(user).toEntity();
  }

  @override
  Future<Either<Failure, void>> saveUserData({required UserEntity user}) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final result = await firestoreService.addDocument(
        collection: 'users',
        data: userModel.toMap(),
        documentId: user.id,
      );

      return result.fold((failure) => Left(failure), (_) => const Right(null));
    } catch (e, stackTrace) {
      log('❌ Error saving user data: $e');
      return Left(UnknownFailure('فشل حفظ بيانات المستخدم', stackTrace));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserData({
    required String userId,
  }) async {
    try {
      final result = await firestoreService.getDocument(
        collection: 'users',
        documentId: userId,
      );

      return result.fold((failure) => Left(failure), (data) {
        final userModel = UserModel.fromJson(data);
        return Right(userModel.toEntity());
      });
    } catch (e, stackTrace) {
      log('❌ Error getting user data: $e');
      return Left(UnknownFailure('فشل الحصول على بيانات المستخدم', stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile({
    required UserEntity user,
  }) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final result = await firestoreService.updateDocument(
        collection: 'users',
        documentId: user.id,
        data: userModel.toMap(),
      );

      return result.fold((failure) => Left(failure), (_) => const Right(null));
    } catch (e, stackTrace) {
      log('❌ Error updating user profile: $e');
      return Left(UnknownFailure('فشل تحديث ملف المستخدم', stackTrace));
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmailExists(String email) async {
    try {
      // Check in Firestore database for email existence
      // This is more secure than using Firebase Auth methods
      final result = await firestoreService.getDocuments(
        collection: 'users',
        queryBuilder: (ref) => ref.where('email', isEqualTo: email).limit(1),
      );

      return result.fold(
        (failure) => Left(failure),
        (docs) => Right(docs.isNotEmpty),
      );
    } on FirebaseAuthException catch (e, stackTrace) {
      log(
        '❌ FirebaseAuthException in checkEmailExists: ${e.code} - ${e.message}',
      );
      return Left(
        FirebaseFailure(
          e.message ?? 'فشل التحقق من البريد الإلكتروني',
          stackTrace,
        ),
      );
    } catch (e, stackTrace) {
      log('❌ Error checking email existence: $e');
      return Left(
        UnknownFailure('فشل التحقق من البريد الإلكتروني', stackTrace),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    return await firebaseAuthService.sendPasswordResetEmail(email);
  }
}
