# Firebase Auth Service Documentation

## Overview

تم إنشاء `FirebaseAuthService` كخدمة مركزية لإدارة جميع عمليات المصادقة في التطبيق باستخدام Firebase Authentication. الخدمة تتبع نفس النمط المستخدم في مشروع pharma_now مع Either type من مكتبة dartz للتعامل مع الأخطاء بطريقة functional.

## Features Implemented

### ✅ 1. تسجيل الدخول بالبريد الإلكتروني
```dart
Future<Either<Failure, User>> signInWithEmail({
  required String email,
  required String password,
})
```
- تسجيل الدخول باستخدام email و password
- معالجة شاملة لجميع أخطاء Firebase Auth
- رسائل خطأ واضحة باللغة العربية

### ✅ 2. إنشاء حساب جديد
```dart
Future<Either<Failure, User>> createUserWithEmailAndPassword({
  required String email,
  required String password,
})
```
- إنشاء حساب جديد في Firebase
- التحقق من صلاحية البيانات
- معالجة أخطاء مثل "البريد مستخدم بالفعل" و "كلمة المرور ضعيفة"

### ✅ 3. تسجيل الدخول بالهاتف (Phone Authentication)
```dart
Future<Either<Failure, String>> signInWithPhone({
  required String phoneNumber,
  required Function(String verificationId) onCodeSent,
  required Function(FirebaseAuthException) onVerificationFailed,
})
```
- إرسال رمز OTP إلى رقم الهاتف
- Callbacks للتعامل مع حالات مختلفة (codeSent, verificationFailed, etc.)
- دعم التحقق التلقائي (Android)

### ✅ 4. التحقق من رمز OTP
```dart
Future<Either<Failure, User>> verifyOTP({
  required String verificationId,
  required String smsCode,
})
```
- التحقق من رمز OTP المدخل من قبل المستخدم
- إكمال عملية تسجيل الدخول بالهاتف

### ✅ 5. تسجيل الدخول بـ Google
```dart
Future<Either<Failure, User>> signInWithGoogle()
```
- تسجيل الدخول باستخدام حساب Google
- معالجة حالة إلغاء المستخدم لعملية التسجيل
- دمج كامل مع Google Sign-In

### ✅ 6. تسجيل الخروج
```dart
Future<Either<Failure, void>> signOut()
```
- تسجيل الخروج من Firebase و Google معاً
- تنظيف جميع sessions

### ✅ 7. الحصول على المستخدم الحالي
```dart
User? getCurrentUser()
bool isLoggedIn()
```
- الحصول على بيانات المستخدم الحالي
- التحقق من حالة تسجيل الدخول

### ✅ 8. Stream لحالة المصادقة
```dart
Stream<User?> authStateChanges()
```
- متابعة تغييرات حالة المصادقة في الوقت الفعلي
- يتم استدعاؤه عند تسجيل الدخول/الخروج أو تحديث بيانات المستخدم

### ✅ 9. إعادة تعيين كلمة المرور
```dart
Future<Either<Failure, void>> sendPasswordResetEmail(String email)
```
- إرسال بريد إلكتروني لإعادة تعيين كلمة المرور

### ✅ 10. تحقق من البريد الإلكتروني
```dart
Future<Either<Failure, void>> sendEmailVerification()
```
- إرسال بريد تحقق للمستخدم الحالي

### ✅ 11. تحديث بيانات المستخدم
```dart
Future<Either<Failure, void>> updateDisplayName(String displayName)
Future<Either<Failure, void>> updatePhotoURL(String photoURL)
Future<Either<Failure, void>> reloadUser()
```
- تحديث الاسم المعروض
- تحديث صورة المستخدم
- إعادة تحميل بيانات المستخدم

### ✅ 12. حذف الحساب
```dart
Future<Either<Failure, void>> deleteUser()
```
- حذف حساب المستخدم من Firebase

## Error Handling

### معالج مركزي للأخطاء
تم تنفيذ `_handleFirebaseAuthException()` كمعالج مركزي يحول أكواد أخطاء Firebase إلى Failure objects مع رسائل واضحة بالعربية:

