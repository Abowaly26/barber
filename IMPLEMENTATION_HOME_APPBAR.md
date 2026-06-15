# تنفيذ Home AppBar - Implementation Summary

## 📋 نظرة عامة (Overview)

تم تنفيذ AppBar للصفحة الرئيسية (Home) بنفس المواصفات الموجودة في مشروع `pharma_now`، مع استدعاء بيانات المستخدم من Firebase Firestore.

## ✅ الملفات المضافة (New Files)

### 1. **ProfileProvider** 
`lib/features/profile/presentation/cubit/profile_provider.dart`

Provider لإدارة حالة بيانات المستخدم:
- جلب بيانات المستخدم من Firestore
- تحديث بيانات المستخدم
- الاستماع للتغييرات في الوقت الفعلي (Real-time updates)
- إدارة حالات التحميل والأخطاء

**الوظائف الرئيسية:**
```dart
- fetchUserProfile(String userId)      // جلب بيانات المستخدم
- updateUserProfile({...})             // تحديث بيانات المستخدم
- listenToUserProfile(String userId)   // الاستماع للتغييرات
- refreshUserProfile()                 // تحديث البيانات
- clearUser()                          // مسح البيانات عند تسجيل الخروج
```

### 2. **ProfileAvatar Widget**
`lib/core/widgets/profile_avatar.dart`

Widget قابل لإعادة الاستخدام لعرض صورة المستخدم:
- عرض صورة المستخدم من URL
- عرض الأحرف الأولى من الاسم (Initials) إذا لم تتوفر صورة
- عرض أيقونة افتراضية
- حالة التحميل (Loading state)
- إمكانية التخصيص الكامل (الحجم، الألوان، وغيرها)

**المعاملات (Parameters):**
```dart
- imageUrl          // رابط الصورة
- userName          // اسم المستخدم (لعرض الأحرف الأولى)
- radius            // نصف قطر الصورة
- showArc           // إظهار قوس حول الصورة
- showEditOverlay   // إظهار أيقونة التعديل
- isLoading         // حالة التحميل
- backgroundColor   // لون الخلفية
- textColor         // لون النص
```

### 3. **HomeAppBar Widget**
`lib/features/main_shell/presentation/views/widgets/home_appbar.dart`

AppBar للصفحة الرئيسية مع:
- صورة المستخدم (ProfileAvatar)
- رسالة ترحيب بالاسم
- أيقونة الإشعارات مع Badge للإشعارات غير المقروءة
- تصميم منحني في الأسفل
- لون الخلفية من theme التطبيق

**المميزات:**
- استدعاء بيانات المستخدم من Firestore عبر ProfileProvider
- عرض عدد الإشعارات غير المقروءة في الوقت الفعلي
- تصميم responsive باستخدام ScreenUtil

## 🔄 الملفات المعدّلة (Modified Files)

### 1. **main.dart**
```dart
// تم إضافة:
import 'package:provider/provider.dart';
import 'features/profile/presentation/cubit/profile_provider.dart';

// وإضافة MultiProvider:
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ProfileProvider()),
  ],
  child: MaterialApp(...),
)
```

### 2. **main_shell_view.dart**
```dart
// تم إضافة:
- import للـ HomeAppBar و ProfileProvider
- PreferredSize في Scaffold مع HomeAppBar للـ Home tab (index 0)
- إزالة SafeArea من _HomeTab (لأن AppBar يوفرها)
```

### 3. **pubspec.yaml**
```yaml
# تم إضافة:
provider: ^6.1.2  # لإدارة الحالة
```

## 🗂️ هيكل Firebase المطلوب (Firebase Structure)

### Collection: `users`
```json
{
  "userId": {
    "id": "userId",
    "name": "اسم المستخدم",
    "email": "user@example.com",
    "phoneNumber": "+966xxxxxxxxx",
    "photoUrl": "https://...",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

### Sub-Collection: `users/{userId}/notifications`
```json
{
  "notificationId": {
    "title": "عنوان الإشعار",
    "body": "محتوى الإشعار",
    "read": false,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "type": "booking" // أو أي نوع آخر
  }
}
```

## 🎨 التصميم (Design)

### الألوان (Colors)
- خلفية AppBar: `AppColors.primary` مع شفافية 0.9
- النص: أبيض
- Badge الإشعارات: أحمر مع نص أبيض
- ProfileAvatar background: أبيض مع شفافية 0.3

### الأبعاد (Dimensions)
- ارتفاع AppBar: `80.h`
- نصف قطر الانحناء: `35.r`
- حجم ProfileAvatar: `20.r`
- حجم أيقونة الإشعارات: `24.w`

## 📱 الاستخدام (Usage)

### 1. في أي صفحة تحتاج بيانات المستخدم:
```dart
Consumer<ProfileProvider>(
  builder: (context, provider, child) {
    final user = provider.currentUser;
    return Text(user?.name ?? 'Guest');
  },
)
```

### 2. تحديث بيانات المستخدم:
```dart
final profileProvider = context.read<ProfileProvider>();
await profileProvider.updateUserProfile(
  name: 'اسم جديد',
  phoneNumber: '+966xxxxxxxxx',
);
```

### 3. استخدام ProfileAvatar في أي مكان:
```dart
ProfileAvatar(
  imageUrl: user?.photoUrl,
  userName: user?.name,
  radius: 30,
  onTap: () {
    // Navigate to profile page
  },
)
```

## ✨ المميزات (Features)

1. **Real-time Updates**: تحديث تلقائي للبيانات عند تغييرها في Firestore
2. **Notification Badge**: عرض عدد الإشعارات غير المقروءة
3. **Responsive Design**: تصميم متجاوب مع جميع أحجام الشاشات
4. **Error Handling**: معالجة الأخطاء وإدارة حالات التحميل
5. **Reusable Components**: مكونات قابلة لإعادة الاستخدام

## 🔧 التخصيص (Customization)

يمكنك تخصيص:
- الألوان من `AppColors` في `lib/core/utils/color_manager.dart`
- النصوص والرسائل
- حجم وشكل الـ Avatar
- موضع وشكل Badge الإشعارات

## 🚀 الخطوات التالية (Next Steps)

1. إضافة صفحة Profile كاملة
2. إضافة صفحة Notifications
3. إضافة إمكانية تغيير الصورة
4. إضافة إمكانية تحرير البيانات
5. إضافة Firebase Cloud Messaging للإشعارات

## 📝 ملاحظات (Notes)

- تأكد من تهيئة Firebase في المشروع
- تأكد من وجود collection `users` في Firestore
- يجب أن يكون المستخدم مسجل دخول لعرض البيانات
- ProfileProvider يتم تهيئته تلقائياً عند بدء التطبيق

## 🐛 استكشاف الأخطاء (Troubleshooting)

### المشكلة: البيانات لا تظهر
**الحل:** تأكد من:
1. Firebase تم تهيئته بشكل صحيح
2. المستخدم مسجل دخول
3. Collection `users` موجود في Firestore
4. البيانات موجودة للمستخدم الحالي

### المشكلة: الصورة لا تظهر
**الحل:** تأكد من:
1. رابط الصورة صحيح وصالح
2. الصورة متاحة ويمكن الوصول إليها
3. permissions الصورة في Firebase Storage صحيحة

---

تم التنفيذ بنجاح ✅
