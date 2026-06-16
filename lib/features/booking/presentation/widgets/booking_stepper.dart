import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/utils/color_manager.dart';


class BookingStep {
  final String title;
  final String subtitle;
  final IconData icon;

  const BookingStep({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class BookingStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<BookingStep> steps;

  const BookingStepper({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          return _buildStep(index, isCompleted, isCurrent);
        }),
      ),
    );
  }

  Widget _buildStep(int index, bool isCompleted, bool isCurrent) {
    return Expanded(
      child: Row(
        children: [
          if (index > 0)
            Expanded(
              child: Container(
                height: 2.h,
                color: isCompleted || isCurrent
                    ? ColorManager.primaryColor
                    : ColorManager.borderColor,
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCurrent ? 36.w : 28.w,
                height: isCurrent ? 36.w : 28.w,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? ColorManager.primaryColor
                      : isCurrent
                          ? Colors.white
                          : ColorManager.backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? ColorManager.primaryColor
                        : isCurrent
                            ? ColorManager.primaryColor
                            : ColorManager.borderColor,
                    width: isCurrent ? 2.5 : 1.5,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: ColorManager.primaryColor.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: isCompleted
                    ? Icon(Icons.check, color: Colors.white, size: 14.w)
                    : Icon(
                        steps[index].icon,
                        color: isCurrent
                            ? ColorManager.primaryColor
                            : ColorManager.textHintColor,
                        size: isCurrent ? 16.w : 13.w,
                      ),
              ),
              SizedBox(height: 4.h),
              Text(
                steps[index].title,
                style: TextStyle(
                  fontSize: isCurrent ? 10.sp : 9.sp,
                  fontWeight:
                      isCurrent ? FontWeight.w600 : FontWeight.w400,
                  color: isCompleted || isCurrent
                      ? ColorManager.primaryColor
                      : ColorManager.textHintColor,
                ),
              ),
            ],
          ),
          if (index < steps.length - 1)
            Expanded(
              child: Container(
                height: 2.h,
                color: isCompleted
                    ? ColorManager.primaryColor
                    : ColorManager.borderColor,
              ),
            ),
        ],
      ),
    );
  }
}
