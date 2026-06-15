import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:app/features/quti_shared/quti_shared.dart';

/// Banner slider with auto-scroll functionality
/// Uses images from assets folder
class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider>
    with WidgetsBindingObserver {
  late PageController _bannerController;
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  // Banner images from assets folder
  final List<String> _bannerImages = [
    'assets/download.jpg',
    'assets/removebg-preview.png',
    'assets/download (3).jpg', // ملاحظة: اسم بمسافة
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(initialPage: 0);
    WidgetsBinding.instance.addObserver(this);

    // Start auto-scroll after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _bannerImages.isNotEmpty) {
        _startBannerAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _stopBannerAutoScroll();
    _bannerController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) return;

    if (state == AppLifecycleState.resumed) {
      // Restart timer when app comes to foreground
      _startBannerAutoScroll();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Stop timer when app is not active
      _stopBannerAutoScroll();
    }
  }

  void _startBannerAutoScroll() {
    if (_bannerTimer?.isActive == true || _bannerImages.length <= 1) return;

    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_bannerController.hasClients) {
        timer.cancel();
        return;
      }

      _currentBannerIndex = (_currentBannerIndex + 1) % _bannerImages.length;

      _bannerController.animateToPage(
        _currentBannerIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopBannerAutoScroll() {
    _bannerTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerImages.isEmpty) {
      debugPrint('❌ BannerSlider: No images available');
      return SizedBox(height: 220.h); // نفس الارتفاع الجديد
    }

    debugPrint('✅ BannerSlider: Building with ${_bannerImages.length} images');

    return Column(
      children: [
        // Banner PageView with gesture detection
        Listener(
          onPointerDown: (_) => _stopBannerAutoScroll(),
          onPointerUp: (_) => _startBannerAutoScroll(),
          onPointerCancel: (_) => _startBannerAutoScroll(),
          child: SizedBox(
            height: 180.h,
            child: PageView.builder(
              controller: _bannerController,
              itemCount: _bannerImages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentBannerIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildBannerItem(_bannerImages[index], index);
              },
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // Page indicator
        SmoothPageIndicator(
          controller: _bannerController,
          count: _bannerImages.length,
          effect: WormEffect(
            dotHeight: 8.h,
            dotWidth: 8.w,
            spacing: 10.w,
            dotColor: AppColors.borderGrey,
            activeDotColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildBannerItem(String imagePath, int index) {
    debugPrint('🖼️ Building banner item $index: $imagePath');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // خلفية مؤقتة للتأكد من الظهور
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Banner Image
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.background,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 48.sp,
                      color: AppColors.textGrey,
                    ),
                  ),
                );
              },
            ),

            // Optional: Gradient overlay for better text visibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                ),
              ),
            ),

            // Tap interaction
            Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: AppColors.primary.withOpacity(0.1),
                highlightColor: AppColors.primary.withOpacity(0.05),
                onTap: () {
                  // Handle banner tap
                  debugPrint('Banner $index tapped');
                  // TODO: Navigate to specific screen or show details
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
