import 'package:flutter/material.dart';

class ColorManager {
  ColorManager._();

  // Primary Colors
  static const Color primaryColor = Color(0xFF2C3E50); // Dark blue-grey
  static const Color secondaryColor = Color(0xFFE67E22); // Orange
  static const Color accentColor = Color(0xFF3498DB); // Light blue

  // Background Colors
  static const Color backgroundColor = Color(0xFFF5F6FA);
  static const Color cardBackgroundColor = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimaryColor = Color(0xFF2C3E50);
  static const Color textSecondaryColor = Color(0xFF7F8C8D);
  static const Color textHintColor = Color(0xFFBDC3C7);

  // Status Colors
  static const Color successColor = Color(0xFF27AE60);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color warningColor = Color(0xFFF39C12);
  static const Color infoColor = Color(0xFF3498DB);

  // UI Element Colors
  static const Color dividerColor = Color(0xFFECF0F1);
  static const Color borderColor = Color(0xFFDFE6E9);
  static const Color iconColor = Color(0xFF7F8C8D);
  static const Color shadowColor = Color(0x1A000000);

  // Auth Screen Colors
  static const Color authTealColor = Color(0xFF458189);

  // Special Colors
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF000000);
  static const Color transparentColor = Colors.transparent;

  // Rating Color
  static const Color ratingStarColor = Color(0xFFF39C12);

  // Shimmer Colors (for loading states)
  static const Color shimmerBaseColor = Color(0xFFE0E0E0);
  static const Color shimmerHighlightColor = Color(0xFFF5F5F5);

  // Button Colors
  static const Color buttonPrimaryColor = primaryColor;
  static const Color buttonSecondaryColor = secondaryColor;
  static const Color buttonDisabledColor = Color(0xFFBDC3C7);

  // Input Field Colors
  static const Color inputFillColor = Color(0xFFF8F9FA);
  static const Color inputBorderColor = borderColor;
  static const Color inputFocusedBorderColor = primaryColor;
  static const Color inputErrorBorderColor = errorColor;
}
