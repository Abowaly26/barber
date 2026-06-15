# 🎠 Banner Slider - دليل الاستخدام

## ✅ تم التنفيذ بنجاح

تم إضافة Banner Slider مع انتقالات تلقائية باستخدام الصور من مجلد assets!

---

## 📋 المميزات

- ✅ **Auto-scroll**: انتقال تلقائي كل 3 ثوانٍ
- ✅ **Manual scroll**: إمكانية التمرير اليدوي
- ✅ **Pause on touch**: توقف الانتقال عند اللمس
- ✅ **Page indicator**: مؤشر الصفحة الحالية (dots)
- ✅ **Smooth animations**: انتقالات سلسة
- ✅ **Lifecycle aware**: يتوقف عند خروج التطبيق من الشاشة
- ✅ **Error handling**: معالجة أخطاء تحميل الصور

---

## 📁 الملفات المضافة

### 1. BannerSlider Widget
**المسار:** `lib/features/main_shell/presentation/views/widgets/banner_slider.dart`

**الوظائف:**
- انتقال تلقائي بين الصور
- توقف عند اللمس
- استئناف بعد ترك اللمس
- مؤشر الصفحة الحالية

---

## 🖼️ الصور المستخدمة

الصور من مجلد `assets/`:
1. `download.jpg`
2. `download (3).jpg`
3. `removebg-preview.png`

---

## 💻 الاستخدام

### استخدام البانر في أي صفحة:

```dart
import 'package:app/features/main_shell/presentation/views/widgets/banner_slider.dart';

// في build method:
const BannerSlider()
```

### تخصيص الصور:

عدّل قائمة الصور في `banner_slider.dart`:

```dart
final List<String> _bannerImages = [
  'assets/صورة1.jpg',
  'assets/صورة2.png',
  'assets/صورة3.jpg',
];
```

---

## ⚙️ التخصيص

### 1. تغيير مدة الانتقال التلقائي:

```dart
// في _startBannerAutoScroll()
_bannerTimer = Timer.periodic(
  const Duration(seconds: 5), // غيّر من 3 إلى 5 ثوانٍ
  (timer) {
    // ...
  },
);
```

### 2. تغيير سرعة الانيميشن:

```dart
_bannerController.animateToPage(
  _currentBannerIndex,
  duration: const Duration(milliseconds: 500), // غيّر من 300
  curve: Curves.easeInOut, // أو Curves.bounceOut
);
```

### 3. تغيير ارتفاع البانر:

```dart
SizedBox(
  height: 200.h, // غيّر من 180.h
  child: PageView.builder(...),
)
```

### 4. تخصيص Page Indicator:

```dart
SmoothPageIndicator(
  controller: _bannerController,
  count: _bannerImages.length,
  effect: WormEffect(
    dotHeight: 10.h,        // حجم النقطة
    dotWidth: 10.w,         // عرض النقطة
    spacing: 12.w,          // المسافة بين النقاط
    dotColor: Colors.grey,  // لون النقاط غير النشطة
    activeDotColor: Colors.blue, // لون النقطة النشطة
  ),
)
```

### 5. تغيير شكل Page Indicator:

```dart
// بدلاً من WormEffect:

// 1. Expanding Dots
effect: ExpandingDotsEffect(
  dotHeight: 8.h,
  dotWidth: 8.w,
  activeDotColor: AppColors.primary,
),

// 2. Sliding Dots
effect: SlideEffect(
  dotHeight: 8.h,
  dotWidth: 8.w,
  activeDotColor: AppColors.primary,
),

// 3. Jumping Dots
effect: JumpingDotEffect(
  dotHeight: 8.h,
  dotWidth: 8.w,
  activeDotColor: AppColors.primary,
),
```

---

## 🎨 التصميم

### الأبعاد:
- **Height**: 180.h
- **Margin**: 16.w (horizontal)
- **Border Radius**: 16.r
- **Dot Size**: 8.h x 8.w
- **Dot Spacing**: 10.w

