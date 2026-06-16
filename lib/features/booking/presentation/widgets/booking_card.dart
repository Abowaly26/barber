import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/utils/color_manager.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/features/booking/data/models/booking_model.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onCancel,
  });

  Color get _statusColor {
    switch (booking.status) {
      case BookingStatus.upcoming:
        return ColorManager.accentColor;
      case BookingStatus.completed:
        return ColorManager.successColor;
      case BookingStatus.cancelled:
        return ColorManager.errorColor;
      case BookingStatus.inProgress:
        return ColorManager.warningColor;
    }
  }

  IconData get _statusIcon {
    switch (booking.status) {
      case BookingStatus.upcoming:
        return Icons.schedule;
      case BookingStatus.completed:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.inProgress:
        return Icons.autorenew;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProviderAvatar(),
                      SizedBox(width: 12.w),
                      Expanded(child: _buildDetails()),
                      _buildStatusBadge(),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildMetaRow(),
                  if (booking.status == BookingStatus.upcoming &&
                      onCancel != null) ...[
                    SizedBox(height: 12.h),
                    _buildCancelButton(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderAvatar() {
    return Container(
      width: 52.w,
      height: 52.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorManager.primaryColor.withValues(alpha: 0.1),
        border: Border.all(color: ColorManager.borderColor, width: 1),
      ),
      child: booking.providerImageUrl != null
          ? ClipOval(
              child: Image.network(
                booking.providerImageUrl!,
                fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _buildDefaultAvatar(),
              ),
            )
          : _buildDefaultAvatar(),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Icon(
        Icons.person,
        color: ColorManager.primaryColor,
        size: 24.w,
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          booking.serviceName,
          style: TextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2.h),
        Text(
          booking.providerName,
          style: TextStyles.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon, size: 12.w, color: _statusColor),
          SizedBox(width: 4.w),
          Text(
            booking.statusLabel,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: _statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: ColorManager.backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Flexible(
            child: _buildMetaItem(Icons.calendar_today, booking.formattedDate),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: _buildMetaItem(Icons.access_time, booking.formattedTime),
          ),
          if (booking.address != null) ...[
            SizedBox(width: 12.w),
            Flexible(
              child: _buildMetaItem(
                Icons.location_on_outlined,
                booking.address!,
                isAddress: true,
              ),
            ),
          ],
          SizedBox(width: 8.w),
          Text(
            '\${booking.price.toStringAsFixed(0)}',
            style: TextStyles.priceRegular,
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text, {bool isAddress = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.w, color: ColorManager.iconColor),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            text,
            style: TextStyles.caption.copyWith(
              fontSize: isAddress ? 11.sp : 12.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onCancel,
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorManager.errorColor,
          side: BorderSide(color: ColorManager.errorColor.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 10.h),
        ),
        child: Text(
          'Cancel Booking',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
