import 'package:cloud_firestore/cloud_firestore.dart';

enum StoreItemType { product, offer, service }

extension StoreItemTypeX on StoreItemType {
  String get value {
    switch (this) {
      case StoreItemType.product:
        return 'product';
      case StoreItemType.offer:
        return 'offer';
      case StoreItemType.service:
        return 'service';
    }
  }

  String get label {
    switch (this) {
      case StoreItemType.product:
        return 'Product';
      case StoreItemType.offer:
        return 'Offer';
      case StoreItemType.service:
        return 'Service';
    }
  }
}

StoreItemType storeItemTypeFromString(String? value) {
  switch (value) {
    case 'offer':
      return StoreItemType.offer;
    case 'service':
      return StoreItemType.service;
    case 'product':
    default:
      return StoreItemType.product;
  }
}

class StoreItemModel {
  final String id;
  final String title;
  final String brand;
  final String description;
  final String category;
  final double price;
  final double? oldPrice;
  final double rating;
  final String? badge;
  final String imageUrl;
  final StoreItemType type;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StoreItemModel({
    required this.id,
    required this.title,
    required this.brand,
    required this.description,
    required this.category,
    required this.price,
    required this.oldPrice,
    required this.rating,
    required this.badge,
    required this.imageUrl,
    required this.type,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoreItemModel.fromMap(Map<String, dynamic> map) {
    return StoreItemModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      brand: map['brand']?.toString() ?? 'QUTI Store',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? 'All',
      price: _doubleFromValue(map['price']),
      oldPrice: map['oldPrice'] == null
          ? null
          : _doubleFromValue(map['oldPrice']),
      rating: _doubleFromValue(map['rating'], fallback: 4.8),
      badge: map['badge']?.toString().isEmpty ?? true
          ? null
          : map['badge']?.toString(),
      imageUrl: map['imageUrl']?.toString() ?? '',
      type: storeItemTypeFromString(map['type']?.toString()),
      isActive: map['isActive'] != false,
      createdAt: _dateFromValue(map['createdAt']),
      updatedAt: _dateFromValue(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'brand': brand,
      'description': description,
      'category': category,
      'price': price,
      'oldPrice': oldPrice,
      'rating': rating,
      'badge': badge,
      'imageUrl': imageUrl,
      'type': type.value,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedPrice => '${_trimMoney(price)} EGP';
  String? get formattedOldPrice =>
      oldPrice == null ? null : '${_trimMoney(oldPrice!)} EGP';
  String get formattedRating => _trimMoney(rating);

  static double _doubleFromValue(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static DateTime _dateFromValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }

  static String _trimMoney(double value) {
    final fixed = value.toStringAsFixed(2);
    return fixed.endsWith('00')
        ? value.toStringAsFixed(0)
        : fixed.replaceFirst(RegExp(r'0$'), '');
  }
}
