import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../errors/failures.dart';

/// Service لإدارة جميع عمليات المصادقة عبر Firebase
/// يستخدم Either type من dartz للتعامل مع الأخطاء بطريقة functional
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  ///
  /// Returns: Either<Failure, User>
  /// - Left: FirebaseFailure في حالة حدوث خطأ
  /// - Right: User في حالة النجاح
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
          FirebaseFailure('فشل تسجيل الدخول - لم يتم العثور على المستخدم'),
        );
      }

      log(
        '✅ Firebase Auth: تم تسجيل الدخول بنجاح للمستخدم: ${credential.user!.email}',
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
        UnknownFailure('حدث خطأ غير متوقع أثناء تسجيل الدخول', stackTrace),
      );
    }
  }

  /// إنشاء حساب جديد باستخدام البريد الإلكتروني وكلمة المرور
  ///
  /// Returns: Either<Failure, User>
  /// - Left: FirebaseFailure في حالة حدوث خطأ
  /// - Right: User في حالة النجاح
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
          FirebaseFailure('فشل إنشاء الحساب - لم يتم إنشاء المستخدم'),
        );
      }

      log(
        '✅ Firebase Auth: تم إنشاء حساب جديد للمستخدم: ${credential.user!.email}',
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
        UnknownFailure('حدث خطأ غير متوقع أثناء إنشاء الحساب', stackTrace),
      );
    }
  }

  /// إرسال رمز التحقق OTP إلى رقم الهاتف
  ///
  /// Parameters:
  /// - phoneNumber: رقم الهاتف بصيغة دولية (مثال: +966501234567)
  /// - onCodeSent: callback يتم استدعاؤه عند إرسال الكود بنجاح
  /// - onVerificationFailed: callback يتم استدعاؤه في حالة فشل التحقق
  ///
  /// Returns: Either<Failure, String>
  /// - Left: FirebaseFailure في حالة حدوث خطأ
  /// - Right: verificationId في حالة النجاح
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
          // يتم استدعاؤه تلقائياً في بعض الحالات (Android فقط)
          log('📱 Firebase Auth: التحقق التلقائي من الهاتف اكتمل');
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          log(
            '❌ Firebase Auth: فشل التحقق من رقم الهاتف - ${e.code}: ${e.message}',
          );
          errorResult = _handleFirebaseAuthException(e);
          onVerificationFailed(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          log('✅ Firebase Auth: تم إرسال رمز التحقق إلى $phoneNumber');
          verificationIdResult = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          log('⏱️ Firebase Auth: انتهت مهلة استرجاع الكود التلقائي');
          verificationIdResult = verificationId;
        },
      );

      // انتظار حتى يتم الحصول على النتيجة
      await Future.delayed(const Duration(milliseconds: 500));

      if (errorResult != null) {
        return Left(errorResult!);
      }

      if (verificationIdResult != null) {
        return Right(verificationIdResult!);
      }

      return const Left(
        FirebaseFailure('فشل إرسال رمز التحقق - لم يتم الحصول على معرف التحقق'),
      );
    } catch (e, stackTrace) {
      log('❌ Unexpected error in signInWithPhone: ${e.toString()}');
      return Left(
        UnknownFailure('حدث خطأ غير متوقع أثناء إرسال رمز التحقق', stackTrace),
      );
    }
  }

  /// التحقق من رمز OTP وإتمام تسجيل الدخول
  ///
  /// Parameters:
  /// - verificationId: معرف التحقق الذي تم الحصول عليه من signInWithPhone
  /// - smsCode: رمز التحقق الذي أدخله المستخدم
  ///
  /// Returns: Either<Failure, User>
  /// - Left: FirebaseFailure في حالة حدوث خطأ
  /// - Right: User في حالة النجاح
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
          FirebaseFailure('فشل التحقق من الرمز - لم يتم العثور على المستخدم'),
        );
      }

      log(
        '✅ Firebase Auth: تم التحقق من رمز OTP بنجاح للمستخدم: ${userCredential.user!.phoneNumber}',
      );
      return Right(userCredential.user!);
    } on FirebaseAuthException catch (e, stackTrace) {
      log('❌ FirebaseAuthException in verifyOTP: ${e.code} - ${e.message}');
      return Left(_handleFirebaseAuthException(e, stackTrace));
    } catch (e, stackTrace) {
      log('❌ Unexpected error in verifyOTP: ${e.toString()}');
      return Left(
        UnknownFailure('حدث خطأ غير متوقع أثناء التحقق من الرمز', stackTrace),
      );
    }
  }

  /// تسجيل الدخول باستخدام حساب Google
  ///
  /// Returns: Either<Failure, User>
  /// - Left: FirebaseFailure في حالة حدوث خطأ
  /// - Right: User في حالة النجاح
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      // Sign out first to allow re-selecting account
      await _googleSignIn.signOut();

      // Start Google sign in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If user cancelled the sign in
      if (googleUser == null) {
        return const Left(FirebaseFailure('Google sign in was cancelled'));
      }

      // Get auth credentials
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credential
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

  /// تسجيل الخروج من التطبيق
  ///
  /// Returns: Either<Failure, void>
  /// - Left: FirebaseFailure في حالة حدوث خطأ
  /// - Right: void في حالة النجاح
  Future<Either<Failure, void>> signOut() async {
    try {
      // تسجيل الخروج من Firebase
      await _auth.signOut();

      // تسجيل الخروج من Google (إن كان مسجلاً دخول)
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      log('✅ Firebase Auth: تم تسجيل الخروج بنجاح');
      return const Right(null);
    } catch (e, stackTrace) {
      log('❌ Unexpected error in signOut: ${e.toString()}');
      return Left(
        UnknownFailure('حدث خطأ غير متوقع أثناء تسجيل الخروج', stackTrace),
      );
    }
  }

  /// الحصول على المستخدم الحالي
  ///
  /// Returns: User? - المستخدم الحالي أو null إذا لم يكن مسجلاً دخول
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// التحقق من أن المستخدم مسجل دخول
  ///
  /// Returns: bool - true إذا كان مسجلاً دخول، false إذا لم يكن
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  /// Stream لمتابعة تغييرات حالة المصادقة
  ///
  /// يتم استدعاؤه عند:
  /// - تسجيل الدخول
  /// - تسجيل الخروج
  /// - تحديث بيانات المستخدم
  ///
  /// Returns: Stream<User?> - stream للمستخدم الحالي
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  /// إرسال بريد إلكتروني لإعادة تعيين كلمة المرور
  ///
  /// Returns: Either<Failure, void>
  /// - Left: FirebaseFailure في حالة حدوث خطأ
  /// - Right: void في حالة النجاح
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      log('✅ Firebase Auth: تم إرسال بريد إعادة تعيين كلمة المرور إلى $email');
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
          'حدث خطأ غير متوقع أثناء إرسال بريد إعادة تعيين كلمة المرور',
          stackTrace,
        ),
      );
    }
  }

  /// إرسال بريد تحقق من البريد الإلكتروني
  ///
  /// Returns: Either<Failure, void>
  /// - Left: FirebaseFailure في حالة حدوث خطأ
  /// - Right: void في حالة النجاح
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(UnauthorizedFailure('لا يوجد مستخدم مسجل دخول'));
      }

      if (user.emailVerified) {
        return const Left(ValidationFailure('البريد الإلكتروني مُحقق بالفعل'));
      }

      await user.sendEmailVerification();
      log('✅ Firebase Auth: تم إرسال بريد التحقق إلى ${user.email}');
      return const Right(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      log(
        '❌ FirebaseAuthException in sendEmailVerification: ${e.code} - ${e.message}',
      );
      return Left(_handleFirebaseAuthException(e, stackTrace));
    } catch (e, stackTrace) {
      log('❌ Unexpected error in sendEmailVerification: ${e.toString()}');
      return Left(
        UnknownFailure('حدث خطأ غير متوقع أثناء إرسال بريد التحقق', stackTrace),
      );
    }
  }

  /// إعادة تحميل بيانات المستخدم الحالي
  ///
  /// Returns: Either<Failure, void>
  /// - Left: FirebaseFailure في حالة حدوث خطأ
  /// - Right: void في حالة النجاح
  Future<Either<Failure, void>> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(UnauthorizedFailure('لا يوجد مستخدم مسجل دخول'));
      }

      await user.reload();
      log('✅ Firebase Auth: تم إعادة تحميل بيانات المستخدم');
      return const Right(null);
    } catch (e, stackTrace) {
      log('❌ Unexpected error in reloadUser: ${e.toString()}');
      return Left(
        UnknownFailure(
          'حدث خطأ غير متوقع أثناء إعادة تحميل بيانات المستخدم',
          stackTrace,
        ),
      );
    }
  }

  /// تحديث الاسم المعروض للمستخدم
  ///
  /// Returns: Either<Failure, void>
  /// - Left: FirebaseFailure في حالة حدوث خطأ
  /// - Right: void في حالة النجاح
  Future<Either<Failure, void>> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(UnauthorizedFailure('لا يوجد مستخدم مسجل دخول'));
      }

      await user.updateDisplayName(displayName);
      await user.reload();
      log('✅ Firebase Auth: تم تحديث الاسم المعروض إلى $displayName');
      return const Right(null);
    } catch (e, stackTrace) {
      log('❌ Unexpected error in updateDisplayName: ${e.toString()}');
      return Left(
        UnknownFailure('حدث خطأ غير متوقع أثناء تحديث الاسم', stackTrace),
      );
    }
  }

  /// تحديث صورة المستخدم
  ///
  /// Returns: Either<Failure, void>
  /// - Left: FirebaseFailure في حالة حدوث خطأ
  /// - Right: void في حالة النجاح
  Future<Either<Failure, void>> updatePhotoURL(String photoURL) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(UnauthorizedFailure('لا يوجد مستخدم مسجل دخول'));
      }

      await user.updatePhotoURL(photoURL);
      await user.reload();
      log('✅ Firebase Auth: تم تحديث صورة المستخدم');
      return const Right(null);
    } catch (e, stackTrace) {
      log('❌ Unexpected error in updatePhotoURL: ${e.toString()}');
      return Left(
        UnknownFailure('حدث خطأ غير متوقع أثناء تحديث الصورة', stackTrace),
      );
    }
  }

  /// حذف حساب المستخدم الحالي
  ///
  /// Returns: Either<Failure, void>
  /// - Left: FirebaseFailure في حالة حدوث خطأ
  /// - Right: void في حالة النجاح
  Future<Either<Failure, void>> deleteUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(UnauthorizedFailure('لا يوجد مستخدم مسجل دخول'));
      }

      await user.delete();
      log('✅ Firebase Auth: تم حذف حساب المستخدم');
      return const Right(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      log('❌ FirebaseAuthException in deleteUser: ${e.code} - ${e.message}');
      return Left(_handleFirebaseAuthException(e, stackTrace));
    } catch (e, stackTrace) {
      log('❌ Unexpected error in deleteUser: ${e.toString()}');
      return Left(
        UnknownFailure('حدث خطأ غير متوقع أثناء حذف الحساب', stackTrace),
      );
    }
  }

  /// معالج مركزي لأخطاء Firebase Auth
  /// يحول أكواد الأخطاء إلى رسائل واضحة باللغة العربية
  Failure _handleFirebaseAuthException(
    FirebaseAuthException e, [
    StackTrace? stackTrace,
  ]) {
    switch (e.code) {
      // أخطاء تسجيل الدخول
      case 'user-not-found':
        return FirebaseFailure(
          'لم يتم العثور على حساب بهذا البريد الإلكتروني',
          stackTrace,
        );
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return FirebaseFailure('كلمة المرور غير صحيحة', stackTrace);
      case 'user-disabled':
        return FirebaseFailure('تم تعطيل هذا الحساب', stackTrace);
      case 'too-many-requests':
        return FirebaseFailure(
          'تم تجاوز عدد المحاولات المسموح بها، يرجى المحاولة لاحقاً',
          stackTrace,
        );

      // أخطاء إنشاء الحساب
      case 'email-already-in-use':
        return FirebaseFailure('البريد الإلكتروني مستخدم بالفعل', stackTrace);
      case 'weak-password':
        return ValidationFailure('كلمة المرور ضعيفة جداً', stackTrace);
      case 'invalid-email':
        return ValidationFailure('البريد الإلكتروني غير صالح', stackTrace);
      case 'operation-not-allowed':
        return FirebaseFailure('العملية غير مسموح بها', stackTrace);

      // أخطاء التحقق من الهاتف
      case 'invalid-phone-number':
        return ValidationFailure('رقم الهاتف غير صالح', stackTrace);
      case 'invalid-verification-code':
        return ValidationFailure('رمز التحقق غير صحيح', stackTrace);
      case 'invalid-verification-id':
        return FirebaseFailure('معرف التحقق غير صالح', stackTrace);
      case 'session-expired':
        return FirebaseFailure(
          'انتهت صلاحية الجلسة، يرجى المحاولة مرة أخرى',
          stackTrace,
        );

      // أخطاء الشبكة
      case 'network-request-failed':
        return NetworkFailure('خطأ في الاتصال بالإنترنت', stackTrace);

      // أخطاء تتطلب إعادة تسجيل دخول
      case 'requires-recent-login':
        return UnauthorizedFailure(
          'تتطلب هذه العملية تسجيل دخول حديث، يرجى تسجيل الدخول مرة أخرى',
          stackTrace,
        );

      // خطأ افتراضي
      default:
        return FirebaseFailure(
          e.message ?? 'حدث خطأ في عملية المصادقة',
          stackTrace,
        );
    }
  }
}
