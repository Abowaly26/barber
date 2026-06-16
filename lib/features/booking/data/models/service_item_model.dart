class ServiceItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final int durationMinutes;
  final String category;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final bool isPopular;
  final bool isAvailable;

  const ServiceItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.durationMinutes,
    required this.category,
    this.imageUrl,
    this.rating = 0,
    this.reviewCount = 0,
    this.isPopular = false,
    this.isAvailable = true,
  });

  factory ServiceItemModel.fromJson(Map<String, dynamic> json) {
    return ServiceItemModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      durationMinutes: json['durationMinutes'] as int? ?? 60,
      category: json['category'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      isPopular: json['isPopular'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'originalPrice': originalPrice,
        'durationMinutes': durationMinutes,
        'category': category,
        'imageUrl': imageUrl,
        'rating': rating,
        'reviewCount': reviewCount,
        'isPopular': isPopular,
        'isAvailable': isAvailable,
      };

  double get discountPercentage {
    if (originalPrice == null || originalPrice! <= 0) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).roundToDouble();
  }

  ServiceItemModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    int? durationMinutes,
    String? category,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    bool? isPopular,
    bool? isAvailable,
  }) {
    return ServiceItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isPopular: isPopular ?? this.isPopular,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
