import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app/features/booking/data/models/booking_model.dart';
import 'package:app/features/booking/data/models/service_item_model.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit() : super(const BookingState());

  void initialize() {
    _loadServices();
    _loadBookings();
  }

  void _loadServices() {
    emit(
      state.copyWith(
        services: _mockServices(),
        filteredServices: _mockServices(),
        isLoading: false,
      ),
    );
  }

  void _loadBookings() {
    emit(state.copyWith(bookings: _mockBookings()));
  }

  void searchServices(String query) {
    if (query.isEmpty) {
      emit(state.copyWith(filteredServices: state.services, searchQuery: ''));
      return;
    }
    final lower = query.toLowerCase();
    final filtered = state.services.where((s) {
      return s.name.toLowerCase().contains(lower) ||
          s.category.toLowerCase().contains(lower) ||
          s.description.toLowerCase().contains(lower);
    }).toList();
    emit(state.copyWith(filteredServices: filtered, searchQuery: query));
  }

  void filterByCategory(String? category) {
    if (category == null || category == 'All') {
      emit(
        state.copyWith(
          filteredServices: state.services,
          selectedCategory: category,
        ),
      );
      return;
    }
    final filtered = state.services
        .where((s) => s.category == category)
        .toList();
    emit(
      state.copyWith(filteredServices: filtered, selectedCategory: category),
    );
  }

  void selectService(ServiceItemModel service) {
    emit(state.copyWith(selectedService: service));
  }

  void selectProvider(String name, String? imageUrl) {
    emit(
      state.copyWith(
        selectedProviderName: name,
        selectedProviderImageUrl: imageUrl,
      ),
    );
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  void selectTime(DateTime time) {
    emit(state.copyWith(selectedTime: time));
  }

  void setAddress(String address) {
    emit(state.copyWith(address: address));
  }

  void setNotes(String notes) {
    emit(state.copyWith(notes: notes));
  }

  void selectPaymentMethod(PaymentMethod method) {
    emit(state.copyWith(paymentMethod: method));
  }

  Future<bool> confirmBooking() {
    emit(state.copyWith(isConfirming: true));
    final booking = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceName: state.selectedService?.name ?? '',
      providerName: state.selectedProviderName ?? '',
      providerImageUrl: state.selectedProviderImageUrl,
      address: state.address,
      date: state.selectedDate ?? DateTime.now(),
      time: state.selectedTime ?? DateTime.now(),
      price: state.selectedService?.price ?? 0,
      serviceFee: 5.0,
      durationMinutes: state.selectedService?.durationMinutes ?? 60,
      status: BookingStatus.upcoming,
      paymentMethod: state.paymentMethod,
      notes: state.notes,
      serviceDetails: state.selectedService,
      createdAt: DateTime.now(),
    );
    final updated = [booking, ...state.bookings];
    emit(
      state.copyWith(
        bookings: updated,
        isConfirming: false,
        lastConfirmedBooking: booking,
      ),
    );
    return Future.value(true);
  }

  void cancelBooking(String bookingId) {
    print('🔴 cancelBooking called for ID: $bookingId');
    print('🔴 Current bookings count: ${state.bookings.length}');

    final updated = state.bookings.map((b) {
      if (b.id == bookingId) {
        print('🟢 Found booking to cancel: ${b.serviceName}');
        return b.copyWith(status: BookingStatus.cancelled);
      }
      return b;
    }).toList();

    print('🔴 Updated bookings count: ${updated.length}');
    final cancelledCount = updated
        .where((b) => b.status == BookingStatus.cancelled)
        .length;
    final upcomingCount = updated
        .where((b) => b.status == BookingStatus.upcoming)
        .length;
    print('🔴 Cancelled: $cancelledCount, Upcoming: $upcomingCount');

    emit(state.copyWith(bookings: updated));
    print('🟢 New state emitted');
  }

  void resetBookingFlow() {
    emit(
      state.copyWith(
        selectedService: null,
        selectedProviderName: null,
        selectedProviderImageUrl: null,
        selectedDate: null,
        selectedTime: null,
        address: null,
        notes: null,
        paymentMethod: PaymentMethod.cash,
        lastConfirmedBooking: null,
      ),
    );
  }

  List<BookingModel> get upcomingBookings =>
      state.bookings.where((b) => b.status == BookingStatus.upcoming).toList();

  List<BookingModel> get completedBookings =>
      state.bookings.where((b) => b.status == BookingStatus.completed).toList();

  List<BookingModel> get cancelledBookings =>
      state.bookings.where((b) => b.status == BookingStatus.cancelled).toList();

  List<String> get categories {
    final cats = state.services.map((s) => s.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  List<ServiceItemModel> _mockServices() {
    return [
      ServiceItemModel(
        id: '1',
        name: 'Classic Haircut',
        description: 'Precision haircut with hot towel finish and style',
        price: 45.0,
        originalPrice: 60.0,
        durationMinutes: 45,
        category: 'Haircut',
        imageUrl: null,
        rating: 4.8,
        reviewCount: 234,
        isPopular: true,
      ),
      ServiceItemModel(
        id: '2',
        name: 'Beard Grooming',
        description: 'Professional beard trim, shaping, and moisturizing',
        price: 30.0,
        durationMinutes: 30,
        category: 'Grooming',
        imageUrl: null,
        rating: 4.6,
        reviewCount: 189,
        isPopular: true,
      ),
      ServiceItemModel(
        id: '3',
        name: 'Hair & Beard Combo',
        description: 'Full haircut and beard grooming package with hot towel',
        price: 65.0,
        originalPrice: 90.0,
        durationMinutes: 60,
        category: 'Combo',
        imageUrl: null,
        rating: 4.9,
        reviewCount: 412,
        isPopular: true,
      ),
      ServiceItemModel(
        id: '4',
        name: 'Hot Towel Shave',
        description: 'Traditional straight razor shave with hot towels',
        price: 40.0,
        durationMinutes: 45,
        category: 'Grooming',
        imageUrl: null,
        rating: 4.7,
        reviewCount: 156,
      ),
      ServiceItemModel(
        id: '5',
        name: 'Kids Haircut',
        description: 'Fun and friendly haircut experience for children',
        price: 25.0,
        durationMinutes: 30,
        category: 'Haircut',
        imageUrl: null,
        rating: 4.5,
        reviewCount: 89,
      ),
      ServiceItemModel(
        id: '6',
        name: 'Hair Styling',
        description: 'Professional styling with premium products',
        price: 50.0,
        durationMinutes: 45,
        category: 'Styling',
        imageUrl: null,
        rating: 4.7,
        reviewCount: 203,
      ),
      ServiceItemModel(
        id: '7',
        name: 'Scalp Treatment',
        description: 'Deep cleansing scalp treatment with massage',
        price: 55.0,
        originalPrice: 75.0,
        durationMinutes: 60,
        category: 'Treatment',
        imageUrl: null,
        rating: 4.4,
        reviewCount: 67,
      ),
      ServiceItemModel(
        id: '8',
        name: 'Color & Cut',
        description: 'Full color service with precision haircut',
        price: 120.0,
        durationMinutes: 120,
        category: 'Coloring',
        imageUrl: null,
        rating: 4.9,
        reviewCount: 89,
        isPopular: true,
      ),
    ];
  }

  List<BookingModel> _mockBookings() {
    final now = DateTime.now();
    return [
      BookingModel(
        id: 'B001',
        serviceName: 'Classic Haircut',
        providerName: 'Ahmed Hassan',
        providerImageUrl: null,
        providerPhone: '+966501234567',
        address: '123 Main St, Riyadh',
        date: now.add(const Duration(days: 2)),
        time: DateTime(now.year, now.month, now.day, 10, 30),
        price: 45.0,
        serviceFee: 5.0,
        durationMinutes: 45,
        status: BookingStatus.upcoming,
        paymentMethod: PaymentMethod.creditCard,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      BookingModel(
        id: 'B002',
        serviceName: 'Hair & Beard Combo',
        providerName: 'Mohammed Ali',
        providerImageUrl: null,
        address: '456 King Fahd Rd, Jeddah',
        date: now.add(const Duration(days: 5)),
        time: DateTime(now.year, now.month, now.day, 14, 0),
        price: 65.0,
        serviceFee: 5.0,
        discount: 10.0,
        durationMinutes: 60,
        status: BookingStatus.upcoming,
        paymentMethod: PaymentMethod.applePay,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      BookingModel(
        id: 'B003',
        serviceName: 'Beard Grooming',
        providerName: 'Khalid Omer',
        providerImageUrl: null,
        address: '789 Olaya St, Riyadh',
        date: now.subtract(const Duration(days: 7)),
        time: DateTime(now.year, now.month, now.day, 11, 0),
        price: 30.0,
        durationMinutes: 30,
        status: BookingStatus.completed,
        paymentMethod: PaymentMethod.cash,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      BookingModel(
        id: 'B004',
        serviceName: 'Hot Towel Shave',
        providerName: 'Sami Ibrahim',
        providerImageUrl: null,
        address: '321 Prince Sultan St, Dammam',
        date: now.subtract(const Duration(days: 14)),
        time: DateTime(now.year, now.month, now.day, 9, 30),
        price: 40.0,
        serviceFee: 5.0,
        durationMinutes: 45,
        status: BookingStatus.completed,
        paymentMethod: PaymentMethod.creditCard,
        createdAt: now.subtract(const Duration(days: 16)),
      ),
      BookingModel(
        id: 'B005',
        serviceName: 'Hair Styling',
        providerName: 'Noor Ahmed',
        providerImageUrl: null,
        address: '555 Tahlia St, Riyadh',
        date: now.subtract(const Duration(days: 3)),
        time: DateTime(now.year, now.month, now.day, 16, 0),
        price: 50.0,
        durationMinutes: 45,
        status: BookingStatus.cancelled,
        paymentMethod: PaymentMethod.cash,
        createdAt: now.subtract(const Duration(days: 5)),
        cancellationReason: 'Schedule conflict',
      ),
    ];
  }
}
