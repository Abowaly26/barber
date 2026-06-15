// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/features/quti_shared/quti_shared.dart';
import 'package:app/features/booking_type/presentation/views/booking_type_view.dart';
import 'package:app/features/womens_flow/presentation/views/womens_flow_view.dart';
import 'package:app/features/ai_flow/presentation/views/ai_flow_view.dart';
import 'package:app/features/store_flow/presentation/views/store_flow_view.dart';
import 'package:app/features/provider_flow/presentation/views/provider_flow_view.dart';

class CategorySelectionView extends StatelessWidget {
  static const String routeName = '/category-selection';

  const CategorySelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with profile icon
              SizedBox(height: 16.h),

              // Welcome Text
              const Text(
                'Choose your experience',
                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              SizedBox(height: 8.h),
              const Text(
                'Who are you booking for?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 32.h),

              // Main Category Cards (Large colored cards)
              _buildMainCard(
                context,
                title: 'Men',
                subtitle: 'Barbershops & Grooming',
                icon: '💈',
                color: Colors.grey.shade400,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingTypeScreen()),
                ),
              ),
              SizedBox(height: 16.h),
              _buildMainCard(
                context,
                title: 'Women',
                subtitle: 'Salons & Beauty',
                icon: '💅',
                color: Colors.grey.shade300,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BeautyHomeScreen()),
                ),
              ),
              SizedBox(height: 16.h),
              _buildMainCard(
                context,
                title: 'Kids',
                subtitle: 'Fun & Friendly Cuts',
                icon: '👦',
                color: Colors.grey.shade200,
                textColor: AppColors.textDark,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kids services coming soon')),
                  );
                },
              ),
              SizedBox(height: 32.h),

              // Action Tiles
              _buildActionTile(
                icon: Icons.shopping_bag_outlined,
                iconColor: Colors.pinkAccent,
                title: 'QUTI Store',
                subtitle: 'Shop grooming products',
                bgColor: AppColors.background,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StoreHomeScreen()),
                ),
              ),
              SizedBox(height: 12.h),
              _buildActionTile(
                icon: Icons.content_cut,
                iconColor: Colors.redAccent,
                title: 'Join as Provider',
                subtitle: 'Barbers & shop owners',
                bgColor: const Color(0xFFFDF0F5),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProviderJoinScreen()),
                ),
              ),
              SizedBox(height: 12.h),
              _buildActionTile(
                icon: Icons.auto_awesome,
                iconColor: AppColors.primary,
                title: 'AI Hair Advisor',
                subtitle: 'Find your perfect style',
                bgColor: AppColors.primaryLight,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AIAdvisorIntroScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
    Color textColor = Colors.white,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 24)),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: iconColor, size: 20.w),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: AppColors.textGrey,
            size: 20.w,
          ),
        ),
      ),
    );
  }
}