### الألوان:
- **Active Dot**: `AppColors.primary`
- **Inactive Dot**: `AppColors.borderGrey`
- **Shadow**: `Colors.black` (opacity 0.08)

---

## 🔧 إضافة صور جديدة

### الخطوة 1: أضف الصور إلى assets
```
assets/
├── banner1.jpg
├── banner2.png
└── banner3.jpg
```

### الخطوة 2: سجّل الصور في pubspec.yaml
```yaml
flutter:
  assets:
    - assets/
```

### الخطوة 3: حدّث قائمة الصور
```dart
final List<String> _bannerImages = [
  'assets/banner1.jpg',
  'assets/banner2.png',
  'assets/banner3.jpg',
];
```

---

## 🎯 التعامل مع Tap Events

### إضافة وظيفة عند الضغط على البانر:

```dart
InkWell(
  onTap: () {
    // الحصول على index الصورة الحالية
    final currentIndex = index;
    
    // التنقل إلى صفحة معينة حسب البانر
    if (currentIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BannerDetailsScreen1()),
      );
    } else if (currentIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BannerDetailsScreen2()),
      );
    }
    // ...
  },
  child: ...,
)
```

---

## 📱 المثال الكامل

```dart
import 'package:flutter/material.dart';
import 'package:app/features/main_shell/presentation/views/widgets/banner_slider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner Slider
            const BannerSlider(),
            
            // باقي المحتوى
            // ...
          ],
        ),
      ),
    );
  }
}
```

---

## 🐛 حل المشاكل

### المشكلة: الصور لا تظهر

**الحل:**
1. تأكد من وجود الصور في `assets/`
2. تأكد من تسجيل assets في `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/
```
3. شغّل `flutter pub get`
4. أعد تشغيل التطبيق

### المشكلة: الانتقال التلقائي لا يعمل

**الحل:**
تأكد من:
- عدد الصور > 1
- Timer يعمل بشكل صحيح
- التطبيق في foreground

### المشكلة: الانتقال لا يتوقف عند اللمس

**الحل:**
تأكد من وجود `Listener` حول `PageView`:
```dart
Listener(
  onPointerDown: (_) => _stopBannerAutoScroll(),
  onPointerUp: (_) => _startBannerAutoScroll(),
  child: PageView.builder(...),
)
```

---

## 🚀 التحسينات المستقبلية

### يمكنك إضافة:

1. **جلب الصور من Firebase Storage**
```dart
// بدلاً من assets، استخدم NetworkImage
Image.network(imageUrl)
```

2. **إضافة نصوص على البانر**
```dart
Stack(
  children: [
    Image.asset(...),
    Positioned(
      bottom: 20,
      left: 20,
      child: Text('عنوان البانر'),
    ),
  ],
)
```

3. **إضافة Shimmer Loading**
```dart
import 'package:shimmer/shimmer.dart';

Image.asset(
  imagePath,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(color: Colors.white),
    );
  },
)
```

4. **Cache للصور**
```dart
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: imageUrl,
  fit: BoxFit.cover,
)
```

---

## 📦 الحزم المستخدمة

```yaml
dependencies:
  smooth_page_indicator: ^2.0.1  # Page indicator
  flutter_screenutil: ^5.9.3     # Responsive design
```

---

## 📚 المراجع

- [smooth_page_indicator](https://pub.dev/packages/smooth_page_indicator)
- [PageView Documentation](https://api.flutter.dev/flutter/widgets/PageView-class.html)
- [Timer Documentation](https://api.flutter.dev/flutter/dart-async/Timer-class.html)

---

## ✨ الخلاصة

تم إضافة Banner Slider احترافي مع:
- ✅ انتقال تلقائي سلس
- ✅ تحكم يدوي
- ✅ مؤشر جذاب
- ✅ معالجة الأخطاء
- ✅ Lifecycle management

**جاهز للاستخدام! 🎉**

---

*آخر تحديث: 2024*  
*النسخة: 1.0.0*
