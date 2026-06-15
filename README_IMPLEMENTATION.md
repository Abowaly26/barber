# تطبيق حلاق - Barber Booking App

## 🎯 نظرة عامة

تطبيق حلاق هو منصة متكاملة لحجز مواعيد الحلاقة والتجميل، مبني باستخدام Flutter مع Clean Architecture. يوفر التطبيق واجهة سهلة الاستخدام للعملاء لحجز المواعيد وتصفح الخدمات.

## ✨ الميزات المكتملة

### 🚀 المصادقة والتسجيل
- ✅ تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
- ✅ إنشاء حساب جديد
- ✅ تسجيل الدخول باستخدام Google
- ✅ التحقق من صحة الإدخال
- ✅ حالات Loading واضحة
- ✅ رسائل خطأ مفيدة

### 🏠 الشاشة الرئيسية (Category Selection)
- ✅ 6 فئات رئيسية:
  - خدمات الرجال
  - خدمات النساء
  - خدمات الأطفال
  - متجر QUTI
  - انضم كمزود خدمة
  - مستشار الشعر الذكي
- ✅ تصميم بكروت أنيقة
- ✅ تأثيرات عند الضغط

### 🎨 التصميم
- ✅ واجهة مستخدم عصرية وجذابة
- ✅ دعم اللغة العربية (RTL)
- ✅ تصميم متجاوب لجميع أحجام الشاشات
- ✅ نظام ألوان متناسق
- ✅ أنماط نص موحدة

## 🏗️ البنية التقنية

### المعمارية
```
Clean Architecture + Feature-First Pattern
├── Core Layer (مشترك)
├── Features Layer (مستقل)
└── Config Layer (إعدادات)
```

### التقنيات المستخدمة
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Cubit/Bloc
- **Dependency Injection**: GetIt
- **Backend**: Firebase + Supabase
- **UI**: flutter_screenutil, Material 3

### المكتبات الرئيسية
```yaml
dependencies:
  flutter_bloc: ^8.1.6          # State management
  get_it: ^8.3.0                # Dependency injection
  dartz: ^0.10.1                # Functional programming
  firebase_core: ^3.15.2        # Firebase core
  firebase_auth: ^5.7.0         # Authentication
  cloud_firestore: ^5.6.12      # Database
  supabase_flutter: ^2.10.0     # Supabase integration
  flutter_screenutil: ^5.9.3    # Responsive UI
```

## 📁 هيكل المشروع

```
lib/
├── main.dart                    # نقطة البداية
├── core/                        # الكود المشترك
│   ├── entities/               # الكيانات
│   ├── models/                 # النماذج
│   ├── services/               # الخدمات
│   ├── utils/                  # الأدوات
│   └── widgets/                # المكونات المشتركة
├── features/                    # الميزات
│   ├── splash/                 # شاشة البداية
│   ├── auth/                   # المصادقة
│   └── category_selection/     # اختيار الفئة
└── config/                      # الإعدادات
    ├── routes/                 # المسارات
    └── themes/                 # التصميم
```

## 🚀 كيفية التشغيل

### المتطلبات
- Flutter SDK 3.x أو أحدث
- Dart 3.x أو أحدث
- Android Studio أو VS Code
- حساب Firebase مع إعداد المشروع
- حساب Supabase (اختياري)

### خطوات التشغيل

1. **استنساخ المشروع**
```bash
git clone [repository-url]
cd app
```

2. **تثبيت Dependencies**
```bash
flutter pub get
```

3. **إعداد Firebase**
```bash
# تأكد من وجود google-services.json للأندرويد
# و GoogleService-Info.plist للـ iOS
```

4. **تشغيل التطبيق**
```bash
flutter run
```

## 📱 الشاشات

### 1. Splash Screen
- عرض لوجو التطبيق
- مؤشر تحميل
- الانتقال التلقائي بعد 2 ثانية

### 2. Sign In Screen
- حقل البريد الإلكتروني
- حقل كلمة المرور
- زر تسجيل الدخول
- زر Google Sign In
- خيار تذكرني
- رابط نسيت كلمة المرور
- رابط إنشاء حساب

### 3. Sign Up Screen
- حقل الاسم الكامل
- حقل البريد الإلكتروني
- حقل كلمة المرور
- حقل تأكيد كلمة المرور
- خانة الموافقة على الشروط
- زر إنشاء حساب
- زر Google Sign Up
- رابط تسجيل الدخول

### 4. Category Selection Screen
- عنوان ترحيبي
- 6 كروت للفئات
- زر الملف الشخصي

## 🎨 التخصيص

### الألوان
يمكنك تعديل الألوان من `lib/core/utils/color_manager.dart`:

```dart
static const Color primaryColor = Color(0xFF2C3E50);
static const Color secondaryColor = Color(0xFFE67E22);
static const Color accentColor = Color(0xFF3498DB);
```

### أنماط النص
يمكنك تعديل أنماط النص من `lib/core/utils/text_styles.dart`:

```dart
static TextStyle heading1 = TextStyle(
  fontFamily: 'Tajawal',
  fontSize: 32.sp,
  fontWeight: FontWeight.bold,
);
```

## 🧪 الاختبار

### تشغيل الاختبارات
```bash
# جميع الاختبارات
flutter test

# اختبارات محددة
flutter test test/core/utils/validators_test.dart
```

## 📝 الوثائق الإضافية

- [ARCHITECTURE.md](ARCHITECTURE.md) - شرح تفصيلي للبنية
- [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) - ملخص التنفيذ

## 🔜 المهام المستقبلية

- [ ] تطوير شاشات خدمات الرجال
- [ ] تطوير شاشات خدمات النساء
- [ ] تطوير شاشات خدمات الأطفال
- [ ] تطوير متجر QUTI
- [ ] تطوير تسجيل مزود الخدمة
- [ ] تطوير مستشار الشعر الذكي
- [ ] نظام الحجز
- [ ] نظام التقييمات
- [ ] نظام الدفع
- [ ] الإشعارات

## 🐛 الإبلاغ عن المشاكل

إذا واجهت أي مشكلة، يرجى:
1. التحقق من وجود Firebase و Supabase configurations
2. تشغيل `flutter clean` و `flutter pub get`
3. التحقق من سجلات الأخطاء

## 👥 المساهمة

نرحب بالمساهمات! يرجى:
1. Fork المشروع
2. إنشاء branch جديد
3. Commit التغييرات
4. Push إلى branch
5. فتح Pull Request

## 📄 الترخيص

[حدد نوع الترخيص هنا]

## 📞 التواصل

- **المشروع**: Barber Booking App
- **الإصدار**: 1.0.0
- **التاريخ**: 2024

---

## ⚡ نصائح سريعة

### للمطورين
```dart
// استخدام GetIt للوصول للخدمات
final authCubit = getIt<AuthCubit>();

// التنقل بين الشاشات
Navigator.pushNamed(context, SignInView.routeName);

// استخدام Validators
validator: Validators.validateEmail,
```

### للتصميم
```dart
// استخدام الألوان
color: ColorManager.primaryColor

// استخدام أنماط النص
style: TextStyles.heading1

// استخدام المسافات المتجاوبة
SizedBox(height: 16.h)
```

---

**تم التطوير بـ ❤️ باستخدام Flutter**
