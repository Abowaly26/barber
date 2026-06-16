import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/utils/color_manager.dart';
import 'package:app/core/utils/text_styles.dart';

class TimeSlot {
  final String label;
  final DateTime time;
  final bool isAvailable;
  final bool isPeak;

  const TimeSlot({
    required this.label,
    required this.time,
    this.isAvailable = true,
    this.isPeak = false,
  });
}

class TimeSlotGrid extends StatelessWidget {
  final List<TimeSlot> slots;
  final TimeSlot? selectedSlot;
  final ValueChanged<TimeSlot>? onSlotSelected;

  const TimeSlotGrid({
    super.key,
    required this.slots,
    this.selectedSlot,
    this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: Column(
            children: [
              Icon(Icons.event_busy,
                  size: 40.w, color: ColorManager.textHintColor),
              SizedBox(height: 8.h),
              Text(
                'No time slots available',
                style: TextStyles.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: slots.map((slot) => _buildSlot(slot)).toList(),
    );
  }

  Widget _buildSlot(TimeSlot slot) {
    final isSelected = selectedSlot?.label == slot.label;
    final canSelect = slot.isAvailable;

    return SizedBox(
      width: 100.w,
      child: GestureDetector(
        onTap: canSelect ? () => onSlotSelected?.call(slot) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? ColorManager.primaryColor
                : canSelect
                    ? Colors.white
                    : ColorManager.backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? ColorManager.primaryColor
                  : canSelect
                      ? ColorManager.borderColor
                      : ColorManager.borderColor.withValues(alpha: 0.5),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: ColorManager.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                slot.label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : canSelect
                          ? ColorManager.textPrimaryColor
                          : ColorManager.textHintColor,
                ),
              ),
              SizedBox(height: 2.h),
              if (slot.isPeak)
                Text(
                  'Peak',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white70
                        : ColorManager.warningColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
