import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/utils/color_manager.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/features/booking/data/models/booking_model.dart';
import 'package:app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:app/features/booking/presentation/widgets/booking_card.dart';
import 'package:app/features/booking/presentation/widgets/empty_booking_state.dart';
import 'package:app/features/booking/presentation/widgets/skeleton_loader.dart';

class BookingHomeScreen extends StatefulWidget {
  static const String routeName = '/bookings';

  const BookingHomeScreen({super.key});

  @override
  State<BookingHomeScreen> createState() => _BookingHomeScreenState();
}

class _BookingHomeScreenState extends State<BookingHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<BookingCubit>().initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.backgroundColor,
      appBar: _buildAppBar(),
      body: BlocBuilder<BookingCubit, BookingState>(
        buildWhen: (previous, current) {
          // Force rebuild when bookings list changes
          print(
            '🔵 buildWhen: previous bookings: ${previous.bookings.length}, current: ${current.bookings.length}',
          );
          final hasChanged =
              previous.bookings.length != current.bookings.length ||
              previous.bookings != current.bookings;
          print('🔵 buildWhen result: $hasChanged');
          return hasChanged || previous.isLoading != current.isLoading;
        },
        builder: (context, state) {
          print(
            '🟣 BlocBuilder rebuilding with ${state.bookings.length} bookings',
          );
          if (state.isLoading) {
            return const SkeletonLoader();
          }
          return Column(
            children: [
              _buildStatsRow(state),
              _buildTabBar(),
              Expanded(child: _buildTabContent(state)),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: true,
      title: Text('My Bookings', style: TextStyles.appBarTitle),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz),
          color: ColorManager.textPrimaryColor,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildStatsRow(BookingState state) {
    final upcomingCount = state.bookings
        .where((b) => b.status == BookingStatus.upcoming)
        .length;
    final completedCount = state.bookings
        .where((b) => b.status == BookingStatus.completed)
        .length;
    final cancelledCount = state.bookings
        .where((b) => b.status == BookingStatus.cancelled)
        .length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      color: Colors.white,
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.schedule,
            label: 'Upcoming',
            count: upcomingCount,
            color: ColorManager.accentColor,
          ),
          SizedBox(width: 10.w),
          _buildStatCard(
            icon: Icons.check_circle,
            label: 'Completed',
            count: completedCount,
            color: ColorManager.successColor,
          ),
          SizedBox(width: 10.w),
          _buildStatCard(
            icon: Icons.cancel,
            label: 'Cancelled',
            count: cancelledCount,
            color: ColorManager.errorColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20.w, color: color),
            SizedBox(height: 4.h),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: ColorManager.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: ColorManager.primaryColor,
        unselectedLabelColor: ColorManager.textSecondaryColor,
        indicatorColor: ColorManager.primaryColor,
        indicatorWeight: 3,
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Upcoming'),
          Tab(text: 'Completed'),
          Tab(text: 'Cancelled'),
        ],
      ),
    );
  }

  Widget _buildTabContent(BookingState state) {
    // Add key based on bookings to force rebuild
    final upcomingCount = state.bookings
        .where((b) => b.status == BookingStatus.upcoming)
        .length;
    final completedCount = state.bookings
        .where((b) => b.status == BookingStatus.completed)
        .length;
    final cancelledCount = state.bookings
        .where((b) => b.status == BookingStatus.cancelled)
        .length;

    print(
      '🟡 _buildTabContent: Upcoming: $upcomingCount, Completed: $completedCount, Cancelled: $cancelledCount',
    );

    return TabBarView(
      key: ValueKey(
        'tabs_${upcomingCount}_${completedCount}_${cancelledCount}',
      ),
      controller: _tabController,
      physics: const BouncingScrollPhysics(),
      children: [
        _buildBookingList(BookingStatus.upcoming, state),
        _buildBookingList(BookingStatus.completed, state),
        _buildBookingList(BookingStatus.cancelled, state),
      ],
    );
  }

  Widget _buildBookingList(BookingStatus status, BookingState state) {
    List<BookingModel> bookings;
    String emptyTitle;
    String emptySubtitle;
    IconData emptyIcon;

    switch (status) {
      case BookingStatus.upcoming:
        bookings = state.bookings
            .where((b) => b.status == BookingStatus.upcoming)
            .toList();
        print(
          '🟢 _buildBookingList(upcoming): Found ${bookings.length} bookings',
        );
        emptyTitle = 'No upcoming bookings';
        emptySubtitle = 'Book a service and it will appear here';
        emptyIcon = Icons.calendar_today;
      case BookingStatus.completed:
        bookings = state.bookings
            .where((b) => b.status == BookingStatus.completed)
            .toList();
        emptyTitle = 'No completed bookings';
        emptySubtitle = 'Your completed services will show here';
        emptyIcon = Icons.history;
      case BookingStatus.cancelled:
        bookings = state.bookings
            .where((b) => b.status == BookingStatus.cancelled)
            .toList();
        print(
          '🔴 _buildBookingList(cancelled): Found ${bookings.length} bookings',
        );
        emptyTitle = 'No cancelled bookings';
        emptySubtitle = 'Cancelled bookings will appear here';
        emptyIcon = Icons.cancel_outlined;
      default:
        bookings = [];
        emptyTitle = '';
        emptySubtitle = '';
        emptyIcon = Icons.info;
    }

    if (bookings.isEmpty) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          height: 400.h,
          child: EmptyBookingState(
            icon: emptyIcon,
            title: emptyTitle,
            subtitle: emptySubtitle,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<BookingCubit>().initialize();
      },
      color: ColorManager.primaryColor,
      child: ListView.builder(
        key: ValueKey('list_${status.name}_${bookings.length}'),
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return BookingCard(
            key: ValueKey('booking_${booking.id}_${booking.status.name}'),
            booking: booking,
            onTap: () => _showBookingDetail(booking),
            onCancel: status == BookingStatus.upcoming
                ? () => _confirmCancel(booking)
                : null,
          );
        },
      ),
    );
  }

  void _showBookingDetail(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingDetailSheet(booking: booking),
    );
  }

  void _confirmCancel(BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text('Cancel Booking'),
        content: Text(
          'Are you sure you want to cancel your ${booking.serviceName} booking?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep It',
              style: TextStyle(color: ColorManager.primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<BookingCubit>().cancelBooking(booking.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }
}

class _BookingDetailSheet extends StatelessWidget {
  final BookingModel booking;

  const _BookingDetailSheet({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: ColorManager.borderColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        booking.statusLabel,
                        style: TextStyle(
                          color: _statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: Text(
                      booking.serviceName,
                      style: TextStyles.heading3,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Center(
                    child: Text(
                      booking.providerName,
                      style: TextStyles.bodySmall,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _infoTile(
                    Icons.calendar_today,
                    'Date',
                    booking.formattedDate,
                  ),
                  _infoTile(Icons.access_time, 'Time', booking.formattedTime),
                  if (booking.address != null)
                    _infoTile(
                      Icons.location_on_outlined,
                      'Location',
                      booking.address!,
                    ),
                  _infoTile(
                    Icons.credit_card,
                    'Payment',
                    booking.paymentMethod.name,
                  ),
                  if (booking.notes != null && booking.notes!.isNotEmpty)
                    _infoTile(Icons.notes, 'Notes', booking.notes!),
                  SizedBox(height: 16.h),
                  Divider(color: ColorManager.dividerColor),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: TextStyles.labelLarge),
                      Text(
                        '\$${booking.totalPrice.toStringAsFixed(2)}',
                        style: TextStyles.priceRegular.copyWith(
                          fontSize: 22.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: ColorManager.backgroundColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.w, color: ColorManager.iconColor),
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
      ),
    );
  }
}
