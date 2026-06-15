# كيفية تسجيل الخروج من التطبيق

## المشكلة
عند تشغيل التطبيق أول مرة، يدخلك مباشرة إلى الصفحة الرئيسية لأن هناك مستخدم مسجل دخول بالفعل من Firebase.

## الحلول

### الحل 1: استخدام زر Sign Out من التطبيق ✅ (الموصى به)

1. شغل التطبيق
2. اذهب إلى تاب **Profile** (الأيقونة الأخيرة في الـ Bottom Navigation)
3. اضغط على زر **Sign Out** (الزر الأحمر)
4. أكد تسجيل الخروج
5. ✅ سيتم توجيهك لشاشة Sign In

### الحل 2: مسح بيانات التطبيق من الجهاز

#### Android:
```
Settings → Apps → Your App → Storage → Clear Data
```

#### iOS:
```
Settings → General → iPhone Storage → Your App → Delete App
```

#### Windows (Debug):
```powershell
# احذف مجلد البيانات المحلية
Remove-Item -Recurse -Force "$env:LOCALAPPDATA\your_app_name"
```

### الحل 3: تسجيل الخروج من Firebase Console

1. افتح Firebase Console
2. اذهب إلى Authentication
3. اذهب إلى Users
4. احذف المستخدم الموجود

### الحل 4: تسجيل الخروج من الكود (للتطوير فقط)

يمكنك إضافة هذا الكود مؤقتاً في `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // 👇 أضف هذا السطر للتطوير فقط
  await FirebaseAuth.instance.signOut();
  
  await SupabaseStorageService.initSupabase();
  setupGetIt();
  runApp(const BarberBookingApp());
}
```

⚠️ **تذكر**: احذف هذا السطر بعد الاختبار!

## تم إضافة صفحة Profile كاملة

الآن عندما تذهب إلى تاب Profile ستجد:
- ✅ صورة واسم المستخدم
- ✅ البريد الإلكتروني
- ✅ خيارات Profile (Edit, Notifications, Favorites, Settings, Help)
- ✅ زر Sign Out باللون الأحمر

## تدفق تسجيل الخروج

```
User clicks "Sign Out" → Confirmation Dialog
  ↓
User confirms → Sign out from Firebase
  ↓
Clear ProfileProvider data
  ↓
Navigate to SignInView
```

الآن جرب:
1. شغل التطبيق → سيدخلك Home مباشرة
2. اذهب لـ Profile tab
3. اضغط Sign Out
4. أكد تسجيل الخروج
5. ✅ يجب أن تظهر شاشة Sign In
6. سجل دخول بـ Google مرة أخرى
7. ✅ يجب أن تظهر بياناتك في Home AppBar
