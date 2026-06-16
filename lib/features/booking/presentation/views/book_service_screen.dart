import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/utils/color_manager.dart';
import 'package:app/core/utils/text_styles.dart';
import 'package:app/features/booking/data/models/service_item_model.dart';
import 'package:app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:app/features/booking/presentation/widgets/service_card.dart';
import 'package:app/features/booking/presentation/widgets/empty_booking_state.dart';

class BookServiceScreen extends StatefulWidget {
  static const String routeName = '/book-service';

  const BookServiceScreen({super.key});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<BookingCubit>().initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.backgroundColor,
      appBar: _buildAppBar(),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildSearchBar(),
              _buildCategoryChips(state),
              Expanded(child: _buildServicesGrid(state)),
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
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, size: 18.w),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Book a Service', style: TextStyles.appBarTitle),
      centerTitle: true,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          context.read<BookingCubit>().searchServices(query);
        },
        style: TextStyle(fontSize: 14.sp, color: ColorManager.textPrimaryColor),
        decoration: InputDecoration(
          hintText: 'Search services...',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: ColorManager.textHintColor,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: ColorManager.iconColor,
            size: 20.w,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, size: 18.w),
                  onPressed: () {
                    _searchController.clear();
                    context.read<BookingCubit>().searchServices('');
                  },
                )
              : null,
          filled: true,
          fillColor: ColorManager.backgroundColor,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: ColorManager.primaryColor.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BookingState state) {
    final cubit = context.read<BookingCubit>();
    return Container(
      color: Colors.white,
      height: 44.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: cubit.categories.map((cat) {
          final isSelected = state.selectedCategory == cat;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () => cubit.filterByCategory(isSelected ? null : cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorManager.primaryColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? ColorManager.primaryColor
                        : ColorManager.borderColor,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                ColorManager.primaryColor.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : ColorManager.textPrimaryColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildServicesGrid(BookingState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.filteredServices.isEmpty) {
      return EmptyBookingState(
        icon: Icons.search_off,
        title: 'No services found',
        subtitle: state.searchQuery != null
            ? 'No results for "${state.searchQuery}"'
            : 'No services available in this category',
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      itemCount: state.filteredServices.length,
      itemBuilder: (context, index) {
        final service = state.filteredServices[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: ServiceCard(
            service: service,
            onTap: () => _selectService(service),
          ),
        );
      },
    );
  }

  void _selectService(ServiceItemModel service) {
    context.read<BookingCubit>().selectService(service);
    Navigator.pushNamed(context, '/select-date-time');
  }
}
