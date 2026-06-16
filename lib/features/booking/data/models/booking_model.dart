import 'package:app/features/booking/data/models/service_item_model.dart';

enum BookingStatus { upcoming, completed, cancelled, inProgress }

enum PaymentMethod { creditCard, cash, applePay, googlePay }

class BookingModel {
  final String id;
  final String serviceName;
  final String providerName;
  final String? providerImageUrl;
  final String? providerPhone;
  final String? address;
  final DateTime date;
  final DateTime time;
  final double price;
  final double? serviceFee;
  final double? discount;
  final int durationMinutes;
  final BookingStatus status;
  final PaymentMethod paymentMethod;
  final String? notes;
  final ServiceItemModel? serviceDetails;
  final DateTime createdAt;
  final String? cancellationReason;

  const BookingModel({
    required this.id,
    required this.serviceName,
    required this.providerName,
    this.providerImageUrl,
    this.providerPhone,
    this.address,
    required this.date,
    required this.time,
    required this.price,
    this.serviceFee,
    this.discount,
    required this.durationMinutes,
    required this.status,
    required this.paymentMethod,
    this.notes,
    this.serviceDetails,
    required this.createdAt,
    this.cancellationReason,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? '',
      providerName: json['providerName'] as String? ?? '',
      providerImageUrl: json['providerImageUrl'] as String?,
      providerPhone: json['providerPhone'] as String?,
      address: json['address'] as String?,
      date: DateTime.parse(json['date'] as String),
      time: DateTime.parse(json['time'] as String),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      serviceFee: (json['serviceFee'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      durationMinutes: json['durationMinutes'] as int? ?? 60,
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.upcoming,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      notes: json['notes'] as String?,
      serviceDetails: json['serviceDetails'] != null
          ? ServiceItemModel.fromJson(
              json['serviceDetails'] as Map<String, dynamic>,
            )
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      cancellationReason: json['cancellationReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'serviceName': serviceName,
    'providerName': providerName,
    'providerImageUrl': providerImageUrl,
    'providerPhone': providerPhone,
    'address': address,
    'date': date.toIso8601String(),
    'time': time.toIso8601String(),
    'price': price,
    'serviceFee': serviceFee,
    'discount': discount,
    'durationMinutes': durationMinutes,
    'status': status.name,
    'paymentMethod': paymentMethod.name,
    'notes': notes,
    'serviceDetails': serviceDetails?.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'cancellationReason': cancellationReason,
  };

  String get formattedTime {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String get formattedDate {
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
  }

  double get totalPrice {
    double total = price;
    if (serviceFee != null) total += serviceFee!;
    if (discount != null) total -= discount!;
    return total;
  }

  String get statusLabel {
    switch (status) {
      case BookingStatus.upcoming:
        return 'Upcoming';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.inProgress:
        return 'In Progress';
    }
  }

  BookingModel copyWith({
    String? id,
    String? serviceName,
    String? providerName,
    String? providerImageUrl,
    String? providerPhone,
    String? address,
    DateTime? date,
    DateTime? time,
    double? price,
    double? serviceFee,
    double? discount,
    int? durationMinutes,
    BookingStatus? status,
    PaymentMethod? paymentMethod,
    String? notes,
    ServiceItemModel? serviceDetails,
    DateTime? createdAt,
    String? cancellationReason,
  }) {
    return BookingModel(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      providerName: providerName ?? this.providerName,
      providerImageUrl: providerImageUrl ?? this.providerImageUrl,
      providerPhone: providerPhone ?? this.providerPhone,
      address: address ?? this.address,
      date: date ?? this.date,
      time: time ?? this.time,
      price: price ?? this.price,
      serviceFee: serviceFee ?? this.serviceFee,
      discount: discount ?? this.discount,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      serviceDetails: serviceDetails ?? this.serviceDetails,
      createdAt: createdAt ?? this.createdAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingModel &&
        other.id == id &&
        other.serviceName == serviceName &&
        other.providerName == providerName &&
        other.providerImageUrl == providerImageUrl &&
        other.providerPhone == providerPhone &&
        other.address == address &&
        other.date == date &&
        other.time == time &&
        other.price == price &&
        other.serviceFee == serviceFee &&
        other.discount == discount &&
        other.durationMinutes == durationMinutes &&
        other.status == status &&
        other.paymentMethod == paymentMethod &&
        other.notes == notes &&
        other.serviceDetails == serviceDetails &&
        other.createdAt == createdAt &&
        other.cancellationReason == cancellationReason;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      serviceName,
      providerName,
      providerImageUrl,
      providerPhone,
      address,
      date,
      time,
      price,
      serviceFee,
      discount,
      durationMinutes,
      status,
      paymentMethod,
      notes,
      serviceDetails,
      createdAt,
      cancellationReason,
    ]);
  }
}
