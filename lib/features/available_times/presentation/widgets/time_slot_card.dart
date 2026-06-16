import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/utils/color_manager.dart';
import 'package:app/core/utils/text_styles.dart';

class TimeSlotCard extends StatelessWidget {
  final String date;
  final String time;
  final String status;
  final String serviceName;
  final String providerName;
  final String address;
  final VoidCallback onTap;
  final bool isAvailable;

  const TimeSlotCard({
    super.key,
    required this.date,
    required this.time,
    required this.status,
    required this.serviceName,
    required this.providerName,
    required this.address,
    required this.onTap,
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: ColorManager.cardBackgroundColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: ColorManager.shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Time Row
              Row(
                children: [
                  // Date Container
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: ColorManager.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _extractDay(date),
                          style: TextStyles.heading4.copyWith(
                            fontSize: 18.sp,
                            color: ColorManager.primaryColor,
                          ),
                        ),
                        Text(
                          _extractMonth(date),
                          style: TextStyles.labelSmall.copyWith(
                            color: ColorManager.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          time,
                          style: TextStyles.heading3.copyWith(
                            fontSize: 20.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          date,
                          style: TextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? ColorManager.successColor.withValues(alpha: 0.15)
                          : ColorManager.textHintColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? ColorManager.successColor
                                : ColorManager.textHintColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          status,
                          style: TextStyles.labelSmall.copyWith(
                            color: isAvailable
                                ? ColorManager.successColor
                                : ColorManager.textHintColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // Divider
              Divider(
                color: ColorManager.dividerColor,
                thickness: 1,
              ),
              SizedBox(height: 16.h),
              // Service and Provider Info
              Row(
                children: [
                  // Service Icon
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: ColorManager.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.content_cut,
                      size: 24.w,
                      color: ColorManager.secondaryColor,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Service Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: TextStyles.cardTitle.copyWith(
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          providerName,
                          style: TextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // Address Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18.w,
                    color: ColorManager.textSecondaryColor,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      address,
                      style: TextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
              // Book Button
              if (isAvailable) ...[
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primaryColor,
                      foregroundColor: ColorManager.whiteColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Book Now',
                      style: TextStyles.buttonMedium,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _extractDay(String date) {
    // Extract day from date format like "Jun 15, 2026"
    final parts = date.split(' ');
    if (parts.length >= 2) {
      return parts[1].replaceAll(',', '');
    }
    return date;
  }

  String _extractMonth(String date) {
    // Extract month from date format like "Jun 15, 2026"
    final parts = date.split(' ');
    if (parts.isNotEmpty) {
      return parts[0];
    }
    return '';
  }
}
