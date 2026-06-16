import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/utils/color_manager.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/features/booking/data/models/booking_model.dart';
import 'package:app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:app/features/booking/presentation/widgets/booking_summary.dart';

class BookingReviewScreen extends StatefulWidget {
  static const String routeName = '/booking-review';

  const BookingReviewScreen({super.key});

  @override
  State<BookingReviewScreen> createState() => _BookingReviewScreenState();
}

class _BookingReviewScreenState extends State<BookingReviewScreen> {
  final _notesController = TextEditingController();
  PaymentMethod _selectedPayment = PaymentMethod.cash;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18.w),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Review & Confirm', style: TextStyles.appBarTitle),
        centerTitle: true,
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          if (state.selectedService == null) {
            return const Center(child: Text('No service selected'));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BookingSummary(
                        service: state.selectedService,
                        providerName: state.selectedProviderName,
                        date: state.selectedDate,
                        time: state.selectedTime,
                        address: state.address,
                        serviceFee: 5.0,
                        paymentMethod: _selectedPayment,
                      ),
                      SizedBox(height: 16.h),
                      _buildNotesSection(),
                      SizedBox(height: 16.h),
                      _buildPaymentOptions(),
                      SizedBox(height: 16.h),
                      _buildTermsSection(),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ColorManager.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: ColorManager.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.notes,
                    color: ColorManager.primaryColor,
                    size: 18.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Special Notes',
                  style: TextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              onChanged: (value) {
                context.read<BookingCubit>().setNotes(value);
              },
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorManager.textPrimaryColor,
              ),
              decoration: InputDecoration(
                hintText: 'Add any special requests...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: ColorManager.textHintColor,
                ),
                filled: true,
                fillColor: ColorManager.backgroundColor,
                contentPadding: EdgeInsets.all(14.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ColorManager.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: ColorManager.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.payment,
                    color: ColorManager.primaryColor,
                    size: 18.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Payment Method',
                  style: TextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...PaymentMethod.values.map((method) {
            final isSelected = _selectedPayment == method;
            return GestureDetector(
              onTap: () => setState(() => _selectedPayment = method),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorManager.primaryColor.withValues(alpha: 0.05)
                      : Colors.transparent,
                  border: Border(
                    top: BorderSide(color: ColorManager.dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _paymentIcon(method),
                      size: 22.w,
                      color: isSelected
                          ? ColorManager.primaryColor
                          : ColorManager.iconColor,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        _paymentLabel(method),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: ColorManager.textPrimaryColor,
                        ),
                      ),
                    ),
                    Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? ColorManager.primaryColor
                              : ColorManager.borderColor,
                          width: 2,
                        ),
                        color: isSelected
                            ? ColorManager.primaryColor
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 14.w,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: ColorManager.backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              size: 16.w, color: ColorManager.textSecondaryColor),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'By confirming, you agree to our cancellation policy. '
              'Free cancellation up to 2 hours before the appointment.',
              style: TextStyle(
                fontSize: 12.sp,
                color: ColorManager.textSecondaryColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BookingState state) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed:
              state.isConfirming ? null : () => _confirmBooking(state),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorManager.primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: ColorManager.buttonDisabledColor,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            elevation: 0,
          ),
          child: state.isConfirming
              ? SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Confirm Booking',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '— \$${_calculateTotal(state).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  double _calculateTotal(BookingState state) {
    final price = state.selectedService?.price ?? 0;
    return price + 5.0;
  }

  void _confirmBooking(BookingState state) async {
    final cubit = context.read<BookingCubit>();
    cubit.selectPaymentMethod(_selectedPayment);

    final success = await cubit.confirmBooking();
    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/booking-success',
        (route) => route.settings.name == '/bookings',
      );
    }
  }

  IconData _paymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.applePay:
        return Icons.apple;
      case PaymentMethod.googlePay:
        return Icons.payment;
    }
  }

  String _paymentLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
    }
  }
}