#### أخطاء تسجيل الدخول:
- `user-not-found` → "لم يتم العثور على حساب بهذا البريد الإلكتروني"
- `wrong-password` → "كلمة المرور غير صحيحة"
- `user-disabled` → "تم تعطيل هذا الحساب"
- `too-many-requests` → "تم تجاوز عدد المحاولات المسموح بها"

#### أخطاء إنشاء الحساب:
- `email-already-in-use` → "البريد الإلكتروني مستخدم بالفعل"
- `weak-password` → "كلمة المرور ضعيفة جداً"
- `invalid-email` → "البريد الإلكتروني غير صالح"

#### أخطاء التحقق من الهاتف:
- `invalid-phone-number` → "رقم الهاتف غير صالح"
- `invalid-verification-code` → "رمز التحقق غير صحيح"
- `session-expired` → "انتهت صلاحية الجلسة"

#### أخطاء الشبكة:
- `network-request-failed` → `NetworkFailure`

#### أخطاء الصلاحيات:
- `requires-recent-login` → `UnauthorizedFailure`

## Usage Examples

### مثال 1: تسجيل الدخول بالبريد الإلكتروني
```dart
final authService = FirebaseAuthService();

final result = await authService.signInWithEmail(
  email: 'user@example.com',
  password: 'password123',
);

result.fold(
  (failure) {
    // معالجة الخطأ
    print('Error: ${failure.message}');
  },
  (user) {
    // نجح تسجيل الدخول
    print('Logged in: ${user.email}');
  },
);
```

### مثال 2: تسجيل الدخول بالهاتف
```dart
final authService = FirebaseAuthService();

// 1. إرسال رمز OTP
String? verificationId;

final result = await authService.signInWithPhone(
  phoneNumber: '+966501234567',
  onCodeSent: (String verId) {
    verificationId = verId;
    // عرض UI لإدخال الكود
  },
  onVerificationFailed: (FirebaseAuthException e) {
    // معالجة الخطأ
    print('Verification failed: ${e.message}');
  },
);

// 2. التحقق من رمز OTP
if (verificationId != null) {
  final verifyResult = await authService.verifyOTP(
    verificationId: verificationId!,
    smsCode: '123456', // الكود المدخل من المستخدم
  );
  
  verifyResult.fold(
    (failure) => print('Error: ${failure.message}'),
    (user) => print('Phone verified: ${user.phoneNumber}'),
  );
}
```

### مثال 3: تسجيل الدخول بـ Google
```dart
final authService = FirebaseAuthService();

final result = await authService.signInWithGoogle();

result.fold(
  (failure) {
    if (failure.message.contains('إلغاء')) {
      // المستخدم ألغى العملية
      print('User cancelled');
    } else {
      // خطأ آخر
      print('Error: ${failure.message}');
    }
  },
  (user) {
    print('Signed in with Google: ${user.displayName}');
  },
);
```

### مثال 4: متابعة حالة المصادقة
```dart
final authService = FirebaseAuthService();

authService.authStateChanges().listen((User? user) {
  if (user == null) {
    // المستخدم غير مسجل دخول
    print('User is signed out');
  } else {
    // المستخدم مسجل دخول
    print('User is signed in: ${user.email}');
  }
});
```

## Integration with Repository Pattern

يجب استخدام هذه الخدمة من خلال Repository Layer (وليس مباشرة من UI):

```dart
// lib/features/auth/data/repos/auth_repo_impl.dart
class AuthRepoImpl implements AuthRepo {
  final FirebaseAuthService authService;
  final FirestoreService firestoreService;
  
  AuthRepoImpl({
    required this.authService,
    required this.firestoreService,
  });
  
  @override
  Future<Either<Failure, UserEntity>> signInWithEmail(
    String email,
    String password,
  ) async {
    final result = await authService.signInWithEmail(
      email: email,
      password: password,
    );
    
    return result.fold(
      (failure) => Left(failure),
      (user) async {
        // جلب بيانات المستخدم من Firestore
        final userDataResult = await firestoreService.getDocument(
          'users',
          user.uid,
        );
        
        return userDataResult.fold(
          (failure) => Left(failure),
          (userData) {
            final userModel = UserModel.fromJson(userData);
            return Right(userModel.toEntity());
          },
        );
      },
    );
  }
}
```

