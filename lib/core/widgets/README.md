# Core Widgets

هذا المجلد يحتوي على الـ Widgets الأساسية القابلة لإعادة الاستخدام في جميع أنحاء التطبيق.

## الـ Widgets المتاحة

### 1. CustomButton

زر قابل لإعادة الاستخدام مع دعم لحالة التحميل (loading state).

#### المميزات:
- دعم حالة التحميل (loading indicator)
- دعم حالة التعطيل (disabled state)
- إمكانية إضافة أيقونات (prefix/suffix icons)
- تخصيص الألوان والأنماط
- استخدام ScreenUtil للاستجابة

#### مثال الاستخدام:

```dart
CustomButton(
  text: 'تسجيل الدخول',
  onPressed: () {
    // الإجراء عند الضغط
  },
  isLoading: false,
  prefixIcon: Icon(Icons.login),
)
```

#### المعاملات المتاحة:
- `text`: نص الزر (مطلوب)
- `onPressed`: دالة يتم تنفيذها عند الضغط (مطلوب)
- `backgroundColor`: لون الخلفية (اختياري)
- `textColor`: لون النص (اختياري)
- `textStyle`: نمط النص (اختياري)
- `prefixIcon`: أيقونة في بداية النص (اختياري)
- `suffixIcon`: أيقونة في نهاية النص (اختياري)
- `isLoading`: عرض مؤشر التحميل (افتراضي: false)
- `isDisabled`: تعطيل الزر (افتراضي: false)
- `width`: عرض الزر (اختياري)
- `height`: ارتفاع الزر (افتراضي: 56)
- `borderRadius`: نصف قطر الحواف (افتراضي: 8)
- `padding`: الحشو الداخلي (اختياري)

---

### 2. CustomTextField

حقل نص قابل لإعادة الاستخدام مع دعم للتحقق (validation).

#### المميزات:
- دعم التحقق من البيانات (validation)
- تخصيص الأيقونات (prefix/suffix icons)
- دعم أنواع الإدخال المختلفة
- تصميم متسق مع نظام الألوان
- استخدام ScreenUtil للاستجابة

#### مثال الاستخدام:

```dart
CustomTextField(
  label: 'البريد الإلكتروني',
  hint: 'أدخل بريدك الإلكتروني',
  textInputType: TextInputType.emailAddress,
  controller: emailController,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    return null;
  },
  prefixIcon: Icon(Icons.email),
)
```

#### المعاملات المتاحة:
- `label`: عنوان الحقل (مطلوب)
- `hint`: نص تلميحي (مطلوب)
- `textInputType`: نوع لوحة المفاتيح (مطلوب)
- `controller`: TextEditingController (اختياري)
- `obscureText`: إخفاء النص (افتراضي: false)
- `prefixIcon`: أيقونة في البداية (اختياري)
- `suffixIcon`: أيقونة في النهاية (اختياري)
- `validator`: دالة التحقق (اختياري)
- `onSaved`: دالة الحفظ (اختياري)
- `onChanged`: دالة التغيير (اختياري)
- `onFieldSubmitted`: دالة عند الإرسال (اختياري)
- `focusNode`: FocusNode (اختياري)
- `textInputAction`: إجراء لوحة المفاتيح (اختياري)
- `inputFormatters`: قائمة محددات الإدخال (اختياري)
- `maxLines`: عدد الأسطر الأقصى (افتراضي: 1)
- `minLines`: عدد الأسطر الأدنى (اختياري)
- `enabled`: تفعيل/تعطيل الحقل (افتراضي: true)
- `readOnly`: قراءة فقط (افتراضي: false)

---

### 3. PasswordField

حقل كلمة المرور مع إمكانية إظهار/إخفاء كلمة المرور.

#### المميزات:
- زر إظهار/إخفاء كلمة المرور تلقائياً
- يرث جميع مميزات CustomTextField
- أيقونة تبديل (visibility toggle) مدمجة
- دعم التحقق من البيانات

#### مثال الاستخدام:

```dart
PasswordField(
  label: 'كلمة المرور',
  hint: 'أدخل كلمة المرور',
  controller: passwordController,
  validator: (value) {
    if (value == null || value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  },
  prefixIcon: Icon(Icons.lock),
)
```

#### المعاملات المتاحة:
- `label`: عنوان الحقل (مطلوب)
- `hint`: نص تلميحي (مطلوب)
- `controller`: TextEditingController (اختياري)
- `validator`: دالة التحقق (اختياري)
- `onSaved`: دالة الحفظ (اختياري)
- `onChanged`: دالة التغيير (اختياري)
- `onFieldSubmitted`: دالة عند الإرسال (اختياري)
- `focusNode`: FocusNode (اختياري)
- `textInputAction`: إجراء لوحة المفاتيح (اختياري)
- `inputFormatters`: قائمة محددات الإدخال (اختياري)
- `enabled`: تفعيل/تعطيل الحقل (افتراضي: true)
- `prefixIcon`: أيقونة في البداية (اختياري)

---

## ملاحظات مهمة

1. **ColorManager**: جميع الـ Widgets تستخدم `ColorManager` لضمان التناسق في الألوان
2. **TextStyles**: جميع الـ Widgets تستخدم `TextStyles` لضمان التناسق في أنماط النصوص
3. **ScreenUtil**: جميع الأحجام والمسافات تستخدم ScreenUtil للاستجابة على جميع أحجام الشاشات
4. **Validation**: يمكن استخدام `core/utils/validators.dart` للحصول على دوال تحقق جاهزة

## الاختبارات

جميع الـ Widgets لديها اختبارات شاملة في مجلد `test/core/widgets/`:
- `custom_button_test.dart`
- `custom_text_field_test.dart`
- `password_field_test.dart`

لتشغيل الاختبارات:
```bash
flutter test test/core/widgets/
```
