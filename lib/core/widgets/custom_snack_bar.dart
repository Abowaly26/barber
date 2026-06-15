import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/utils/color_manager.dart';

enum CustomSnackBarType { error, warning, info, success }

enum CustomSnackBarPosition { top, bottom }

OverlayEntry? _activeTopSnackBarEntry;

void _dismissTopSnackBar() {
  _activeTopSnackBarEntry?.remove();
  _activeTopSnackBarEntry = null;
}

/// Clears the top overlay snack bar (if any) and the current [ScaffoldMessenger] snack bar.
void dismissCustomSnackBar(BuildContext context) {
  _dismissTopSnackBar();
  ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
}

Color _backgroundForType(CustomSnackBarType type) {
  switch (type) {
    case CustomSnackBarType.error:
      return ColorManager.errorColor;
    case CustomSnackBarType.warning:
      return const Color(0xFFFFA726); // Orange
    case CustomSnackBarType.info:
      return ColorManager.authTealColor;
    case CustomSnackBarType.success:
      return ColorManager.successColor;
  }
}

TextStyle _textStyleForType(BuildContext context, CustomSnackBarType type) {
  return TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: ColorManager.whiteColor,
  );
}

Widget _buildSuccessIcon() {
  return Icon(Icons.check_circle, color: ColorManager.whiteColor, size: 22.w);
}

Widget _buildErrorIcon() {
  return Icon(Icons.error, color: ColorManager.whiteColor, size: 22.w);
}

Widget _buildWarningIcon() {
  return Icon(Icons.warning, color: ColorManager.whiteColor, size: 22.w);
}

Widget _buildInfoIcon() {
  return Icon(Icons.info, color: ColorManager.whiteColor, size: 22.w);
}

Widget _buildIconForType(CustomSnackBarType type) {
  switch (type) {
    case CustomSnackBarType.success:
      return _buildSuccessIcon();
    case CustomSnackBarType.error:
      return _buildErrorIcon();
    case CustomSnackBarType.warning:
      return _buildWarningIcon();
    case CustomSnackBarType.info:
      return _buildInfoIcon();
  }
}

Widget _buildMessageRow(
  String message,
  TextStyle textStyle,
  CustomSnackBarType type, {
  bool centered = true,
}) {
  return Row(
    mainAxisSize: centered ? MainAxisSize.min : MainAxisSize.max,
    children: [
      _buildIconForType(type),
      SizedBox(width: 8.w),
      Flexible(
        child: Text(message, textAlign: TextAlign.center, style: textStyle),
      ),
    ],
  );
}

void showCustomSnackBar(
  BuildContext context,
  String message, {
  CustomSnackBarType type = CustomSnackBarType.info,
  Color? backgroundColor,
  CustomSnackBarPosition position = CustomSnackBarPosition.bottom,
  int seconds = 3,
  String? actionLabel,
  VoidCallback? onActionPressed,
}) {
  assert(
    (actionLabel == null) == (onActionPressed == null),
    'actionLabel and onActionPressed must both be set or both null.',
  );

  _dismissTopSnackBar();
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  final Color bg = backgroundColor ?? _backgroundForType(type);
  final TextStyle textStyle = _textStyleForType(context, type);
  final bool hasAction = actionLabel != null && onActionPressed != null;

  if (position == CustomSnackBarPosition.top) {
    final overlay = Overlay.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: topInset + 36.h,
        left: 16.w,
        right: 16.w,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: hasAction
                ? EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h)
                : EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            constraints: hasAction ? BoxConstraints(minHeight: 44.h) : null,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10).r,
            ),
            child: hasAction
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildIconForType(type),
                      SizedBox(width: 8.w),
                      Expanded(child: Text(message, style: textStyle)),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: ColorManager.whiteColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 10.h,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          _dismissTopSnackBar();
                          onActionPressed();
                        },
                        child: Text(actionLabel),
                      ),
                      IconButton(
                        onPressed: _dismissTopSnackBar,
                        icon: Icon(
                          Icons.close,
                          color: ColorManager.whiteColor,
                          size: 22.sp,
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(
                          minWidth: 40.w,
                          minHeight: 40.h,
                        ),
                      ),
                    ],
                  )
                : Center(child: _buildMessageRow(message, textStyle, type)),
          ),
        ),
      ),
    );
    _activeTopSnackBarEntry = entry;
    overlay.insert(entry);
    Future.delayed(Duration(seconds: seconds), () {
      if (_activeTopSnackBarEntry == entry) {
        entry.remove();
        _activeTopSnackBarEntry = null;
      }
    });
    return;
  }

  final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
  final bool isKeyboardOpen = keyboardHeight > 100;
  final EdgeInsets margin = EdgeInsets.fromLTRB(
    16.w,
    0,
    16.w,
    isKeyboardOpen ? keyboardHeight * 0.7 : 32.h,
  );

  final messenger = ScaffoldMessenger.of(context);
  final controller = messenger.showSnackBar(
    SnackBar(
      padding: hasAction
          ? EdgeInsets.symmetric(horizontal: 12.w, vertical: 18.h)
          : EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      content: Center(child: _buildMessageRow(message, textStyle, type)),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      margin: margin,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10).r),
      duration: Duration(seconds: seconds),
      persist: false,
      action: hasAction
          ? SnackBarAction(
              label: actionLabel,
              textColor: ColorManager.whiteColor,
              onPressed: onActionPressed,
            )
          : null,
    ),
  );

  // Ensures auto-hide even if framework treats action snackbars as persistent.
  Future<void>.delayed(Duration(seconds: seconds), () {
    if (!context.mounted) return;
    try {
      controller.close();
    } catch (_) {
      // Snackbar was already dismissed (e.g. by navigation or a newer snackbar).
    }
  });
}

/// Shortcut for showing success message
void showSuccess(BuildContext context, String message) {
  showCustomSnackBar(
    context,
    message,
    type: CustomSnackBarType.success,
    position: CustomSnackBarPosition.bottom,
  );
}

/// Shortcut for showing error message
void showError(BuildContext context, String message) {
  showCustomSnackBar(
    context,
    message,
    type: CustomSnackBarType.error,
    position: CustomSnackBarPosition.bottom,
  );
}

/// Shortcut for showing warning message
void showWarning(BuildContext context, String message) {
  showCustomSnackBar(
    context,
    message,
    type: CustomSnackBarType.warning,
    position: CustomSnackBarPosition.bottom,
  );
}

/// Shortcut for showing info message
void showInfo(BuildContext context, String message) {
  showCustomSnackBar(
    context,
    message,
    type: CustomSnackBarType.info,
    position: CustomSnackBarPosition.bottom,
  );
}
