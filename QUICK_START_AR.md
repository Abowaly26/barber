# 🚀 دليل البدء السريع

## ✅ تم إضافة Home AppBar بنجاح!

### 📝 ملخص التغييرات

تم نسخ نفس الـ AppBar من مشروع `pharma_now` إلى المشروع الحالي مع:
- ✅ صورة المستخدم من Firebase
- ✅ رسالة ترحيب مخصصة
- ✅ Badge للإشعارات غير المقروءة
- ✅ تحديث تلقائي من Firestore

---

## 🎯 كيف تستخدمه؟

### 1️⃣ سجل دخول المستخدم أولاً

تأكد أن المستخدم سجل دخول في Firebase Auth.

### 2️⃣ أنشئ بيانات اختبار

```dart
import 'package:app/features/profile/presentation/cubit/profile_test_helper.dart';

// بعد تسجيل الدخول مباشرة:
await ProfileTestHelper.createTestUserDocument();
```

### 3️⃣ أنشئ إشعارات (اختياري)

```dart
// لعرض Badge الإشعارات:
await ProfileTestHelper.createTestNotifications(count: 5);
```

### 4️⃣ شغّل التطبيق

```bash
flutter run
```

---

## 📁 الملفات الجديدة

```
lib/
├── features/
│   ├── profile/presentation/cubit/
│   │   ├── profile_provider.dart         ✅ جديد
│   │   └── profile_test_helper.dart      ✅ جديد
│   └── main_shell/presentation/views/widgets/
│       └── home_appbar.dart              ✅ جديد
└── core/widgets/
    └── profile_avatar.dart               ✅ جديد
```

---

## 🔧 الملفات المعدّلة

- ✏️ `lib/main.dart` - أضفنا ProfileProvider
- ✏️ `lib/features/main_shell/presentation/views/main_shell_view.dart` - أضفنا AppBar
- ✏️ `pubspec.yaml` - أضفنا provider package

---

## 🔥 Firebase Structure

### أنشئ هذه البيانات في Firestore:

#### Collection: `users`
```
users/{userId}/
  ├── name: "اسم المستخدم"
  ├── email: "user@example.com"
  ├── phoneNumber: "+966xxxxxxxxx"
  ├── photoUrl: "https://..."
  ├── createdAt: timestamp
  └── updatedAt: timestamp
```

#### Sub-Collection: `notifications`
```
users/{userId}/notifications/{notificationId}/
  ├── title: "عنوان الإشعار"
  ├── body: "محتوى الإشعار"
  ├── read: false
  ├── createdAt: timestamp
  └── type: "booking"
```

---

## 💡 أمثلة سريعة

### مثال 1: إنشاء بيانات اختبار
```dart
// في أي مكان بعد تسجيل الدخول
await ProfileTestHelper.createTestUserDocument();
await ProfileTestHelper.createTestNotifications(count: 3);
```

### مثال 2: تحديث الاسم
```dart
await ProfileTestHelper.updateTestUserProfile(
  name: 'محمد أحمد',
);
```

### مثال 3: تحديث الصورة
```dart
await ProfileTestHelper.updateTestUserProfile(
  photoUrl: 'https://ui-avatars.com/api/?name=Ahmed&size=200',
);
```

### مثال 4: الحصول على البيانات في أي صفحة
```dart
import 'package:provider/provider.dart';
import 'package:app/features/profile/presentation/cubit/profile_provider.dart';

// في أي Widget:
Consumer<ProfileProvider>(
  builder: (context, provider, child) {
    final user = provider.currentUser;
    return Text('مرحباً ${user?.name}');
  },
)
```

---

## 🎨 الألوان المستخدمة

الألوان من `AppColors` في `quti_shared.dart`:
- **Primary:** `#438587` - اللون الأساسي للـ AppBar
- **Text:** `#FFFFFF` - أبيض للنصوص
- **Badge:** `#FF0000` - أحمر للإشعارات

---

## ⚡ اختبار سريع

### خطوة 1: تحقق من تسجيل الدخول
```dart
if (FirebaseAuth.instance.currentUser != null) {
  print('✅ User logged in');
} else {
  print('❌ User not logged in');
}
```

### خطوة 2: أنشئ بيانات اختبار
```dart
await ProfileTestHelper.createTestUserDocument();
```

### خطوة 3: شغّل التطبيق وتحقق
- ✅ يظهر الاسم في AppBar؟
- ✅ تظهر الصورة/الأحرف الأولى؟
- ✅ تظهر أيقونة الإشعارات؟

### خطوة 4: اختبار Notifications
```dart
// أنشئ 5 إشعارات
await ProfileTestHelper.createTestNotifications(count: 5);
// يجب أن يظهر Badge بالرقم 5
```

---

## 🐛 حل المشاكل

### ❌ البيانات لا تظهر؟
```dart
// جرب هذا:
await ProfileTestHelper.createTestUserDocument();
await ProfileTestHelper.printCurrentUserData();
```

### ❌ الصورة لا تظهر؟
```dart
// استخدم رابط صورة تجريبي:
await ProfileTestHelper.updateTestUserProfile(
  photoUrl: 'https://ui-avatars.com/api/?name=Test+User&size=200',
);
```

### ❌ Badge لا يظهر؟
```dart
// أنشئ إشعارات:
await ProfileTestHelper.createTestNotifications(count: 3);
```

---

## 📚 الملفات التوثيقية

للمزيد من التفاصيل، راجع:
- 📖 `HOME_APPBAR_README.md` - دليل شامل كامل
- 📖 `IMPLEMENTATION_HOME_APPBAR.md` - تفاصيل التنفيذ
- 📖 `TESTING_GUIDE.md` - دليل الاختبار التفصيلي

---

## 🎉 تهانينا!

تم تنفيذ Home AppBar بنجاح! 🚀

الآن لديك:
- ✅ AppBar احترافي مع بيانات من Firebase
- ✅ Notification badge يعمل بشكل تلقائي
- ✅ Real-time updates من Firestore
- ✅ تصميم responsive ومتناسق

---

## 🚀 الخطوات التالية

1. شغّل التطبيق وتحقق من AppBar
2. أنشئ بيانات اختبار
3. جرب تحديث البيانات من Firebase Console
4. راجع الملفات التوثيقية للمزيد

**استمتع بالتطوير! 💙**
