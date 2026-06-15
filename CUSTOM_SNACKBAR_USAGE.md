# Custom SnackBar Usage Guide

## Overview
تم إضافة Custom SnackBar مخصص مأخوذ من مشروع car-wash-apps مع تحسينات لعرض رسائل النجاح والخطأ بشكل احترافي.

## Features
✅ أنواع مختلفة: Success, Error, Warning, Info
✅ أيقونات مميزة لكل نوع
✅ موضعين: Top (أعلى الشاشة) أو Bottom (أسفل الشاشة)
✅ دعم الـ Actions (أزرار إضافية)
✅ تلقائي الاختفاء بعد وقت محدد
✅ تصميم responsive مع flutter_screenutil

## How to Use

### 1. Basic Usage

#### Success Message
```dart
showSuccess(context, 'Account created successfully!');
```

#### Error Message
```dart
showError(context, 'Invalid email or password');
```

#### Warning Message
```dart
showWarning(context, 'Please verify your email');
```

#### Info Message
```dart
showInfo(context, 'New update available');
```

### 2. Advanced Usage

#### Custom SnackBar with Options
```dart
showCustomSnackBar(
  context,
  'Your message here',
  type: CustomSnackBarType.success,
  position: CustomSnackBarPosition.bottom, // or .top
  seconds: 3, // Duration in seconds
  backgroundColor: Colors.blue, // Optional custom color
);
```

#### With Action Button
```dart
showCustomSnackBar(
  context,
  'File saved',
  type: CustomSnackBarType.success,
  actionLabel: 'VIEW',
  onActionPressed: () {
    // Navigate to file or do something
  },
);
```

### 3. Position Options

#### Bottom (Default)
```dart
showCustomSnackBar(
  context,
  'Message at bottom',
  position: CustomSnackBarPosition.bottom,
);
```

#### Top
```dart
showCustomSnackBar(
  context,
  'Message at top',
  position: CustomSnackBarPosition.top,
);
```

## Authentication Integration

تم دمج Custom SnackBar في شاشات المصادقة:

### Sign In Success
```dart
if (state is AuthSuccess) {
  showSuccess(context, 'Welcome back!');
  // Navigate to home...
}
```

### Sign Up Success
```dart
if (state is AuthSuccess) {
  showSuccess(context, 'Account created successfully!');
  // Navigate to home...
}
```

### Authentication Error
```dart
if (state is AuthError) {
  showError(context, state.message);
}
```

### Password Reset
```dart
if (state is PasswordResetSent) {
  showSuccess(context, 'Password reset email sent!');
}
```

## Types & Colors

| Type | Color | Icon | Use Case |
|------|-------|------|----------|
| Success | Green (#4CAF50) | ✓ check_circle | Successful operations |
| Error | Red (ColorManager.errorColor) | ⚠ error | Failed operations |
| Warning | Orange (#FFA726) | ⚠ warning | Warnings & alerts |
| Info | Teal (ColorManager.authTealColor) | ℹ info | Informational messages |

## Dismiss SnackBar Manually

```dart
dismissCustomSnackBar(context);
```

## Best Practices

### ✅ DO:
- Use Success for completed actions (login, signup, save)
- Use Error for failed operations (network errors, validation)
- Use Warning for non-critical issues (permissions, updates)
- Use Info for neutral information (tips, notifications)
- Keep messages short and clear (one sentence)
- Use appropriate duration (3 seconds for normal, 5 for important)

### ❌ DON'T:
- Don't show multiple snackbars at once (auto-dismissed)
- Don't use long messages (truncates badly)
- Don't use for critical errors (use dialog instead)
- Don't forget to check context.mounted before showing

## Example: Complete Auth Flow

```dart
BlocConsumer<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is AuthSuccess) {
      showSuccess(context, 'Welcome back!');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    } else if (state is AuthError) {
      if (!state.message.contains('cancelled')) {
        showError(context, state.message);
      }
    }
  },
  builder: (context, state) {
    // Your UI here
  },
)
```

## Customization

### Change Default Duration
```dart
showCustomSnackBar(
  context,
  'Message',
  seconds: 5, // Show for 5 seconds
);
```

### Custom Background Color
```dart
showCustomSnackBar(
  context,
  'Message',
  type: CustomSnackBarType.success,
  backgroundColor: Colors.purple,
);
```

## File Location
- Implementation: `lib/core/widgets/custom_snack_bar.dart`
- Usage: Import and call directly from any widget

```dart
import 'package:app/core/widgets/custom_snack_bar.dart';
```

## Testing Tips

1. Test with different message lengths
2. Test with keyboard open (position adjusts automatically)
3. Test rapid show/dismiss (auto-handles previous snackbar)
4. Test navigation while showing (auto-cleanup)
5. Test with RTL languages

## Comparison with Standard SnackBar

| Feature | Standard | Custom |
|---------|----------|--------|
| Icons | ❌ No | ✅ Yes |
| Types | ❌ No | ✅ 4 types |
| Top Position | ❌ No | ✅ Yes |
| Auto Icon | ❌ No | ✅ Yes |
| Design | Basic | Professional |
| Keyboard Aware | ❌ No | ✅ Yes |

## Migration from Old SnackBar

### Before:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Success'),
    backgroundColor: Colors.green,
  ),
);
```

### After:
```dart
showSuccess(context, 'Success');
```

Much simpler! 🎉
