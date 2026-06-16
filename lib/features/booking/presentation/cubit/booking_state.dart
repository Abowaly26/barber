part of 'booking_cubit.dart';

class BookingState extends Equatable {
  final List<ServiceItemModel> services;
  final List<ServiceItemModel> filteredServices;
  final List<BookingModel> bookings;
  final ServiceItemModel? selectedService;
  final String? selectedProviderName;
  final String? selectedProviderImageUrl;
  final DateTime? selectedDate;
  final DateTime? selectedTime;
  final String? address;
  final String? notes;
  final PaymentMethod paymentMethod;
  final BookingModel? lastConfirmedBooking;
  final String? searchQuery;
  final String? selectedCategory;
  final bool isLoading;
  final bool isConfirming;

  const BookingState({
    this.services = const [],
    this.filteredServices = const [],
    this.bookings = const [],
    this.selectedService,
    this.selectedProviderName,
    this.selectedProviderImageUrl,
    this.selectedDate,
    this.selectedTime,
    this.address,
    this.notes,
    this.paymentMethod = PaymentMethod.cash,
    this.lastConfirmedBooking,
    this.searchQuery,
    this.selectedCategory,
    this.isLoading = true,
    this.isConfirming = false,
  });

  BookingState copyWith({
    List<ServiceItemModel>? services,
    List<ServiceItemModel>? filteredServices,
    List<BookingModel>? bookings,
    ServiceItemModel? selectedService,
    String? selectedProviderName,
    String? selectedProviderImageUrl,
    DateTime? selectedDate,
    DateTime? selectedTime,
    String? address,
    String? notes,
    PaymentMethod? paymentMethod,
    BookingModel? lastConfirmedBooking,
    String? searchQuery,
    String? selectedCategory,
    bool? isLoading,
    bool? isConfirming,
    bool clearService = false,
    bool clearProvider = false,
    bool clearDate = false,
    bool clearTime = false,
    bool clearAddress = false,
    bool clearNotes = false,
    bool clearLastBooking = false,
  }) {
    return BookingState(
      services: services ?? this.services,
      filteredServices: filteredServices ?? this.filteredServices,
      bookings: bookings ?? this.bookings,
      selectedService: clearService
          ? null
          : selectedService ?? this.selectedService,
      selectedProviderName: clearProvider
          ? null
          : selectedProviderName ?? this.selectedProviderName,
      selectedProviderImageUrl: clearProvider
          ? null
          : selectedProviderImageUrl ?? this.selectedProviderImageUrl,
      selectedDate: clearDate ? null : selectedDate ?? this.selectedDate,
      selectedTime: clearTime ? null : selectedTime ?? this.selectedTime,
      address: clearAddress ? null : address ?? this.address,
      notes: clearNotes ? null : notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      lastConfirmedBooking: clearLastBooking
          ? null
          : lastConfirmedBooking ?? this.lastConfirmedBooking,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      isConfirming: isConfirming ?? this.isConfirming,
    );
  }

  @override
  List<Object?> get props => [
    services,
    filteredServices,
    bookings,
    selectedService,
    selectedProviderName,
    selectedProviderImageUrl,
    selectedDate,
    selectedTime,
    address,
    notes,
    paymentMethod,
    lastConfirmedBooking,
    searchQuery,
    selectedCategory,
    isLoading,
    isConfirming,
  ];
}
