import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/utils/color_manager.dart';

class SkeletonLoader extends StatefulWidget {
  final int itemCount;

  const SkeletonLoader({super.key, this.itemCount = 3});

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.itemCount,
        (index) => _buildShimmerItem(),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(52.w, 52.w, 52.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerLine(140.w, 16.h),
                      SizedBox(height: 6.h),
                      _buildShimmerLine(100.w, 12.h),
                      SizedBox(height: 12.h),
                      _buildShimmerLine(double.infinity, 14.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox(double w, double h, double radius) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: _shimmerColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildShimmerLine(double width, double height) {
    return Container(
      width: width >= double.infinity ? null : width,
      height: height,
      decoration: BoxDecoration(
        color: _shimmerColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }

  Color get _shimmerColor {
    final value = (_animation.value + 2) / 4;
    return Color.lerp(
      ColorManager.shimmerBaseColor,
      ColorManager.shimmerHighlightColor,
      value,
    )!;
  }
}
