import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/utils/color_manager.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/features/booking/data/models/booking_model.dart';
import 'package:app/features/booking/data/models/service_item_model.dart';

class BookingSummary extends StatelessWidget {
  final ServiceItemModel? service;
  final String? providerName;
  final DateTime? date;
  final DateTime? time;
  final String? address;
  final double? serviceFee;
  final double? discount;
  final PaymentMethod paymentMethod;

  const BookingSummary({
    super.key,
    this.service,
    this.providerName,
    this.date,
    this.time,
    this.address,
    this.serviceFee,
    this.discount,
    this.paymentMethod = PaymentMethod.cash,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ColorManager.borderColor),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildDivider(),
          if (service != null) ...[
            _buildRow(Icons.content_cut, service!.name, service!.category),
            _buildDivider(),
          ],
          if (providerName != null) ...[
            _buildRow(Icons.person_outline, 'Provider', providerName!),
            _buildDivider(),
          ],
          if (date != null && time != null) ...[
            _buildRow(
              Icons.calendar_today,
              'Date & Time',
              '${_formatDate(date!)} at ${_formatTime(time!)}',
            ),
            _buildDivider(),
          ],
          if (address != null) ...[
            _buildRow(Icons.location_on_outlined, 'Location', address!, isAddress: true),
            _buildDivider(),
          ],
          _buildPaymentRow(),
          _buildDivider(),
          _buildPriceBreakdown(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
              Icons.receipt_long,
              color: ColorManager.primaryColor,
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Booking Summary',
            style: TextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value, {bool isAddress = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.w, color: ColorManager.iconColor),
          SizedBox(width: 12.w),
          SizedBox(
            width: 70.w,
            child: Text(
              label,
              style: TextStyles.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorManager.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isAddress ? 12.sp : 13.sp,
                fontWeight: FontWeight.w500,
                color: ColorManager.textPrimaryColor,
              ),
              maxLines: isAddress ? 3 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow() {
    String label;
    IconData icon;
    switch (paymentMethod) {
      case PaymentMethod.creditCard:
        label = 'Credit Card';
        icon = Icons.credit_card;
      case PaymentMethod.cash:
        label = 'Cash';
        icon = Icons.money;
      case PaymentMethod.applePay:
        label = 'Apple Pay';
        icon = Icons.apple;
      case PaymentMethod.googlePay:
        label = 'Google Pay';
        icon = Icons.payment;
    }
    return _buildRow(icon, 'Payment', label);
  }

  Widget _buildPriceBreakdown() {
    final subtotal = service?.price ?? 0;
    final fee = serviceFee ?? 0;
    final disc = discount ?? 0;
    final total = subtotal + fee - disc;

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _priceLine('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          if (fee > 0) ...[
            SizedBox(height: 6.h),
            _priceLine('Service Fee', '\$${fee.toStringAsFixed(2)}'),
          ],
          if (disc > 0) ...[
            SizedBox(height: 6.h),
            _priceLine('Discount', '-\$${disc.toStringAsFixed(2)}',
                isDiscount: true),
          ],
          SizedBox(height: 6.h),
          const Divider(height: 1),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyles.priceRegular.copyWith(fontSize: 20.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceLine(String label, String amount, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyles.bodySmall,
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isDiscount
                ? ColorManager.successColor
                : ColorManager.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: ColorManager.dividerColor);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
