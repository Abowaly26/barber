import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/features/quti_shared/quti_shared.dart';

/// Custom Bottom Navigation Bar with SVG icons and smooth animations.
/// Inspired by pharma_now's nav bar but with a cleaner, more modern design.
class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.messagesUnreadCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int messagesUnreadCount;

  static const _items = <_NavItem>[
    _NavItem(
      svgPath: 'assets/home-02.svg',
      label: 'Home',
      fallbackIcon: Icons.home_filled,
    ),
    _NavItem(
      svgPath: null,
      label: 'Store',
      fallbackIcon: Icons.shopping_bag_outlined,
    ),
    _NavItem(
      svgPath: 'assets/calendar-favorite-01.svg',
      label: 'Bookings',
      fallbackIcon: Icons.calendar_today,
    ),
    _NavItem(
      svgPath: 'assets/message-dots-circle.svg',
      label: 'Messages',
      fallbackIcon: Icons.chat_bubble_outline,
    ),
    _NavItem(
      svgPath: 'assets/user-01.svg',
      label: 'Profile',
      fallbackIcon: Icons.person_outline,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 70.h + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.borderGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isSelected = currentIndex == index;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(index),
              child: _NavItemWidget(
                item: item,
                isSelected: isSelected,
                unreadCount: index == 3 && !isSelected
                    ? messagesUnreadCount
                    : 0,
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Data class for a navigation item
class _NavItem {
  const _NavItem({
    required this.svgPath,
    required this.label,
    required this.fallbackIcon,
  });

  final String? svgPath;
  final String label;
  final IconData fallbackIcon;
}

/// Animated widget for each nav item
class _NavItemWidget extends StatefulWidget {
  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.unreadCount,
  });

  final _NavItem item;
  final bool isSelected;
  final int unreadCount;

  @override
  State<_NavItemWidget> createState() => _NavItemWidgetState();
}

class _NavItemWidgetState extends State<_NavItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnim = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    if (widget.isSelected) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _NavItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.primary;
    const inactiveColor = AppColors.textGrey;
    final color = widget.isSelected ? primaryColor : inactiveColor;
    final showUnreadBadge = widget.unreadCount > 0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with pill background for selected state
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: widget.isSelected ? 14.w : 0,
                vertical: widget.isSelected ? 6.h : 0,
              ),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Transform.scale(
                scale: _scaleAnim.value,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      widget.item.svgPath != null
                          ? SvgPicture.asset(
                              widget.item.svgPath!,
                              width: 22.w,
                              height: 22.h,
                              colorFilter: ColorFilter.mode(
                                color,
                                BlendMode.srcIn,
                              ),
                            )
                          : Icon(
                              widget.item.fallbackIcon,
                              size: 22.w,
                              color: color,
                            ),
                      if (showUnreadBadge)
                        Positioned(
                          right: -7.w,
                          top: -7.h,
                          child: Container(
                            constraints: BoxConstraints(
                              minWidth: 15.w,
                              minHeight: 15.w,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 3.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              shape: widget.unreadCount > 9
                                  ? BoxShape.rectangle
                                  : BoxShape.circle,
                              borderRadius: widget.unreadCount > 9
                                  ? BorderRadius.circular(9.r)
                                  : null,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5.w,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              widget.unreadCount > 99
                                  ? '99+'
                                  : widget.unreadCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            // Label
            Text(
              widget.item.label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: widget.isSelected
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        );
      },
    );
  }
}
