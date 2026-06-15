# Authentication Flow Documentation

## Overview
تم تطبيق نظام مصادقة كامل باستخدام Firebase Authentication مع دعم تسجيل الدخول بالبريد الإلكتروني وGoogle Sign-In.

## Authentication Flow

### 1. App Startup (SplashView)
```
App Start → SplashView (2 seconds)
  ↓
Check Firebase Auth State
  ├─ User Logged In → Fetch Profile → MainShell (Home)
  └─ User Not Logged In → SignInView
```

### 2. Sign In Flow
```
SignInView
  ├─ Email/Password Sign In → AuthCubit → Firebase Auth
  │   ↓ Success
  │   ├─ Save/Update User in Firestore
  │   ├─ Fetch Profile → ProfileProvider
  │   └─ Navigate to MainShell
  │
  └─ Google Sign In → AuthCubit → Firebase Auth → Google Sign In
      ↓ Success
      ├─ Save/Update User in Firestore
      ├─ Fetch Profile → ProfileProvider
      └─ Navigate to MainShell
```

### 3. Sign Up Flow
```
SignUpView
  ├─ Email/Password/Name → AuthCubit → Firebase Auth
  │   ↓ Success
  │   ├─ Update Display Name
  │   ├─ Save User to Firestore
  │   ├─ Fetch Profile → ProfileProvider
  │   └─ Navigate to MainShell
  │
  └─ Google Sign Up → (Same as Google Sign In)
```

### 4. Home Display
```
MainShell → HomeAppBar
  ├─ ProfileProvider → Display User Name
  └─ ProfileAvatar → Display User Photo
```

## Key Components

### 1. AuthCubit
- `signIn(email, password)` - تسجيل دخول بالبريد الإلكتروني
- `signUp(email, password, name)` - إنشاء حساب جديد
- `signInWithGoogle()` - تسجيل دخول بGoogle
- `sendPasswordReset(email)` - إعادة تعيين كلمة المرور
- `signOut()` - تسجيل خروج

### 2. ProfileProvider
- `fetchUserProfile(userId)` - جلب بيانات المستخدم من Firestore
- `updateUserProfile(...)` - تحديث بيانات المستخدم
- `listenToUserProfile(userId)` - متابعة تغييرات البيانات في الوقت الفعلي
- `clearUser()` - مسح بيانات المستخدم عند تسجيل الخروج

### 3. Firebase Auth Service
- `signInWithEmail()` - تسجيل دخول بالبريد الإلكتروني
- `createUserWithEmailAndPassword()` - إنشاء حساب جديد
- `signInWithGoogle()` - تسجيل دخول بGoogle
- `signOut()` - تسجيل خروج
- `getCurrentUser()` - الحصول على المستخدم الحالي

### 4. Auth Repository Implementation
- يربط بين AuthCubit و Firebase Auth Service
- يحفظ بيانات المستخدم في Firestore بعد المصادقة
- يجلب بيانات المستخدم من Firestore

## User Data Flow

### Google Sign In Example:
1. User clicks "Sign in with Google"
2. `AuthCubit.signInWithGoogle()` is called
3. `AuthRepoImpl.signInWithGoogle()` → `FirebaseAuthService.signInWithGoogle()`
4. Google Sign In Dialog appears
5. User selects Google account
6. Firebase creates/gets user credential
7. Check if user exists in Firestore:
   - If exists: Load user data
   - If not exists: Create new user document with Firebase Auth data
8. `AuthCubit` emits `AuthSuccess(userEntity)`
9. `SignInView` listener:
   - Calls `ProfileProvider.fetchUserProfile(userId)`
   - Navigates to `MainShell`
10. `HomeAppBar` displays user name and photo from `ProfileProvider`

## Files Modified/Created

### Core Files:
- `lib/main.dart` - MultiProvider setup with ProfileProvider
- `lib/config/routes/app_router.dart` - Routes for SignIn/SignUp

### Auth Files:
- `lib/features/auth/presentation/views/sign_in_view.dart` - Sign in screen
- `lib/features/auth/presentation/views/sign_up_view.dart` - Sign up screen
- `lib/features/auth/presentation/cubit/auth_cubit.dart` - Auth state management
- `lib/features/auth/data/repos/auth_repo_impl.dart` - Auth repository
- `lib/core/services/firebase_auth_service.dart` - Firebase Auth wrapper

### Profile Files:
- `lib/features/profile/presentation/cubit/profile_provider.dart` - Profile state management
- `lib/core/widgets/profile_avatar.dart` - Profile avatar widget
- `lib/features/main_shell/presentation/views/widgets/home_appbar.dart` - Home AppBar

### Splash:
- `lib/features/splash/presentation/views/splash_view.dart` - Splash screen with auth check

## Firebase Setup Required

### 1. Firebase Console:
- Enable Email/Password Authentication
- Enable Google Sign-In
- Add SHA-1 key for Android (for Google Sign-In)
- Download and add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

### 2. Firestore Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Testing

### Test Scenarios:
1. ✅ First time user → Sign up with email
2. ✅ First time user → Sign up with Google
3. ✅ Existing user → Sign in with email
4. ✅ Existing user → Sign in with Google
5. ✅ User closes app → Reopen → Should go to Home (if logged in)
6. ✅ Forgot password → Receive email
7. ✅ Sign out → Go to Sign In screen

## Known Issues
- Google Sign-In requires SHA-1 key configured in Firebase Console
- If `assets/google_icon.png` is missing, fallback icon (G) will be shown

## Future Enhancements
- [ ] Phone authentication
- [ ] Email verification
- [ ] Social login (Facebook, Apple)
- [ ] Remember me functionality
- [ ] Biometric authentication
