import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/utils/color_manager.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/features/booking/data/models/service_item_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceItemModel service;
  final VoidCallback? onTap;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(),
                  SizedBox(width: 14.w),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 72.w,
      height: 72.w,
      decoration: BoxDecoration(
        color: ColorManager.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: service.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Image.network(
                service.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildImageFallback(),
              ),
            )
          : _buildImageFallback(),
    );
  }

  Widget _buildImageFallback() {
    return Center(
      child: Icon(
        Icons.content_cut,
        color: ColorManager.primaryColor,
        size: 28.w,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                service.name,
                style: TextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (service.isPopular)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: ColorManager.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'Popular',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.warningColor,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          service.description,
          style: TextStyles.caption,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildRating(),
            SizedBox(width: 8.w),
            _buildDuration(),
            const Spacer(),
            _buildPrice(),
          ],
        ),
      ],
    );
  }

  Widget _buildRating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, size: 14.w, color: ColorManager.ratingStarColor),
        SizedBox(width: 2.w),
        Text(
          service.rating.toStringAsFixed(1),
          style: TextStyles.rating.copyWith(fontSize: 12.sp),
        ),
        SizedBox(width: 2.w),
        Text(
          '(${service.reviewCount})',
          style: TextStyles.caption.copyWith(fontSize: 10.sp),
        ),
      ],
    );
  }

  Widget _buildDuration() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.access_time, size: 13.w, color: ColorManager.iconColor),
        SizedBox(width: 2.w),
        Text(
          '${service.durationMinutes} min',
          style: TextStyles.caption.copyWith(fontSize: 11.sp),
        ),
      ],
    );
  }

  Widget _buildPrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$${service.price.toStringAsFixed(0)}',
          style: TextStyles.priceRegular.copyWith(fontSize: 16.sp),
        ),
        if (service.originalPrice != null)
          Text(
            '\$${service.originalPrice!.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 11.sp,
              color: ColorManager.textSecondaryColor,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}
