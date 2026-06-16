// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:app/features/chat/presentation/views/chat_room_view.dart';
import 'package:app/features/chat/presentation/views/chats_list_view.dart';

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
    ChatsListView(),
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
      // Add AppBar for Home tab (index 0) and Bookings tab (index 2)
      appBar: _currentIndex == 0
          ? PreferredSize(
              preferredSize: Size.fromHeight(80.h),
              child: const HomeAppBar(),
            )
          : _currentIndex == 2
          ? AppBar(
              title: const Text('Bookings'),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: AppColors.textDark,
              automaticallyImplyLeading: false,
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE0E0E0),
                ),
              ),
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

class _BookingsTab extends StatefulWidget {
  const _BookingsTab();

  @override
  State<_BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<_BookingsTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, Future<Map<String, dynamic>>> _barberCache = {};

  DateTime _selectedDate = DateTime.now();
  String? _selectedBarberId;
  String? _selectedBarberName;
  Map<String, dynamic>? _selectedSlot;
  bool _isConfirming = false;

  Stream<QuerySnapshot>? _barbersStream;
  Stream<QuerySnapshot>? _slotsStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _myBookingsStream;

  @override
  void initState() {
    super.initState();
    _barbersStream = _firestore
        .collection('users')
        .where('role', isEqualTo: 'barber')
        .snapshots();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _myBookingsStream = _firestore
          .collection('appointments')
          .where('customerId', isEqualTo: currentUser.uid)
          .snapshots();
    }
  }

  void _updateSlotsStream() {
    if (_selectedBarberId != null) {
      _slotsStream = _firestore
          .collection('appointments')
          .where('barberId', isEqualTo: _selectedBarberId)
          .where('status', isEqualTo: 'available')
          .snapshots();
    } else {
      _slotsStream = null;
    }
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return 'Not scheduled';
    try {
      final date = DateTime.parse(value);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return value.split('T').first;
    }
  }

  String _formatTime(String? value) {
    if (value == null || value.isEmpty) return '--:--';
    try {
      final date = DateTime.parse(value);
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (_) {
      final parts = value.split('T');
      return parts.length > 1 ? parts[1].substring(0, 5) : value;
    }
  }

  Future<Map<String, dynamic>> _getBarber(String? barberId) {
    if (barberId == null || barberId.isEmpty) return Future.value({});
    return _barberCache.putIfAbsent(barberId, () async {
      final doc = await _firestore.collection('users').doc(barberId).get();
      return doc.data() ?? {};
    });
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortedDocs(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final docs = snapshot.docs.toList();
    docs.sort((a, b) {
      final aTime = a.data()['dateTime'] ?? '';
      final bTime = b.data()['dateTime'] ?? '';
      return aTime.toString().compareTo(bTime.toString());
    });
    return docs;
  }

  String _bookingStatusLabel(dynamic status) {
    final statusStr = status?.toString().toLowerCase() ?? '';
    switch (statusStr) {
      case 'available':
        return 'Available';
      case 'pending':
        return 'Pending';
      case 'confirmed':
      case 'booked':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Widget _buildSectionTitle(String title, String? subtitle) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4.w,
            height: subtitle != null ? 40.h : 24.h,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.6)],
              ),
              borderRadius: BorderRadius.circular(2.r),
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
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Generate next 14 days
    final dates = List.generate(
      14,
      (i) => DateTime.now().add(Duration(days: i)),
    );
    final currentMonth =
        '${months[_selectedDate.month - 1]} ${_selectedDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Choose Date', currentMonth),
        SizedBox(
          height: 90.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected =
                  date.year == _selectedDate.year &&
                  date.month == _selectedDate.month &&
                  date.day == _selectedDate.day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    _selectedSlot = null; // reset slot when date changes
                  });
                },
                child: Container(
                  width: 70.w,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderGrey.withOpacity(0.5),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        days[date.weekday - 1],
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : AppColors.textGrey,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBarbersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Available Barbers',
          'Choose your personal care expert',
        ),
        StreamBuilder<QuerySnapshot>(
          stream: _barbersStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'No barbers available',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              );
            }

            final barbers = snapshot.data!.docs;

            return SizedBox(
              height: 140.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: barbers.length,
                itemBuilder: (context, index) {
                  final barberDoc = barbers[index];
                  final barberData = barberDoc.data() as Map<String, dynamic>;
                  final barberId = barberDoc.id;
                  final isSelected = _selectedBarberId == barberId;

                  final rating = barberData['rating']?.toString() ?? '4.9';
                  final experience =
                      barberData['experience']?.toString() ?? '5 years';
                  final specialty =
                      barberData['specialty'] ?? 'Hair & Beard Expert';
                  final name = barberData['name'] ?? 'Professional Barber';

                  final address =
                      barberData['address'] as String? ??
                      barberData['location'] as String? ??
                      barberData['salonAddress'] as String? ??
                      barberData['fullAddress'] as String? ??
                      barberData['shopAddress'] as String? ??
                      barberData['workplace'] as String? ??
                      barberData['addressLine'] as String? ??
                      barberData['street'] as String? ??
                      barberData['area'] as String? ??
                      '';
                  final photoUrl = barberData['photoUrl'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedBarberId = barberId;
                        _selectedBarberName = name;
                        _selectedSlot = null; // reset slot when barber changes
                        _updateSlotsStream();
                      });
                    },
                    child: Container(
                      width: 280.w, // Fixed width for horizontal cards
                      margin: EdgeInsets.only(right: 12.w),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.borderGrey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  'Available',
                                  style: TextStyle(
                                    color: const Color(0xFF4CAF50),
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 26.r,
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.1,
                                ),
                                backgroundImage: photoUrl != null
                                    ? NetworkImage(photoUrl)
                                    : null,
                                child: photoUrl == null
                                    ? Icon(
                                        Icons.person,
                                        color: AppColors.primary,
                                      )
                                    : null,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textDark,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          color: AppColors.primary,
                                          size: 14.w,
                                        ),
                                        SizedBox(width: 4.w),
                                        Expanded(
                                          child: Text(
                                            address.isNotEmpty
                                                ? address
                                                : 'العنوان غير متوفر',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: address.isNotEmpty
                                                  ? AppColors.textDark
                                                  : AppColors.textGrey
                                                        .withOpacity(0.6),
                                              fontWeight: FontWeight.w600,
                                              height: 1.2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeSlots() {
    if (_selectedBarberId == null) return const SizedBox.shrink();

    // The date string format to match appointments (YYYY-MM-DD)
    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Available Times', null),
        StreamBuilder<QuerySnapshot>(
          stream: _slotsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Filter client-side by date
            final allSlots = snapshot.hasData
                ? snapshot.data!.docs
                : <QueryDocumentSnapshot>[];
            final slots = allSlots.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final dt = data['dateTime']?.toString() ?? '';

              // Try multiple date format matching strategies
              if (dt.startsWith(dateStr)) return true;

              // Try parsing the date and comparing
              try {
                final slotDate = DateTime.parse(dt);
                final slotDateStr =
                    '${slotDate.year}-${slotDate.month.toString().padLeft(2, '0')}-${slotDate.day.toString().padLeft(2, '0')}';
                return slotDateStr == dateStr;
              } catch (e) {
                return false;
              }
            }).toList();

            // Sort slots by time
            slots.sort((a, b) {
              final aTime =
                  (a.data() as Map<String, dynamic>)['dateTime'] ?? '';
              final bTime =
                  (b.data() as Map<String, dynamic>)['dateTime'] ?? '';
              return aTime.toString().compareTo(bTime.toString());
            });

            if (slots.isEmpty) {
              // If no slots for selected date, show all available slots with a message
              if (allSlots.isNotEmpty) {
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16.w,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'No slots for $dateStr. Showing all available dates:',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Show all slots instead of filtering by date
                    _buildSlotsGrid(allSlots, dateStr),
                  ],
                );
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 48.w,
                      color: AppColors.textGrey.withOpacity(0.5),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'No available times for this date.',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Try selecting a different date',
                      style: TextStyle(
                        color: AppColors.textGrey.withOpacity(0.7),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              );
            }

            return _buildSlotsGrid(slots, dateStr);
          },
        ),
      ],
    );
  }

  Widget _buildSlotsGrid(
    List<QueryDocumentSnapshot> slotsList,
    String dateStr,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: slotsList.length,
      itemBuilder: (context, index) {
        final slotDoc = slotsList[index];
        final slotData = slotDoc.data() as Map<String, dynamic>;
        slotData['id'] = slotDoc.id;

        final isSelected = _selectedSlot?['id'] == slotDoc.id;
        final timeStr = _formatTime(slotData['dateTime']);

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSlot = slotData;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.borderGrey.withOpacity(0.4),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            alignment: Alignment.center,
            child: Text(
              timeStr,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleCancelBooking(Map<String, dynamic> booking) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.dangerRed),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final bookingId = booking['id'] as String?;
      final barberId = booking['barberId'] as String?;
      if (bookingId == null || barberId == null) return;

      final dateStr = _formatDate(booking['dateTime']);
      final timeStr = _formatTime(booking['dateTime']);

      await _firestore.collection('appointments').doc(bookingId).update({
        'status': 'cancelled',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      final userProfile = context.read<ProfileProvider>().currentUser;
      final customerName =
          userProfile?.name ?? currentUser.displayName ?? 'Customer';
      final chatId = '${currentUser.uid}_$barberId';
      final timestamp = FieldValue.serverTimestamp();
      final cancellationMessage =
          '❌ تم إلغاء الحجز المعاد: $dateStr الساعة $timeStr';

      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'customerId': currentUser.uid,
        'customerName': customerName,
        'barberId': barberId,
        'barberName': booking['barberName'] ?? 'Your Barber',
        'lastMessage': cancellationMessage,
        'lastMessageTime': timestamp,
        'unreadByBarber': FieldValue.increment(1),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
            'senderId': 'system',
            'senderName': 'System',
            'message': cancellationMessage,
            'timestamp': timestamp,
            'type': 'system_cancellation',
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إلغاء الحجز بنجاح'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel booking: $e'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  Future<void> _handleConfirmBooking() async {
    if (_selectedSlot == null) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to book appointments.')),
      );
      return;
    }

    setState(() => _isConfirming = true);

    try {
      final userProfile = context.read<ProfileProvider>().currentUser;
      final customerName =
          userProfile?.name ?? currentUser.displayName ?? 'App User';

      await _firestore
          .collection('appointments')
          .doc(_selectedSlot!['id'])
          .update({
            'status': 'pending',
            'customerId': currentUser.uid,
            'customerName': customerName,
            'customerPhone': '',
            'serviceName': 'App Booking',
            'price': 0,
            'updatedAt': DateTime.now().toIso8601String(),
          });

      final slotWithId = Map<String, dynamic>.from(_selectedSlot!);
      final barberId = _selectedBarberId ?? '';

      // Send automated message
      final dateStr = _formatDate(slotWithId['dateTime']);
      final timeStr = _formatTime(slotWithId['dateTime']);
      final messageText = 'أرغب في تأكيد حجز يوم $dateStr الساعة $timeStr';
      final chatId = '${currentUser.uid}_$barberId';
      final timestamp = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'customerId': currentUser.uid,
        'customerName': customerName,
        'barberId': barberId,
        'barberName': _selectedBarberName ?? 'Your Barber',
        'lastMessage': messageText,
        'lastMessageTime': timestamp,
        'unreadByBarber': FieldValue.increment(1),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
            'senderId': currentUser.uid,
            'senderName': customerName,
            'message': messageText,
            'timestamp': timestamp,
            'type': 'text',
          });

      if (mounted) {
        Navigator.pushNamed(
          context,
          ChatRoomView.routeName,
          arguments: {
            'barberId': barberId,
            'barberName': _selectedBarberName ?? 'Your Barber',
          },
        );
      }

      setState(() {
        _selectedSlot = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to request booking: $e')));
    } finally {
      if (mounted) {
        setState(() => _isConfirming = false);
      }
    }
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: ElevatedButton(
        onPressed: _selectedSlot == null || _isConfirming
            ? null
            : _handleConfirmBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
          minimumSize: Size(double.infinity, 56.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: _selectedSlot != null ? 8 : 0,
          shadowColor: AppColors.primary.withOpacity(0.5),
        ),
        child: _isConfirming
            ? SizedBox(
                height: 24.w,
                width: 24.w,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Request Booking',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildStatusPill(String label, {bool filled = false}) {
    Color bgColor;
    Color textColor;

    switch (label.toLowerCase()) {
      case 'available':
        bgColor = filled ? AppColors.primary : AppColors.primaryLight;
        textColor = filled ? Colors.white : AppColors.primary;
        break;
      case 'pending':
        bgColor = filled ? const Color(0xFFFFA000) : const Color(0xFFFFF8E1);
        textColor = filled ? Colors.white : const Color(0xFFFFA000);
        break;
      case 'confirmed':
      case 'booked':
        bgColor = filled ? const Color(0xFF4CAF50) : const Color(0xFFE8F5E9);
        textColor = filled ? Colors.white : const Color(0xFF4CAF50);
        break;
      case 'completed':
        bgColor = filled ? const Color(0xFF9E9E9E) : const Color(0xFFF5F5F5);
        textColor = filled ? Colors.white : const Color(0xFF9E9E9E);
        break;
      case 'cancelled':
        bgColor = filled ? AppColors.dangerRed : const Color(0xFFFFEBEE);
        textColor = filled ? Colors.white : AppColors.dangerRed;
        break;
      default:
        bgColor = filled ? AppColors.textGrey : const Color(0xFFF5F5F5);
        textColor = filled ? Colors.white : AppColors.textGrey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final statusLabel = _bookingStatusLabel(booking['status']);
    final status = booking['status']?.toString().toLowerCase() ?? '';
    final isPending = status == 'pending';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderGrey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryLight,
                      AppColors.primaryLight.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.primary,
                  size: 22.w,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            booking['serviceName'] ?? 'Confirmed Booking',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        _buildStatusPill(statusLabel, filled: true),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFB),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: AppColors.primary,
                            size: 14.w,
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              '${_formatDate(booking['dateTime'])} • ${_formatTime(booking['dateTime'])}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isPending) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleCancelBooking(booking),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dangerRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Cancel Booking',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoState({
    required IconData icon,
    required String title,
    required String message,
    Color? color,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 60.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: (color ?? AppColors.primary).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40.w,
                color: (color ?? AppColors.primary).withOpacity(0.6),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: color ?? AppColors.textDark,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textGrey,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyBookings() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'My Bookings',
          'Your upcoming and confirmed appointments',
        ),
        if (currentUser == null)
          _buildInfoState(
            icon: Icons.lock_outline_rounded,
            title: 'Sign in required',
            message: 'Sign in to view and manage your bookings.',
          )
        else
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _myBookingsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                  ),
                );
              }

              final bookings = snapshot.hasData
                  ? _sortedDocs(snapshot.data!)
                  : [];
              if (bookings.isEmpty) {
                return _buildInfoState(
                  icon: Icons.event_busy_rounded,
                  title: 'No bookings yet',
                  message:
                      'Confirmed bookings will show here once you reserve a time.',
                );
              }

              return Column(
                children: [
                  ...bookings
                      .map((doc) => _buildBookingCard(doc.data()))
                      .toList(),
                  SizedBox(height: 40.h),
                ],
              );
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAFBFC),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBarbersList(),
              if (_selectedBarberId != null) _buildDateSelector(),
              if (_selectedBarberId != null) _buildTimeSlots(),
              if (_selectedBarberId != null) _buildConfirmButton(),
              _buildMyBookings(),
            ],
          ),
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
