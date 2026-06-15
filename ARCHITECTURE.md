# بنية التطبيق - حلاق

## نظرة عامة

تطبيق حلاق مبني باستخدام **Clean Architecture** مع نمط **Feature-First**، مما يضمن:
- فصل واضح بين الطبقات
- سهولة الصيانة والاختبار
- قابلية التوسع
- إعادة استخدام الكود

## الطبقات الرئيسية

### 1. Core Layer (الطبقة الأساسية)
تحتوي على الكود المشترك بين جميع الـ features:

#### Services (الخدمات)
```
lib/core/services/
├── firebase_auth_service.dart      # خدمة المصادقة باستخدام Firebase
├── firestore_service.dart          # خدمة قاعدة البيانات
├── supabase_storage_service.dart   # خدمة تخزين الملفات
├── get_it_service.dart             # إعداد Dependency Injection
└── navigation_service.dart         # خدمة التنقل
```

#### Widgets (المكونات المشتركة)
```
lib/core/widgets/
├── custom_button.dart              # زر مخصص مع Loading state
├── custom_text_field.dart          # حقل نص مخصص مع Validation
└── password_field.dart             # حقل كلمة مرور مع إظهار/إخفاء
```

#### Utils (الأدوات)
```
lib/core/utils/
├── color_manager.dart              # إدارة الألوان
├── text_styles.dart                # أنماط النصوص
└── validators.dart                 # دوال التحقق من الإدخال
```

#### Entities & Models
```
lib/core/entities/
└── user_entity.dart                # كيان المستخدم

lib/core/models/
└── user_model.dart                 # نموذج المستخدم
```

### 2. Features Layer (طبقة الميزات)

كل feature يتبع نفس البنية:

```
features/[feature_name]/
├── data/
│   ├── models/          # Data models مع fromJson/toJson
│   └── repos/           # تنفيذ Repository
├── domain/
│   ├── entities/        # Business entities
│   └── repos/           # Repository interfaces
└── presentation/
    ├── views/           # الشاشات
    ├── widgets/         # مكونات UI خاصة بالـ feature
    └── cubit/           # State management
```

#### Features المكتملة:

**1. Splash Feature**
```
features/splash/
└── presentation/
    └── views/
        └── splash_view.dart
```

**2. Auth Feature**
```
features/auth/
├── data/
│   └── repos/
│       └── auth_repo_impl.dart
├── domain/
│   └── repos/
│       └── auth_repo.dart
└── presentation/
    ├── views/
    │   ├── sign_in_view.dart
    │   └── sign_up_view.dart
    └── cubit/
        ├── auth_cubit.dart
        └── auth_state.dart
```

**3. Category Selection Feature**
```
features/category_selection/
└── presentation/
    ├── views/
    │   └── category_selection_view.dart
    └── widgets/
        └── category_card.dart
```

### 3. Config Layer (طبقة الإعدادات)

```
lib/config/
├── routes/
│   └── app_router.dart             # إدارة المسارات والتنقل
└── themes/
    └── app_theme.dart              # تصميم التطبيق
```

## Dependency Injection (GetIt)

### الخدمات المسجلة

```dart
// Singletons (نسخة واحدة)
- GlobalKey<NavigatorState>
- FirebaseAuthService
- FirestoreService
- SupabaseStorageService
- NavigationService

// Repositories (Singletons)
- AuthRepo

// Cubits (Factories - نسخة جديدة عند كل استدعاء)
- AuthCubit
```

### كيفية الاستخدام

```dart
// في أي مكان في التطبيق
final authCubit = getIt<AuthCubit>();
final authRepo = getIt<AuthRepo>();
```

## State Management (Cubit/Bloc)

### مثال: AuthCubit

```dart
// States
- AuthInitial
- AuthLoading
- AuthSuccess
- AuthError
- PhoneVerificationCodeSent

// Methods
- signIn(email, password)
- signUp(email, password, name)
- signInWithGoogle()
- signInWithPhone(phoneNumber)
- verifyOTP(verificationId, smsCode)
- signOut()
```

### استخدام في UI

```dart
BlocProvider(
  create: (context) => getIt<AuthCubit>(),
  child: BlocConsumer<AuthCubit, AuthState>(
    listener: (context, state) {
      // Handle navigation and messages
    },
    builder: (context, state) {
      // Build UI based on state
    },
  ),
)
```

## التنقل (Navigation)

### Named Routes

```dart
// التعريف
class SignInView {
  static const String routeName = '/sign-in';
}

// الاستخدام
Navigator.pushNamed(context, SignInView.routeName);
```

### AppRouter

يقوم `AppRouter.onGenerateRoute` بتوجيه كل route إلى الشاشة المناسبة:

```dart
case SignInView.routeName:
  return MaterialPageRoute(
    builder: (_) => const SignInView(),
  );
```

## التصميم (Theming)

### ColorManager

مدير مركزي لجميع الألوان في التطبيق:

```dart
ColorManager.primaryColor      // اللون الأساسي
ColorManager.secondaryColor    // اللون الثانوي
ColorManager.errorColor        // لون الخطأ
// ... إلخ
```

### TextStyles

أنماط نص موحدة في جميع أنحاء التطبيق:

```dart
TextStyles.heading1           // عنوان كبير
TextStyles.bodyMedium         // نص عادي متوسط
TextStyles.buttonMedium       // نص زر
// ... إلخ
```

## التحقق من الإدخال (Validation)

### Validators Class

```dart
Validators.validateEmail(value)        // تحقق من البريد الإلكتروني
Validators.validatePassword(value)     // تحقق من كلمة المرور
Validators.validatePhone(value)        // تحقق من رقم الهاتف
Validators.validateName(value)         // تحقق من الاسم
```

## تدفق البيانات

```
UI (View)
  ↓
Cubit
  ↓
Repository Interface
  ↓
Repository Implementation
  ↓
Service (Firebase/Supabase)
  ↓
Backend
```

## أفضل الممارسات المتبعة

1. **Single Responsibility**: كل class له مسؤولية واحدة
2. **Dependency Inversion**: الاعتماد على abstractions وليس implementations
3. **Code Reusability**: استخدام widgets و utilities مشتركة
4. **Type Safety**: استخدام Either type من dartz للتعامل مع الأخطاء
5. **Consistent Naming**: تسمية موحدة عبر المشروع
6. **RTL Support**: دعم اللغة العربية والـ RTL

## الاختبار

### Unit Tests
```
test/
├── core/
│   ├── services/
│   └── utils/
└── features/
    └── auth/
```

## التطوير المستقبلي

عند إضافة feature جديد:

1. أنشئ مجلد في `features/`
2. اتبع نفس البنية (data/domain/presentation)
3. أضف الـ repository و cubit في GetIt
4. أضف الـ routes في AppRouter
5. استخدم Core widgets و utils الموجودة

## الخلاصة

هذه البنية توفر:
- ✅ فصل واضح بين الطبقات
- ✅ سهولة الاختبار
- ✅ قابلية التوسع
- ✅ إعادة استخدام الكود
- ✅ صيانة سهلة
- ✅ أداء ممتاز
