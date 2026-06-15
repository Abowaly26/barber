// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:app/core/services/get_it_service.dart';
import 'package:app/features/quti_shared/quti_shared.dart';
import 'package:app/features/booking_type/presentation/views/booking_type_view.dart';
import 'package:app/features/womens_flow/presentation/views/womens_flow_view.dart';
import 'package:app/features/ai_flow/presentation/views/ai_flow_view.dart';
import 'package:app/features/store_flow/presentation/views/store_flow_view.dart';
import 'package:app/features/provider_flow/presentation/views/provider_flow_view.dart';
import 'package:app/features/main_shell/presentation/views/widgets/home_appbar.dart';
import 'package:app/features/main_shell/presentation/views/widgets/banner_slider.dart';
import 'package:app/features/main_shell/presentation/views/widgets/custom_bottom_nav.dart';
import 'package:app/features/profile/presentation/cubit/profile_provider.dart';
import 'package:app/features/auth/domain/repos/auth_repo.dart';
import 'package:app/features/auth/presentation/views/sign_in_view.dart';

/// MainShell - wraps all tabs with a single persistent bottom navigation bar.
/// This is the first screen after splash/login. No double nav bars.
class MainShell extends StatefulWidget {
  static const String routeName = '/main-shell';
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    _HomeTab(),
    StoreHomeScreen(embedded: true),
    _BookingsTab(),
    _MessagesTab(),
    _ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add AppBar only for Home tab (index 0)
      appBar: _currentIndex == 0
          ? PreferredSize(
              preferredSize: Size.fromHeight(80.h),
              child: const HomeAppBar(),
            )
          : null,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ============================================================
// HOME TAB - Professional Redesign
// ============================================================
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Banner Slider ──
          const BannerSlider(),
          SizedBox(height: 16.h),

          // ── Who are you booking for? ──
          _buildSectionHeader(
            title: 'Who are you booking for?',
            showSeeAll: false,
          ),
          SizedBox(height: 12.h),
          _buildBookingCards(context),
          SizedBox(height: 24.h),

