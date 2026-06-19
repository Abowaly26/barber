// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:app/features/quti_shared/quti_shared.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key, this.initialTopic});

  final String? initialTopic;

  @override
  Widget build(BuildContext context) {
    final title = initialTopic ?? 'Help & Support';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.support_agent, color: Colors.white, size: 34.w),
                SizedBox(height: 14.h),
                Text(
                  'How can we help?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Find quick answers or reach our support team.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          if (initialTopic != null)
            _InfoCard(title: initialTopic!, body: _topicBody(initialTopic!))
          else ...const [
            _InfoCard(
              title: 'Booking support',
              body:
                  'Choose a barber, pick an available time, then request booking. The barber will receive your request instantly.',
            ),
            _InfoCard(
              title: 'Payments',
              body:
                  'Available payment options and receipts will appear during checkout and booking confirmation.',
            ),
            _InfoCard(
              title: 'Account help',
              body:
                  'You can update your profile details, notifications, and privacy preferences from the profile tab.',
            ),
          ],
          SizedBox(height: 12.h),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
            ),
            leading: const Icon(Icons.email_outlined, color: AppColors.primary),
            title: const Text('Contact Support'),
            subtitle: const Text('support@quti.app'),
          ),
        ],
      ),
    );
  }

  String _topicBody(String topic) {
    if (topic == 'Privacy Policy') {
      return 'We only use your profile, booking, and notification data to provide app features and improve your experience.';
    }
    if (topic == 'Terms of Service') {
      return 'By using QUTI, you agree to use bookings, store features, and messaging responsibly and according to provider availability.';
    }
    return 'More details will be available soon.';
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            body,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
