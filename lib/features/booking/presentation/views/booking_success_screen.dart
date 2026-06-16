import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/utils/color_manager.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/features/booking/presentation/cubit/booking_cubit.dart';

class BookingSuccessScreen extends StatefulWidget {
  static const String routeName = '/booking-success';

  const BookingSuccessScreen({super.key});

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        final booking = state.lastConfirmedBooking;

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  _buildSuccessAnimation(),
                  SizedBox(height: 32.h),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        children: [
                          Text(
                            'Booking Confirmed!',
                            style: TextStyles.heading2.copyWith(
                              color: ColorManager.successColor,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Your appointment has been booked successfully',
                            style: TextStyles.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  if (booking != null) ...[
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: _buildBookingInfo(booking),
                      ),
                    ),
                  ],
                  const Spacer(),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: _buildActions(),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessAnimation() {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        width: 120.w,
        height: 120.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorManager.successColor.withValues(alpha: 0.1),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildPulseRing(),
            Icon(
              Icons.check_circle,
              size: 60.w,
              color: ColorManager.successColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseRing() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.3),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Container(
          width: 120.w * value,
          height: 120.w * value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ColorManager.successColor.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingInfo(dynamic booking) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: ColorManager.backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _infoRow(
            Icons.content_cut,
            'Service',
            booking.serviceName,
          ),
          SizedBox(height: 12.h),
          _infoRow(
            Icons.person_outline,
            'Provider',
            booking.providerName,
          ),
          SizedBox(height: 12.h),
          _infoRow(
            Icons.calendar_today,
            'Date',
            booking.formattedDate,
          ),
          SizedBox(height: 12.h),
          _infoRow(
            Icons.access_time,
            'Time',
            booking.formattedTime,
          ),
          SizedBox(height: 12.h),
          _infoRow(
            Icons.location_on_outlined,
            'Location',
            booking.address ?? 'To be confirmed',
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Paid',
                style: TextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${booking.totalPrice.toStringAsFixed(2)}',
                style: TextStyles.priceRegular.copyWith(fontSize: 20.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.w, color: ColorManager.iconColor),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: ColorManager.textSecondaryColor,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: ColorManager.textPrimaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<BookingCubit>().resetBookingFlow();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/bookings',
                  (route) => false,
                );
              },
              icon: const Icon(Icons.calendar_month, size: 18),
              label: const Text('View My Bookings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<BookingCubit>().resetBookingFlow();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              icon: const Icon(Icons.home_outlined, size: 18),
              label: const Text('Back to Home'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorManager.textPrimaryColor,
                side: BorderSide(color: ColorManager.borderColor),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