          // ── Nearby Salons ──
          _buildSectionHeader(
            title: 'Nearby Salons',
            showSeeAll: true,
            onSeeAll: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SalonsListScreen()),
            ),
          ),
          SizedBox(height: 12.h),
          _buildSalonRow(context),
          SizedBox(height: 24.h),

          // ── Quick Services ──
          _buildSectionHeader(title: 'Quick Services', showSeeAll: false),
          SizedBox(height: 12.h),
          _buildQuickServices(context),
          SizedBox(height: 24.h),

          // ── Featured Packages ──
          _buildSectionHeader(
            title: 'Featured Packages',
            showSeeAll: true,
            onSeeAll: () {},
          ),
          SizedBox(height: 12.h),
          _buildPackageCard(
            icon: '✨',
            title: 'Bridal Glow Package',
            subtitle: '3 hours · 4 services',
            price: '\$199',
            accentColor: const Color(0xFFFFF3E0),
          ),
          SizedBox(height: 10.h),
          _buildPackageCard(
            icon: '🌿',
            title: 'Relax & Refresh',
            subtitle: '2 hours · 3 services',
            price: '\$129',
            accentColor: const Color(0xFFE8F5E9),
          ),
          SizedBox(height: 10.h),
          _buildPackageCard(
            icon: '✨',
            title: 'Color & Style Combo',
            subtitle: '2.5 hours · 3 services',
            price: '\$159',
            accentColor: const Color(0xFFF3E5F5),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  // ── Section Header ──
  Widget _buildSectionHeader({
    required String title,
    bool showSeeAll = false,
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        if (showSeeAll)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See All',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ── Category Chips ──
  Widget _buildCategoryChips() {
    final categories = ['Hair', 'Nails', 'Facial', 'Full Service'];
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final isFirst = index == 0;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isFirst ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isFirst ? AppColors.primary : AppColors.borderGrey,
              ),
            ),
            child: Center(
              child: Text(
                categories[index],
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isFirst ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Booking Cards (Men / Women / Kids) ──
  Widget _buildBookingCards(BuildContext context) {
    return SizedBox(
      height: 110.h,
      child: Row(
        children: [
          Expanded(
            child: _BookingCard(
              icon: '💈',
              title: 'Men',
              subtitle: 'Barbershops',
              gradient: const LinearGradient(
                colors: [Color(0xFF438587), Color(0xFF5BA3A5)],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingTypeScreen()),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _BookingCard(
              icon: '💅',
              title: 'Women',
              subtitle: 'Salons & Beauty',
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFFF06292)],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BeautyHomeScreen()),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _BookingCard(
              icon: '👦',
              title: 'Kids',
              subtitle: 'Friendly Cuts',
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kids services coming soon')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Salon Row ──
  Widget _buildSalonRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSalonCard(
            context,
            'Glow Beauty Studio',
            '4.8 (324)',
            '1.2 km',
            ['Hair', 'Nails', 'Facial'],
          ),
          SizedBox(width: 12.w),
          _buildSalonCard(context, 'Luna Salon & Spa', '4.9 (512)', '2.4 km', [
            'Full Service',
            'Spa',
          ]),
        ],
      ),
    );
  }

  Widget _buildSalonCard(
    BuildContext context,
    String name,
    String rating,
    String distance,
    List<String> tags,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SalonDetailScreen()),
      ),
      child: Container(
        width: 200.w,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.borderGrey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: const Center(
                child: Icon(Icons.store, size: 32, color: AppColors.textGrey),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$rating · $distance',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 4.w,
                    runSpacing: 4.h,
                    children: tags
                        .map(
                          (tag) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick Services ──
  Widget _buildQuickServices(BuildContext context) {
    return Column(
      children: [
        _QuickServiceTile(
          icon: Icons.content_cut,
          iconBgColor: const Color(0xFFFBE9E7),
          iconColor: Colors.deepOrangeAccent,
          title: 'Join as Provider',
          subtitle: 'Barbers & shop owners',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProviderJoinScreen()),
          ),
        ),
        SizedBox(height: 8.h),
        _QuickServiceTile(
          icon: Icons.auto_awesome,
          iconBgColor: AppColors.primaryLight,
          iconColor: AppColors.primary,
          title: 'AI Hair Advisor',
          subtitle: 'Find your perfect style',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AIAdvisorIntroScreen()),
          ),
        ),
      ],
    );
  }

  // ── Package Card ──
  Widget _buildPackageCard({
    required String icon,
    required String title,
    required String subtitle,
    required String price,
    required Color accentColor,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderGrey.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              price,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Booking Card Widget ──
class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Service Tile Widget ──
class _QuickServiceTile extends StatelessWidget {
  const _QuickServiceTile({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.borderGrey.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.w),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textGrey, size: 20.w),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PLACEHOLDER TABS (to be built out later)
// ============================================================
class _SearchTab extends StatelessWidget {
  const _SearchTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppColors.textGrey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Search',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Find salons, services, and more',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: AppColors.textGrey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'My Bookings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your upcoming appointments will appear here',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesTab extends StatelessWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.textGrey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Messages',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chat with your stylists here',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  Future<void> _signOut(BuildContext context) async {
    // Show confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && context.mounted) {
      // Sign out
      final authRepo = getIt<AuthRepo>();
      await authRepo.signOut();

      // Clear profile provider
      if (context.mounted) {
        context.read<ProfileProvider>().clearUser();

        // Navigate to sign in
        Navigator.pushNamedAndRemoveUntil(
          context,
          SignInView.routeName,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            // Profile Header
            Consumer<ProfileProvider>(
              builder: (context, provider, child) {
                final user = provider.currentUser;
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 50.r,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      child: user?.photoUrl == null
                          ? Icon(
                              Icons.person,
                              size: 50.w,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      user?.name ?? 'Guest User',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 32.h),

            // Profile Options
            _buildProfileOption(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit Profile coming soon')),
                );
              },
            ),
            _buildProfileOption(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications coming soon')),
                );
              },
            ),
            _buildProfileOption(
              icon: Icons.favorite_outline,
              title: 'Favorites',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Favorites coming soon')),
                );
              },
            ),
            _buildProfileOption(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon')),
                );
              },
            ),
            _buildProfileOption(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support coming soon')),
                );
              },
            ),
            SizedBox(height: 16.h),

            // Sign Out Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red, size: 24.w),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Colors.red,
                  size: 20.w,
                ),
                onTap: () => _signOut(context),
              ),
            ),
            SizedBox(height: 32.h),

            // App Version
            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textGrey),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.borderGrey),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 24),
        title: Text(title),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textGrey,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}
