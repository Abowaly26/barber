import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/utils/color_manager.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/features/available_times/presentation/widgets/time_slot_card.dart';
import 'package:app/features/main_shell/presentation/views/widgets/custom_bottom_nav.dart';

class AvailableTimesView extends StatefulWidget {
  static const String routeName = '/available-times';

  const AvailableTimesView({super.key});

  @override
  State<AvailableTimesView> createState() => _AvailableTimesViewState();
}

class _AvailableTimesViewState extends State<AvailableTimesView> {
  int _currentIndex = 2; // Bookings tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: ColorManager.whiteColor,
        boxShadow: [
          BoxShadow(
            color: ColorManager.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: ColorManager.backgroundColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20.w,
                color: ColorManager.textPrimaryColor,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Title
          Text(
            'Available Times',
            style: TextStyles.heading2,
          ),
          SizedBox(height: 8.h),
          // Subtitle
          Text(
            'Choose an open slot from your barber dashboard',
            style: TextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
          _buildFilterChips(),
          SizedBox(height: 24.h),
          // Time Slots List
          _buildTimeSlotsList(),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', true),
          SizedBox(width: 12.w),
          _buildFilterChip('Today', false),
          SizedBox(width: 12.w),
          _buildFilterChip('Tomorrow', false),
          SizedBox(width: 12.w),
          _buildFilterChip('This Week', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isSelected
            ? ColorManager.primaryColor
            : ColorManager.whiteColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isSelected
              ? ColorManager.primaryColor
              : ColorManager.borderColor,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyles.labelMedium.copyWith(
          color: isSelected
              ? ColorManager.whiteColor
              : ColorManager.textSecondaryColor,
        ),
      ),
    );
  }

  Widget _buildTimeSlotsList() {
    return Column(
      children: [
        TimeSlotCard(
          date: 'Jun 15, 2026',
          time: '10:00 AM - 11:00 AM',
          status: 'Available',
          serviceName: 'Professional Barber',
          providerName: 'Barber services',
          address: 'No address added yet',
          onTap: () {
            // Handle booking
          },
        ),
        TimeSlotCard(
          date: 'Jun 15, 2026',
          time: '2:00 PM - 3:00 PM',
          status: 'Available',
          serviceName: 'Professional Barber',
          providerName: 'Barber services',
          address: 'No address added yet',
          onTap: () {
            // Handle booking
          },
        ),
        TimeSlotCard(
          date: 'Jun 16, 2026',
          time: '11:00 AM - 12:00 PM',
          status: 'Booked',
          serviceName: 'Professional Barber',
          providerName: 'Barber services',
          address: 'No address added yet',
          onTap: () {
            // Handle booking
          },
          isAvailable: false,
        ),
        TimeSlotCard(
          date: 'Jun 16, 2026',
          time: '4:00 PM - 5:00 PM',
          status: 'Available',
          serviceName: 'Professional Barber',
          providerName: 'Barber services',
          address: 'No address added yet',
          onTap: () {
            // Handle booking
          },
        ),
      ],
    );
  }
}
