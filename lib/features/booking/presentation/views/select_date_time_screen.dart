import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/utils/color_manager.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:app/features/booking/presentation/widgets/time_slot_grid.dart';
import 'package:app/features/booking/presentation/widgets/booking_summary.dart';

class SelectDateTimeScreen extends StatefulWidget {
  static const String routeName = '/select-date-time';

  const SelectDateTimeScreen({super.key});

  @override
  State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeSlot? _selectedSlot;
  late PageController _pageController;

  final List<TimeSlot> _morningSlots = [];
  final List<TimeSlot> _afternoonSlots = [];
  final List<TimeSlot> _eveningSlots = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _generateSlots();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _generateSlots() {
    for (int i = 9; i <= 20; i++) {
      final isPeak = (i >= 11 && i <= 13) || (i >= 17 && i <= 19);
      final time = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        i,
        0,
      );
      final slot = TimeSlot(
        label: '${i > 12 ? i - 12 : i}:00 ${i >= 12 ? 'PM' : 'AM'}',
        time: time,
        isAvailable: i != 12 && i != 13,
        isPeak: isPeak,
      );
      if (i >= 9 && i < 12) {
        _morningSlots.add(slot);
      } else if (i >= 12 && i < 17) {
        _afternoonSlots.add(slot);
      } else {
        _eveningSlots.add(slot);
      }
    }
  }

  List<DateTime> get _next30Days {
    return List.generate(
      30,
      (i) => DateTime.now().add(Duration(days: i)),
    );
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
        title: Text('Select Date & Time', style: TextStyles.appBarTitle),
        centerTitle: true,
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateHeader(),
                      _buildDatePicker(),
                      SizedBox(height: 8.h),
                      _buildSectionLabel('Morning'),
                      _buildTimeSection(_morningSlots),
                      _buildSectionLabel('Afternoon'),
                      _buildTimeSection(_afternoonSlots),
                      _buildSectionLabel('Evening'),
                      _buildTimeSection(_eveningSlots),
                      SizedBox(height: 16.h),
                      if (state.selectedService != null) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: BookingSummary(
                            service: state.selectedService,
                            date: _selectedDate,
                            time: _selectedSlot?.time,
                            paymentMethod: state.paymentMethod,
                          ),
                        ),
                      ],
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
      child: Row(
        children: [
          Icon(Icons.calendar_month, size: 18.w, color: ColorManager.primaryColor),
          SizedBox(width: 8.w),
          Text(
            'Choose a date',
            style: TextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      color: Colors.white,
      height: 80.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _next30Days.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final date = _next30Days[index];
          final isSelected = _isSameDay(date, _selectedDate);
          final isToday = _isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
                _morningSlots.clear();
                _afternoonSlots.clear();
                _eveningSlots.clear();
                _selectedSlot = null;
                _generateSlots();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorManager.primaryColor
                    : isToday
                        ? ColorManager.primaryColor.withValues(alpha: 0.08)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected
                      ? ColorManager.primaryColor
                      : isToday
                          ? ColorManager.primaryColor.withValues(alpha: 0.3)
                          : ColorManager.borderColor,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayAbbr(date),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isSelected
                          ? Colors.white70
                          : ColorManager.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : ColorManager.textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Row(
        children: [
          Container(
            width: 3.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: ColorManager.primaryColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection(List<TimeSlot> slots) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: TimeSlotGrid(
        slots: slots,
        selectedSlot: _selectedSlot,
        onSlotSelected: (slot) {
          setState(() => _selectedSlot = slot);
        },
      ),
    );
  }

  Widget _buildBottomBar() {
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
          onPressed: _selectedSlot != null ? _onContinue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedSlot != null
                ? ColorManager.primaryColor
                : ColorManager.buttonDisabledColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _selectedSlot != null
                    ? 'Continue'
                    : 'Select a time slot',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_selectedSlot != null) ...[
                SizedBox(width: 8.w),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _onContinue() {
    final cubit = context.read<BookingCubit>();
    cubit.selectDate(_selectedDate);
    if (_selectedSlot != null) {
      cubit.selectTime(_selectedSlot!.time);
    }
    Navigator.pushNamed(context, '/booking-review');
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dayAbbr(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
