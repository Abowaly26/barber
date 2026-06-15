import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/utils/color_manager.dart';

class TextStyles {
  TextStyles._();

  // Heading Styles
  static TextStyle heading1 = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    color: ColorManager.textPrimaryColor,
  );

  static TextStyle heading2 = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: ColorManager.textPrimaryColor,
  );

  static TextStyle heading3 = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: ColorManager.textPrimaryColor,
  );

  static TextStyle heading4 = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: ColorManager.textPrimaryColor,
  );

  // Body Text Styles
  static TextStyle bodyLarge = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 18.sp,
    fontWeight: FontWeight.normal,
    color: ColorManager.textPrimaryColor,
  );

  static TextStyle bodyMedium = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: ColorManager.textPrimaryColor,
  );

  static TextStyle bodySmall = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: ColorManager.textSecondaryColor,
  );

  // Button Text Styles
  static TextStyle buttonLarge = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: ColorManager.whiteColor,
  );

  static TextStyle buttonMedium = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: ColorManager.whiteColor,
  );

  static TextStyle buttonSmall = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: ColorManager.whiteColor,
  );

  // Label Styles
  static TextStyle labelLarge = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: ColorManager.textPrimaryColor,
  );

  static TextStyle labelMedium = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: ColorManager.textPrimaryColor,
  );

  static TextStyle labelSmall = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: ColorManager.textSecondaryColor,
  );

  // Caption & Hint Styles
  static TextStyle caption = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: ColorManager.textSecondaryColor,
  );

  static TextStyle hint = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: ColorManager.textHintColor,
  );

  // App Bar Title Style
  static TextStyle appBarTitle = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: ColorManager.textPrimaryColor,
  );

  // Card Title Style
  static TextStyle cardTitle = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: ColorManager.textPrimaryColor,
  );

  static TextStyle cardSubtitle = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: ColorManager.textSecondaryColor,
  );

  // Input Field Styles
  static TextStyle inputLabel = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: ColorManager.textPrimaryColor,
  );

  static TextStyle inputText = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: ColorManager.textPrimaryColor,
  );

  static TextStyle inputHint = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: ColorManager.textHintColor,
  );

  static TextStyle inputError = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: ColorManager.errorColor,
  );

  // Price Styles
  static TextStyle priceRegular = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: ColorManager.primaryColor,
  );

  static TextStyle priceSmall = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: ColorManager.primaryColor,
  );

  // Rating Style
  static TextStyle rating = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: ColorManager.textPrimaryColor,
  );

  // Link Style
  static TextStyle link = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: ColorManager.accentColor,
    decoration: TextDecoration.underline,
  );

  // Error Message Style
  static TextStyle errorMessage = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: ColorManager.errorColor,
  );

  // Success Message Style
  static TextStyle successMessage = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: ColorManager.successColor,
  );

  // Timestamp Style
  static TextStyle timestamp = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: ColorManager.textSecondaryColor,
  );

  // Aliases for common sizes (for backward compatibility)
  static TextStyle get bold24 => heading3;
  static TextStyle get bold18 => heading4;
  static TextStyle get bold16 => labelLarge;
  static TextStyle get medium16 =>
      buttonMedium.copyWith(color: ColorManager.textPrimaryColor);
  static TextStyle get medium14 => labelMedium;
  static TextStyle get regular16 => bodyMedium;
  static TextStyle get regular14 => bodySmall;
}
