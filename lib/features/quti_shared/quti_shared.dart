// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

// --- Quti App Theme & Constants ---
class AppColors {
  static const primary = Color(0xFF438587);
  static const primaryLight = Color(0xFFF0F7F7);
  static const background = Color(0xFFF8F9FA);
  static const textDark = Color(0xFF1E1E1E);
  static const textGrey = Color(0xFF757575);
  static const borderGrey = Color(0xFFE0E0E0);
  static const successGreen = Color(0xFF4CAF50);
  static const warningOrange = Color(0xFFF5A623);
  static const dangerRed = Color(0xFFE57373);
}

// --- Reusable Shared Widgets ---
class PrimaryBottomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final String? price;
  final IconData? icon;

  const PrimaryBottomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.price,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: onPressed == null
                ? AppColors.borderGrey
                : AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (price != null) ...[
                const SizedBox(width: 8),
                Text(
                  "— $price",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildSharedBottomNav(int currentIndex) {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textGrey,
    currentIndex: currentIndex,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today),
        label: 'Bookings',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline),
        label: 'Message',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Profile',
      ),
    ],
  );
}
