import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:app/features/quti_shared/quti_shared.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> with WidgetsBindingObserver {
  static const _fallbackImages = [
    _BannerImage(imageUrl: 'assets/download.jpg', isAsset: true),
    _BannerImage(imageUrl: 'assets/removebg-preview.png', isAsset: true),
    _BannerImage(imageUrl: 'assets/download (3).jpg', isAsset: true),
  ];

  final PageController _bannerController = PageController(initialPage: 0);
  int _currentBannerIndex = 0;
  int _bannerCount = _fallbackImages.length;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startBannerAutoScroll());
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
      _startBannerAutoScroll();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _stopBannerAutoScroll();
    }
  }

  void _syncBannerCount(int nextCount) {
    if (_bannerCount == nextCount) return;

    _bannerCount = nextCount;
    if (_currentBannerIndex >= nextCount) {
      _currentBannerIndex = 0;
      if (_bannerController.hasClients) {
        _bannerController.jumpToPage(0);
      }
    }

    _stopBannerAutoScroll();
    _startBannerAutoScroll();
  }

  void _startBannerAutoScroll() {
    if (_bannerTimer?.isActive == true || _bannerCount <= 1) return;

    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_bannerController.hasClients || _bannerCount <= 1) {
        timer.cancel();
        return;
      }

      _currentBannerIndex = (_currentBannerIndex + 1) % _bannerCount;
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
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('app_banners')
          .where('placement', isEqualTo: 'home')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        final banners = _mapBanners(snapshot.data?.docs);
        final images = banners.isEmpty ? _fallbackImages : banners;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _syncBannerCount(images.length);
        });

        if (images.isEmpty) return SizedBox(height: 220.h);

        return Column(
          children: [
            Listener(
              onPointerDown: (_) => _stopBannerAutoScroll(),
              onPointerUp: (_) => _startBannerAutoScroll(),
              onPointerCancel: (_) => _startBannerAutoScroll(),
              child: SizedBox(
                height: 180.h,
                child: PageView.builder(
                  controller: _bannerController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() => _currentBannerIndex = index);
                  },
                  itemBuilder: (context, index) => _buildBannerItem(images[index], index),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            SmoothPageIndicator(
              controller: _bannerController,
              count: images.length,
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
      },
    );
  }

  List<_BannerImage> _mapBanners(List<QueryDocumentSnapshot<Map<String, dynamic>>>? docs) {
    if (docs == null || docs.isEmpty) return const [];

    final banners = docs
        .map((doc) {
          final data = doc.data();
          final imageUrl = data['imageUrl']?.toString() ?? '';
          if (imageUrl.isEmpty) return null;

          return _BannerImage(
            imageUrl: imageUrl,
            name: data['name']?.toString(),
            tapTarget: data['tapTarget']?.toString(),
            displayOrder: _asInt(data['displayOrder']),
          );
        })
        .whereType<_BannerImage>()
        .toList();

    banners.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return banners;
  }

  Widget _buildBannerItem(_BannerImage banner, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
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
            _BannerImageView(banner: banner),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: AppColors.primary.withOpacity(0.1),
                highlightColor: AppColors.primary.withOpacity(0.05),
                onTap: () => debugPrint('Home banner tapped: ${banner.name ?? index}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerImageView extends StatelessWidget {
  const _BannerImageView({required this.banner});

  final _BannerImage banner;

  @override
  Widget build(BuildContext context) {
    if (banner.isAsset) {
      return Image.asset(
        banner.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _BannerError(),
      );
    }

    return CachedNetworkImage(
      imageUrl: banner.imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: AppColors.borderGrey.withOpacity(0.25)),
      errorWidget: (_, __, ___) => const _BannerError(),
    );
  }
}

class _BannerError extends StatelessWidget {
  const _BannerError();

  @override
  Widget build(BuildContext context) {
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
  }
}

class _BannerImage {
  const _BannerImage({
    required this.imageUrl,
    this.isAsset = false,
    this.name,
    this.tapTarget,
    this.displayOrder = 0,
  });

  final String imageUrl;
  final bool isAsset;
  final String? name;
  final String? tapTarget;
  final int displayOrder;
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
