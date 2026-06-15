# 🎨 Home AppBar - دليل شامل

## 📖 المحتويات
1. [نظرة عامة](#نظرة-عامة)
2. [الملفات المضافة](#الملفات-المضافة)
3. [الملفات المعدلة](#الملفات-المعدلة)
4. [البنية التقنية](#البنية-التقنية)
5. [Firebase Structure](#firebase-structure)
6. [التصميم والألوان](#التصميم-والألوان)
7. [الاستخدام](#الاستخدام)
8. [الاختبار](#الاختبار)
9. [الأسئلة الشائعة](#الأسئلة-الشائعة)

---

## 🎯 نظرة عامة

تم تنفيذ AppBar للصفحة الرئيسية (Home) بنفس المواصفات الموجودة في مشروع `pharma_now`، مع:
- ✅ عرض صورة المستخدم من Firebase
- ✅ رسالة ترحيب مخصصة بالاسم
- ✅ Badge للإشعارات غير المقروءة
- ✅ Real-time updates من Firestore
- ✅ تصميم responsive ومتناسق

---

## 📁 الملفات المضافة

### 1️⃣ ProfileProvider
**المسار:** `lib/features/profile/presentation/cubit/profile_provider.dart`

**المسؤوليات:**
- إدارة حالة بيانات المستخدم
- جلب البيانات من Firestore
- تحديث البيانات
- Real-time synchronization
- معالجة الأخطاء وحالات التحميل

**الوظائف الرئيسية:**
```dart
class ProfileProvider with ChangeNotifier {
  UserModel? currentUser;           // بيانات المستخدم الحالي
  bool isLoading;                   // حالة التحميل
  bool isNavigatingOut;             // حالة الانتقال
  String? error;                    // رسالة الخطأ

  // جلب بيانات المستخدم
  Future<void> fetchUserProfile(String userId);
  
  // تحديث بيانات المستخدم
  Future<void> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? photoUrl,
  });
  
  // الاستماع للتغييرات
  void listenToUserProfile(String userId);
  
  // تحديث البيانات
  Future<void> refreshUserProfile();
  
  // مسح البيانات (عند تسجيل الخروج)
  void clearUser();
}
```

### 2️⃣ ProfileAvatar Widget
**المسار:** `lib/core/widgets/profile_avatar.dart`

**المميزات:**
- عرض صورة من URL
- عرض الأحرف الأولى (Initials) كبديل
- حالة تحميل مع Progress Indicator
- إمكانية التخصيص الكامل
- Edit overlay اختياري

**المعاملات:**
```dart
ProfileAvatar({
  String? imageUrl,           // رابط الصورة
  String? userName,           // الاسم (للأحرف الأولى)
  double radius = 40,         // حجم الصورة
  bool showArc = true,        // إظهار قوس حول الصورة
  bool showEditOverlay = true,// إظهار أيقونة التعديل
  bool isLoading = false,     // حالة التحميل
  VoidCallback? onTap,        // عند الضغط
  Color? backgroundColor,     // لون الخلفية
  Color? textColor,           // لون النص
})
```

**أمثلة الاستخدام:**
```dart
// مع صورة
ProfileAvatar(
  imageUrl: user.photoUrl,
  userName: user.name,
  radius: 30,
)

// مع الأحرف الأولى فقط
ProfileAvatar(
  userName: 'محمد أحمد',
  radius: 40,
  backgroundColor: Colors.blue,
  textColor: Colors.white,
)

// مع حالة تحميل
ProfileAvatar(
  userName: user.name,
  isLoading: true,
)
```

### 3️⃣ HomeAppBar Widget
**المسار:** `lib/features/main_shell/presentation/views/widgets/home_appbar.dart`

**المكونات:**
- ProfileAvatar مع بيانات المستخدم
- رسالة ترحيب ديناميكية
- Notification badge مع العدد
- تصميم منحني

**البنية:**
```
HomeAppBar
├── Container (خلفية بتصميم منحني)
│   └── SafeArea
│       └── Row
│           ├── ProfileAvatar (من ProfileProvider)
│           ├── Welcome Text (من ProfileProvider)
│           └── _NotificationsBadgeIcon
│               └── StreamBuilder (من Firestore)
```

### 4️⃣ ProfileTestHelper
**المسار:** `lib/features/profile/presentation/cubit/profile_test_helper.dart`

**الأدوات المساعدة:**
```dart
// إنشاء بيانات مستخدم اختبار
ProfileTestHelper.createTestUserDocument();

// إنشاء إشعارات
ProfileTestHelper.createTestNotifications(count: 5);

// تحديث البيانات
ProfileTestHelper.updateTestUserProfile(
  name: 'اسم جديد',
  phoneNumber: '+966xxxxxxxxx',
);

// جعل الإشعارات مقروءة
ProfileTestHelper.markAllNotificationsAsRead();

// حذف الإشعارات
ProfileTestHelper.deleteAllNotifications();

// طباعة البيانات
ProfileTestHelper.printCurrentUserData();
ProfileTestHelper.printNotificationCount();
```

---

## 🔧 الملفات المعدلة

### 1️⃣ main.dart
```dart
// تم إضافة Provider
import 'package:provider/provider.dart';
import 'features/profile/presentation/cubit/profile_provider.dart';

// في build method:
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ProfileProvider()),
  ],
  child: MaterialApp(...),
)
```

### 2️⃣ main_shell_view.dart
```dart
// تم إضافة
import 'widgets/home_appbar.dart';
import 'profile_provider.dart';

// في Scaffold:
appBar: _currentIndex == 0
    ? PreferredSize(
        preferredSize: Size.fromHeight(80.h),
        child: const HomeAppBar(),
      )
    : null,
```

### 3️⃣ pubspec.yaml
```yaml
dependencies:
  provider: ^6.1.2  # تمت إضافتها
```

---

## 🏗️ البنية التقنية

### State Management
```
ProfileProvider (ChangeNotifier)
    ↓
Consumer<ProfileProvider> في UI
    ↓
تحديث تلقائي عند تغيير البيانات
```

### Data Flow
```
Firebase Auth → ProfileProvider → Firestore
                      ↓
                  UserModel
                      ↓
              Consumer Widgets
                      ↓
                     UI
```

### Real-time Updates
```
Firestore Stream
    ↓
StreamBuilder في _NotificationsBadgeIcon
    ↓
تحديث Badge تلقائياً
```

---

## 🔥 Firebase Structure

### Collection: users
```json
{
  "userId": {
    "id": "abc123",
    "name": "محمد أحمد",
    "email": "mohamed@example.com",
    "phoneNumber": "+966500000000",
    "photoUrl": "https://example.com/photo.jpg",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

### Sub-Collection: notifications
```
users/{userId}/notifications/{notificationId}
```

```json
{
  "title": "عنوان الإشعار",
  "body": "محتوى الإشعار",
  "read": false,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "type": "booking"
}
```

### Firestore Security Rules (مقترح)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
      
      // Notifications sub-collection
      match /notifications/{notificationId} {
        allow read: if request.auth.uid == userId;
        allow write: if request.auth.uid == userId;
      }
    }
  }
}
```

---

## 🎨 التصميم والألوان

### الألوان المستخدمة
```dart
// من AppColors في quti_shared.dart
AppColors.primary           // #438587 - اللون الأساسي
AppColors.primaryLight      // #F0F7F7 - فاتح
AppColors.background        // #F8F9FA - الخلفية
AppColors.textDark          // #1E1E1E - نص داكن
AppColors.textGrey          // #757575 - نص رمادي
AppColors.borderGrey        // #E0E0E0 - حدود
AppColors.successGreen      // #4CAF50 - أخضر
```

### الأبعاد
```dart
// من ScreenUtil
80.h    // ارتفاع AppBar
35.r    // نصف قطر الانحناء
20.r    // حجم Avatar
24.w    // حجم الأيقونة
16.w    // padding أفقي
12.w    // مسافة بين العناصر
16.sp   // حجم الخط للنص
10.sp   // حجم خط Badge
```

### الشكل النهائي
```
┌────────────────────────────────────┐
│  ┌───┐  Hello, محمد        🔔(3)  │
│  │ M │                            │
│  └───┘                            │
└────────────────────────────────────┘
     ╰─────────────────────────╯
```

---

## 💻 الاستخدام

### استخدام ProfileProvider

#### 1. الحصول على البيانات
```dart
// استخدام Consumer
Consumer<ProfileProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    
    final user = provider.currentUser;
    return Text(user?.name ?? 'Guest');
  },
)

// استخدام Provider.of
final provider = Provider.of<ProfileProvider>(context);
print(provider.currentUser?.name);

// استخدام context.read (بدون rebuild)
final provider = context.read<ProfileProvider>();
await provider.fetchUserProfile(userId);

// استخدام context.watch (مع rebuild)
final user = context.watch<ProfileProvider>().currentUser;
```

#### 2. تحديث البيانات
```dart
final provider = context.read<ProfileProvider>();

// تحديث الاسم
await provider.updateUserProfile(name: 'اسم جديد');

// تحديث رقم الهاتف
await provider.updateUserProfile(phoneNumber: '+966500000000');

// تحديث الصورة
await provider.updateUserProfile(photoUrl: 'https://...');

// تحديث متعدد
await provider.updateUserProfile(
  name: 'محمد أحمد',
  phoneNumber: '+966500000000',
  photoUrl: 'https://...',
);
```

#### 3. تحديث البيانات يدوياً
```dart
final provider = context.read<ProfileProvider>();
await provider.refreshUserProfile();
```

### استخدام ProfileAvatar

#### مثال بسيط
```dart
ProfileAvatar(
  imageUrl: user.photoUrl,
  userName: user.name,
  radius: 30,
)
```

#### مثال متقدم
```dart
ProfileAvatar(
  imageUrl: user.photoUrl,
  userName: user.name,
  radius: 40,
  showEditOverlay: true,
  isLoading: isUploading,
  backgroundColor: Colors.blue,
  textColor: Colors.white,
  onTap: () {
    // Navigate to edit profile
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen()),
    );
  },
)
```

### استخدام HomeAppBar

```dart
// في Scaffold
Scaffold(
  appBar: PreferredSize(
    preferredSize: Size.fromHeight(80.h),
    child: const HomeAppBar(),
  ),
  body: ...,
)
```

---

## 🧪 الاختبار

### اختبار سريع

#### 1. إنشاء بيانات اختبار
```dart
import 'package:app/features/profile/presentation/cubit/profile_test_helper.dart';

// في أي مكان بعد تسجيل الدخول
await ProfileTestHelper.createTestUserDocument();
await ProfileTestHelper.createTestNotifications(count: 5);
```

#### 2. التحقق من البيانات
```dart
await ProfileTestHelper.printCurrentUserData();
await ProfileTestHelper.printNotificationCount();
```

### سيناريوهات الاختبار

#### السيناريو 1: عرض البيانات
✅ تسجيل دخول المستخدم  
✅ عرض الاسم في AppBar  
✅ عرض الصورة/الأحرف الأولى  
✅ عرض أيقونة الإشعارات  

#### السيناريو 2: Notification Badge
```dart
// إنشاء إشعارات
await ProfileTestHelper.createTestNotifications(count: 3);
// يجب ظهور Badge بالرقم 3

// جعل الإشعارات مقروءة
await ProfileTestHelper.markAllNotificationsAsRead();
// يجب اختفاء Badge
```

#### السيناريو 3: Real-time Updates
```dart
// تحديث الاسم من Firebase Console أو الكود
await ProfileTestHelper.updateTestUserProfile(name: 'اسم جديد');
// يجب تحديث AppBar تلقائياً بدون reload
```

---

## ❓ الأسئلة الشائعة

### Q: البيانات لا تظهر في AppBar؟
**A:** تأكد من:
1. تسجيل دخول المستخدم (`FirebaseAuth.instance.currentUser != null`)
2. وجود بيانات في Firestore (`users/{userId}`)
3. تهيئة ProfileProvider في main.dart

```dart
// تحقق من تسجيل الدخول
if (FirebaseAuth.instance.currentUser == null) {
  print('❌ User not logged in');
} else {
  // أنشئ بيانات اختبار
  await ProfileTestHelper.createTestUserDocument();
}
```

### Q: الصورة لا تظهر؟
**A:** تأكد من:
1. رابط الصورة صحيح وصالح
2. الصورة متاحة للوصول العام
3. Firebase Storage permissions صحيحة

```dart
// استخدم رابط صورة مؤقت للاختبار
await ProfileTestHelper.updateTestUserProfile(
  photoUrl: 'https://ui-avatars.com/api/?name=Test+User&size=200',
);
```

### Q: Badge الإشعارات لا يظهر؟
**A:** تأكد من:
1. وجود إشعارات غير مقروءة (`read: false`)
2. صحة path الـ sub-collection: `users/{userId}/notifications`

```dart
// أنشئ إشعارات اختبار
await ProfileTestHelper.createTestNotifications(count: 5);
```

### Q: كيف أخصص الألوان؟
**A:** عدل `AppColors` في `quti_shared.dart`:
```dart
class AppColors {
  static const primary = Color(0xFF438587); // غير هنا
  // ...
}
```

### Q: كيف أضيف وظيفة للضغط على الإشعارات؟
**A:** عدل `_NotificationsBadgeIcon` في `home_appbar.dart`:
```dart
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NotificationsScreen()),
    );
  },
  child: Badge(...),
)
```

### Q: كيف أضيف loading overlay عند التنقل؟
**A:** استخدم `setNavigatingOut`:
```dart
final provider = context.read<ProfileProvider>();
provider.setNavigatingOut(true);

// قم بالعملية
await someAsyncOperation();

provider.setNavigatingOut(false);
```

### Q: كيف أعرض رسالة خطأ؟
**A:**
```dart
Consumer<ProfileProvider>(
  builder: (context, provider, child) {
    if (provider.error != null) {
      return Text('Error: ${provider.error}');
    }
    // ...
  },
)
```

---

## 🚀 الخطوات التالية

### المميزات المقترحة:
1. ✨ صفحة Profile كاملة
2. ✨ صفحة Notifications مع Pagination
3. ✨ إمكانية تحرير الصورة والبيانات
4. ✨ Cache للصور
5. ✨ Offline support
6. ✨ Push Notifications
7. ✨ Analytics events

### التحسينات المقترحة:
1. 🔧 إضافة Unit Tests
2. 🔧 إضافة Widget Tests
3. 🔧 إضافة Integration Tests
4. 🔧 تحسين Error Handling
5. 🔧 إضافة Retry mechanism
6. 🔧 تحسين Performance

---

## 📚 المراجع

- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter ScreenUtil](https://pub.dev/packages/flutter_screenutil)

---

## 👨‍💻 المساهمة

لأي استفسارات أو مشاكل، يمكنك:
1. إنشاء Issue
2. التواصل مع فريق التطوير
3. مراجعة الملفات التوثيقية الأخرى

---

**تم بنجاح ✅**  
*نسخة 1.0.0 - 2024*