## Dependency Injection Setup

يجب تسجيل الخدمة في GetIt:

```dart
// lib/core/services/get_it_service.dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  // Register Core Services
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService());
  
  // Register Repositories
  getIt.registerSingleton<AuthRepo>(
    AuthRepoImpl(
      authService: getIt<FirebaseAuthService>(),
      firestoreService: getIt<FirestoreService>(),
    ),
  );
  
  // Register Cubits as Factories
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepo>()));
}
```

## Logging

الخدمة تستخدم `dart:developer` log للـ logging:
- ✅ الرموز التعبيرية للنجاح
- ❌ للأخطاء
- 📱 للعمليات الخاصة بالهاتف
- ⏱️ للتحذيرات المتعلقة بالوقت

يمكن مراقبة هذه السجلات في:
- Android Studio / VS Code Debug Console
- `flutter logs` في Terminal
- Firebase Crashlytics (للإنتاج)

## Requirements Covered

هذا التنفيذ يغطي المتطلبات التالية من الـ spec:

### Requirement 2: Backend Integration
- ✅ 2.1: Firebase_Service SHALL provide authentication functionality

### Requirement 12: User Authentication
- ✅ 12.1: THE System SHALL provide phone number authentication via Firebase_Service
- ✅ 12.2: THE System SHALL provide email/password authentication via Firebase_Service
- ✅ 12.3: THE System SHALL provide Google Sign-In option
- ✅ 12.4: WHEN User enters phone number, THEN THE System SHALL send OTP code
- ✅ 12.5: WHEN User enters valid OTP, THEN THE System SHALL authenticate User
- ✅ 12.8: THE System SHALL allow User to logout

## Next Steps

بعد تنفيذ هذه الخدمة، الخطوات التالية هي:

1. ✅ **Task 2.2 Complete** - Firebase Auth Service
2. ⏭️ **Task 2.3** - إنشاء Firestore Service
3. ⏭️ **Task 2.4** - إنشاء Supabase Storage Service
4. ⏭️ **Task 16** - تنفيذ Authentication Feature (Repo, Cubit, UI)

## Notes

- **Thread Safety**: Firebase Auth operations هي thread-safe بشكل افتراضي
- **Performance**: جميع العمليات async ولا تحجب UI thread
- **Security**: لا يتم تخزين كلمات المرور محلياً، كل شيء يتم عبر Firebase
- **Testing**: يمكن mock هذه الخدمة بسهولة للـ unit testing
- **Google Sign-In Configuration**: يتطلب إعداد Google Sign-In في Firebase Console و google-services.json/GoogleService-Info.plist

## Dependencies Required

```yaml
dependencies:
  firebase_core: ^3.13.0
  firebase_auth: ^5.5.2
  google_sign_in: ^6.3.0  # ✅ تم إضافتها
  dartz: ^0.10.1
  equatable: ^2.0.7
```

## Platform-Specific Configuration

### Android
1. Add to `android/app/build.gradle`:
```gradle
defaultConfig {
    multiDexEnabled true
}
```

2. Google Sign-In requires SHA-1 fingerprint in Firebase Console

### iOS
1. Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

2. Enable Keychain Sharing in Xcode

## تم الإنجاز ✅

تم إنشاء `FirebaseAuthService` بنجاح مع:
- ✅ جميع الوظائف المطلوبة (Email, Phone, Google, SignOut)
- ✅ معالجة شاملة للأخطاء مع Either type
- ✅ رسائل خطأ واضحة بالعربية
- ✅ Logging شامل
- ✅ Documentation كاملة
- ✅ متوافق مع Clean Architecture pattern
- ✅ جاهز للاستخدام من خلال Repository Layer
