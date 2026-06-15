# دليل الاختبار - Testing Guide

## 🧪 كيفية اختبار Home AppBar

### الخطوة 1: تأكد من تسجيل الدخول

قبل اختبار الـ AppBar، تأكد من تسجيل دخول المستخدم. يمكنك استخدام:
- Firebase Authentication
- تسجيل الدخول بالبريد الإلكتروني
- تسجيل الدخول بـ Google

### الخطوة 2: إنشاء بيانات اختبار

بعد تسجيل الدخول، يمكنك إنشاء بيانات اختبار باستخدام `ProfileTestHelper`:

```dart
import 'package:app/features/profile/presentation/cubit/profile_test_helper.dart';

// في أي مكان في التطبيق، مثلاً بعد تسجيل الدخول:
await ProfileTestHelper.createTestUserDocument();
```

### الخطوة 3: إنشاء إشعارات اختبار (اختياري)

```dart
// إنشاء 5 إشعارات اختبار
await ProfileTestHelper.createTestNotifications(count: 5);
```

### الخطوة 4: التحقق من البيانات

```dart
// طباعة بيانات المستخدم الحالي
await ProfileTestHelper.printCurrentUserData();

// طباعة عدد الإشعارات
await ProfileTestHelper.printNotificationCount();
```

## 🎯 سيناريوهات الاختبار

### السيناريو 1: عرض البيانات الأساسية
1. سجل دخول المستخدم
2. انتقل إلى صفحة Home
3. تحقق من ظهور:
   - صورة المستخدم (أو الأحرف الأولى)
   - رسالة الترحيب بالاسم
   - أيقونة الإشعارات

### السيناريو 2: Notification Badge
1. أنشئ إشعارات اختبار
```dart
await ProfileTestHelper.createTestNotifications(count: 3);
```
2. تحقق من ظهور badge بالرقم 3
3. اجعل الإشعارات مقروءة:
```dart
await ProfileTestHelper.markAllNotificationsAsRead();
```
4. تحقق من اختفاء الـ badge

### السيناريو 3: تحديث البيانات
1. حدث بيانات المستخدم:
```dart
await ProfileTestHelper.updateTestUserProfile(
  name: 'اسم جديد',
  phoneNumber: '+966500000000',
);
```
2. تحقق من تحديث الاسم في الـ AppBar تلقائياً

### السيناريو 4: صورة المستخدم
1. حدث صورة المستخدم:
```dart
await ProfileTestHelper.updateTestUserProfile(
  photoUrl: 'https://example.com/photo.jpg',
);
```
2. تحقق من ظهور الصورة في الـ AppBar

## 🐛 حل المشاكل الشائعة

### المشكلة: البيانات لا تظهر

**السبب المحتمل:** 
- المستخدم غير مسجل دخول
- لا توجد بيانات في Firestore

**الحل:**
```dart
// تحقق من تسجيل الدخول
final user = FirebaseAuth.instance.currentUser;
if (user == null) {
  print('❌ User not logged in');
} else {
  print('✅ User logged in: ${user.uid}');
  
  // أنشئ بيانات المستخدم
  await ProfileTestHelper.createTestUserDocument();
}
```

### المشكلة: الصورة لا تظهر

**السبب المحتمل:**
- رابط الصورة غير صحيح
- الصورة غير متاحة

**الحل:**
```dart
// استخدم رابط صورة صالح، مثل:
await ProfileTestHelper.updateTestUserProfile(
  photoUrl: 'https://ui-avatars.com/api/?name=John+Doe&size=200',
);
```

### المشكلة: Badge الإشعارات لا يظهر

**السبب المحتمل:**
- لا توجد إشعارات غير مقروءة

**الحل:**
```dart
// أنشئ إشعارات اختبار
await ProfileTestHelper.createTestNotifications(count: 5);

// تحقق من العدد
await ProfileTestHelper.printNotificationCount();
```

## 📱 اختبار يدوي سريع

### 1. من خلال Firebase Console:

1. افتح Firebase Console
2. انتقل إلى Firestore Database
3. أنشئ collection `users`
4. أضف document بـ ID المستخدم الحالي:
```json
{
  "name": "محمد أحمد",
  "email": "mohamed@example.com",
  "phoneNumber": "+966500000000",
  "photoUrl": "https://ui-avatars.com/api/?name=محمد+أحمد",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

5. أنشئ sub-collection `notifications`:
```
users/{userId}/notifications/{notificationId}
```

6. أضف documents للإشعارات:
```json
{
  "title": "إشعار جديد",
  "body": "لديك حجز جديد",
  "read": false,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "type": "booking"
}
```

### 2. من خلال الكود:

أضف في صفحة الـ Profile أو أي صفحة أخرى:

```dart
import 'package:app/features/profile/presentation/cubit/profile_test_helper.dart';

// Button للاختبار
ElevatedButton(
  onPressed: () async {
    // إنشاء بيانات المستخدم
    await ProfileTestHelper.createTestUserDocument();
    
    // إنشاء إشعارات
    await ProfileTestHelper.createTestNotifications(count: 3);
    
    // طباعة البيانات
    await ProfileTestHelper.printCurrentUserData();
    await ProfileTestHelper.printNotificationCount();
  },
  child: Text('Create Test Data'),
),
```

## ✅ Checklist للاختبار

- [ ] المستخدم مسجل دخول
- [ ] بيانات المستخدم موجودة في Firestore
- [ ] الاسم يظهر في AppBar
- [ ] صورة المستخدم تظهر (أو الأحرف الأولى)
- [ ] Badge الإشعارات يعمل بشكل صحيح
- [ ] Real-time updates تعمل عند تغيير البيانات
- [ ] التصميم responsive على أحجام الشاشات المختلفة
- [ ] الألوان مطابقة للتصميم

## 🔧 أوامر مفيدة

```dart
// إنشاء بيانات المستخدم
ProfileTestHelper.createTestUserDocument();

// إنشاء 5 إشعارات
ProfileTestHelper.createTestNotifications(count: 5);

// تحديث اسم المستخدم
ProfileTestHelper.updateTestUserProfile(name: 'اسم جديد');

// جعل جميع الإشعارات مقروءة
ProfileTestHelper.markAllNotificationsAsRead();

// حذف جميع الإشعارات
ProfileTestHelper.deleteAllNotifications();

// طباعة بيانات المستخدم
ProfileTestHelper.printCurrentUserData();

// طباعة عدد الإشعارات
ProfileTestHelper.printNotificationCount();
```

## 📊 نتائج متوقعة

### عند تشغيل التطبيق لأول مرة:
- يجب ظهور "Hello!" إذا لم تكن هناك بيانات
- لا يظهر badge للإشعارات

### بعد إنشاء بيانات الاختبار:
- يظهر "Hello, [الاسم]"
- تظهر صورة المستخدم أو الأحرف الأولى
- يظهر badge بعدد الإشعارات غير المقروءة

### عند تحديث البيانات:
- يتم تحديث UI تلقائياً بدون الحاجة لإعادة تشغيل التطبيق

---

Happy Testing! 🎉
