// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/features/quti_shared/quti_shared.dart';
import 'package:app/features/store_flow/data/models/store_item_model.dart';
import 'package:app/features/store_flow/data/repos/store_repository.dart';

// ==========================================
// STORE SHARED WIDGETS
// ==========================================
class StoreCartAction extends StatelessWidget {
  const StoreCartAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<StoreCartItem>>(
      valueListenable: StoreCartController.items,
      builder: (context, cartItems, _) {
        final count = cartItems.fold<int>(0, (total, item) => total + item.quantity);

        return IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart_outlined),
              if (count > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StoreCartScreen()),
          ),
        );
      },
    );
  }
}

// ==========================================
// STORE BANNER SLIDER
// ==========================================
class StoreBannerSlider extends StatefulWidget {
  const StoreBannerSlider({super.key});

  @override
  State<StoreBannerSlider> createState() => _StoreBannerSliderState();
}

class _StoreBannerSliderState extends State<StoreBannerSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _slideCount = _slides.length;
  Timer? _timer;

  static const _slides = <_StoreSlideData>[
    _StoreSlideData(
      tag: 'LIMITED OFFER',
      title: 'Get 30% Off\nGrooming Kits',
      subtitle: 'Premium products for your barbershop',
      ctaLabel: 'Shop Now',
      gradient: [Color(0xFF3B7274), Color(0xFF1A4A4C)],
      accentColor: Color(0xFF6BD4D8),
      icon: Icons.local_offer_outlined,
    ),
    _StoreSlideData(
      tag: 'NEW ARRIVAL',
      title: 'Professional\nHair Care Line',
      subtitle: 'Salon-grade products at your fingertips',
      ctaLabel: 'Explore',
      gradient: [Color(0xFF4A2C6A), Color(0xFF2D1845)],
      accentColor: Color(0xFFB57BFF),
      icon: Icons.auto_awesome_outlined,
    ),
    _StoreSlideData(
      tag: 'BEST SELLERS',
      title: 'Beard Care\nEssentials',
      subtitle: 'Top-rated grooming products',
      ctaLabel: 'View Collection',
      gradient: [Color(0xFF8B5E3C), Color(0xFF5C3A1E)],
      accentColor: Color(0xFFFFB74D),
      icon: Icons.star_outline,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    if (_timer?.isActive == true || _slideCount <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients || _slideCount <= 1) return;

      if (_currentPage < _slideCount - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _syncSlideCount(int nextCount) {
    if (_slideCount == nextCount) return;

    _slideCount = nextCount;
    if (_currentPage >= nextCount) {
      _currentPage = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }

    _timer?.cancel();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('app_banners')
          .where('placement', isEqualTo: 'store')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        final firestoreSlides = _mapStoreBanners(snapshot.data?.docs);
        final slides = firestoreSlides.isEmpty ? _slides : firestoreSlides;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _syncSlideCount(slides.length);
        });

        return Column(
          children: [
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StoreProductsScreen(),
                      ),
                    ),
                    child: slide.imageUrl == null
                        ? _StoreGradientBanner(slide: slide)
                        : _StoreImageBanner(slide: slide),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (index) {
                final isActive = _currentPage == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  List<_StoreSlideData> _mapStoreBanners(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? docs,
  ) {
    if (docs == null || docs.isEmpty) return const [];

    final banners = docs
        .map((doc) {
          final data = doc.data();
          final imageUrl = data['imageUrl']?.toString() ?? '';
          if (imageUrl.isEmpty) return null;

          return _StoreSlideData(
            tag: data['name']?.toString() ?? 'STORE OFFER',
            title: '',
            subtitle: '',
            ctaLabel: 'Shop Now',
            gradient: const [Color(0xFF3B7274), Color(0xFF1A4A4C)],
            accentColor: const Color(0xFF6BD4D8),
            icon: Icons.local_offer_outlined,
            imageUrl: imageUrl,
            displayOrder: _asInt(data['displayOrder']),
          );
        })
        .whereType<_StoreSlideData>()
        .toList();

    banners.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return banners;
  }
}

class StoreCartItem {
  final String productId;
  final String title;
  final String brand;
  final String price;
  final double unitPrice;
  final String? imageUrl;
  final String? barberId;
  final String? barberName;
  final String type;
  int quantity;

  StoreCartItem({
    required this.productId,
    required this.title,
    required this.brand,
    required this.price,
    required this.unitPrice,
    this.imageUrl,
    this.barberId,
    this.barberName,
    this.type = 'product',
    this.quantity = 1,
  });

  double get lineTotal => unitPrice * quantity;

  Map<String, dynamic> toCartMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'productDetails': {
        'title': title,
        'brand': brand,
        'price': unitPrice,
        'imageUrl': imageUrl,
        'barberId': barberId,
        'barberName': barberName,
        'type': type,
      },
    };
  }

  Map<String, dynamic> toOrderMap() {
    return {
      'productId': productId,
      'title': title,
      'brand': brand,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'lineTotal': lineTotal,
      'imageUrl': imageUrl,
      'barberId': barberId,
      'barberName': barberName,
      'type': type,
    };
  }
}

class StoreOrderDraft {
  final String orderNumber;
  final List<StoreCartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final DateTime createdAt;

  const StoreOrderDraft({
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.createdAt,
  });

  int get itemCount => items.fold<int>(0, (total, item) => total + item.quantity);
}

class StoreCartController {
  StoreCartController._();

  static final ValueNotifier<List<StoreCartItem>> items =
      ValueNotifier<List<StoreCartItem>>([]);
  static StoreOrderDraft? lastOrder;

  static void addItem({
    String productId = '',
    required String title,
    required String brand,
    required String price,
    String? imageUrl,
    String? barberId,
    String? barberName,
    String type = 'product',
    int quantity = 1,
  }) {
    final updated = List<StoreCartItem>.from(items.value);
    final itemId = productId.isNotEmpty
        ? productId
        : '${brand}_$title'.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final index = updated.indexWhere(
      (item) => item.productId == itemId,
    );

    if (index >= 0) {
      updated[index].quantity += quantity;
    } else {
      updated.add(
        StoreCartItem(
          productId: itemId,
          title: title,
          brand: brand,
          price: price,
          unitPrice: priceValue(price),
          imageUrl: imageUrl,
          barberId: barberId,
          barberName: barberName,
          type: type,
          quantity: quantity,
        ),
      );
    }

    items.value = updated;
    _syncCart();
  }

  static void updateQuantity(StoreCartItem item, int quantity) {
    final updated = List<StoreCartItem>.from(items.value);
    final index = updated.indexWhere(
      (cartItem) => cartItem.productId == item.productId,
    );

    if (index < 0) return;
    if (quantity <= 0) {
      updated.removeAt(index);
    } else {
      updated[index].quantity = quantity;
    }

    items.value = updated;
    _syncCart();
  }

  static void clear() {
    items.value = [];
    _syncCart();
  }

  static Future<void> _syncCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('carts').doc(user.uid).set({
      'userId': user.uid,
      'items': items.value.map((item) => item.toCartMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  static double priceValue(String price) {
    final normalized = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? 0;
  }

  static String formatEgp(double value) {
    final fixed = value.toStringAsFixed(2);
    final trimmed = fixed.endsWith('00')
        ? value.toStringAsFixed(0)
        : fixed.replaceFirst(RegExp(r'0$'), '');
    return '$trimmed EGP';
  }

  static double subtotal(List<StoreCartItem> cartItems) {
    return cartItems.fold<double>(
      0,
      (total, item) => total + item.lineTotal,
    );
  }

  static Future<StoreOrderDraft> placeOrder({required double deliveryFee}) async {
    final orderItems = List<StoreCartItem>.from(items.value);
    final orderSubtotal = subtotal(orderItems);
    final orderDeliveryFee = orderItems.isEmpty ? 0.0 : deliveryFee;
    final orderTotal = orderSubtotal + orderDeliveryFee;
    final now = DateTime.now();
    final orderNumber = 'QUTI-${now.millisecondsSinceEpoch}';
    final draft = StoreOrderDraft(
      orderNumber: orderNumber,
      items: orderItems,
      subtotal: orderSubtotal,
      deliveryFee: orderDeliveryFee,
      total: orderTotal,
      createdAt: now,
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final timestamp = FieldValue.serverTimestamp();
      var customerName = user.displayName ?? 'Store Customer';
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        customerName = userDoc.data()?['name']?.toString() ?? customerName;
      } catch (_) {}

      final batch = FirebaseFirestore.instance.batch();
      final orderRef = FirebaseFirestore.instance.collection('orders').doc(orderNumber);
      final cartRef = FirebaseFirestore.instance.collection('carts').doc(user.uid);

      batch.set(orderRef, {
        'orderNumber': orderNumber,
        'userId': user.uid,
        'items': orderItems.map((item) => item.toOrderMap()).toList(),
        'subtotal': orderSubtotal,
        'deliveryFee': orderDeliveryFee,
        'total': orderTotal,
        'currency': 'EGP',
        'paymentMethod': 'cash_on_delivery',
        'status': 'placed',
        'createdAt': now.toIso8601String(),
      });
      _addOrderMessagesToBatch(
        batch: batch,
        orderNumber: orderNumber,
        orderItems: orderItems,
        customerId: user.uid,
        customerName: customerName,
        createdAt: timestamp,
      );
      batch.set(cartRef, {
        'userId': user.uid,
        'items': [],
        'updatedAt': now.toIso8601String(),
      }, SetOptions(merge: true));
      await batch.commit();
    }

    lastOrder = draft;
    items.value = [];
    return draft;
  }

  static void _addOrderMessagesToBatch({
    required WriteBatch batch,
    required String orderNumber,
    required List<StoreCartItem> orderItems,
    required String customerId,
    required String customerName,
    required FieldValue createdAt,
  }) {
    if (orderItems.isEmpty) return;

    final adminItems = orderItems.where((item) => (item.barberId ?? '').isEmpty).toList();
    if (adminItems.isNotEmpty) {
      _addChatMessage(
        batch: batch,
        chatId: 'admin_store_orders',
        ownerId: 'admin',
        ownerName: 'Admin',
        customerId: customerId,
        customerName: customerName,
        message: _buildOrderMessage(orderNumber, adminItems),
        timestamp: createdAt,
        isAdminChat: true,
      );
    }

    final barberIds = orderItems
        .map((item) => item.barberId ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    for (final barberId in barberIds) {
      final barberItems = orderItems.where((item) => item.barberId == barberId).toList();
      _addChatMessage(
        batch: batch,
        chatId: '${customerId}_$barberId',
        ownerId: barberId,
        ownerName: barberItems.first.barberName ?? 'Barber',
        customerId: customerId,
        customerName: customerName,
        message: _buildOrderMessage(orderNumber, barberItems),
        timestamp: createdAt,
      );
    }
  }

  static void _addChatMessage({
    required WriteBatch batch,
    required String chatId,
    required String ownerId,
    required String ownerName,
    required String customerId,
    required String customerName,
    required String message,
    required FieldValue timestamp,
    bool isAdminChat = false,
  }) {
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final messageRef = chatRef.collection('messages').doc();

    batch.set(chatRef, {
      'customerId': customerId,
      'customerName': customerName,
      if (isAdminChat) 'adminId': ownerId else 'barberId': ownerId,
      if (isAdminChat) 'adminName': ownerName else 'barberName': ownerName,
      'lastMessage': message,
      'lastMessageTime': timestamp,
      'unreadByBarber': FieldValue.increment(1),
      if (isAdminChat) 'chatType': 'admin_store_orders',
    }, SetOptions(merge: true));

    batch.set(messageRef, {
      'senderId': 'system',
      'senderName': 'System',
      'message': message,
      'timestamp': timestamp,
      'type': isAdminChat ? 'admin_store_order' : 'barber_store_order',
    });
  }

  static String _buildOrderMessage(
    String orderNumber,
    List<StoreCartItem> orderItems,
  ) {
    final itemsTotal = orderItems.fold<double>(0, (total, item) => total + item.lineTotal);
    final lines = orderItems
        .map((item) => '- ${item.title} x${item.quantity} (${formatEgp(item.lineTotal)})')
        .join('\n');
    return 'New order from app\n'
        'Order number: $orderNumber\n'
        '$lines\n'
        'Total: ${formatEgp(itemsTotal)}\n'
        'Payment: Cash on delivery';
  }
}

class _StoreImageBanner extends StatelessWidget {
  const _StoreImageBanner({required this.slide});

  final _StoreSlideData slide;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: slide.imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: AppColors.borderGrey),
          errorWidget: (context, url, error) =>
              const Icon(Icons.image_not_supported),
        ),
      ),
    );
  }
}

class _StoreGradientBanner extends StatelessWidget {
  const _StoreGradientBanner({required this.slide});

  final _StoreSlideData slide;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: slide.gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: slide.gradient.last.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: slide.accentColor.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: slide.accentColor.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: slide.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(slide.icon, color: slide.accentColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        slide.tag,
                        style: TextStyle(
                          color: slide.accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  slide.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  slide.subtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        slide.ctaLabel,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreSlideData {
  final String tag;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final List<Color> gradient;
  final Color accentColor;
  final IconData icon;
  final String? imageUrl;
  final int displayOrder;

  const _StoreSlideData({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.gradient,
    required this.accentColor,
    required this.icon,
    this.imageUrl,
    this.displayOrder = 0,
  });
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

// ==========================================
// 1. STORE HOME SCREEN
// ==========================================
class StoreHomeScreen extends StatelessWidget {
  const StoreHomeScreen({super.key, this.embedded = false});

  /// When true, hides back button (used as a nav tab)
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final bottomInset = embedded
        ? 24.0
        : MediaQuery.of(context).padding.bottom + 24;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: embedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
        title: const Text(
          'QUTI Store',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [const StoreCartAction(), const SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // â”€â”€ Banner Slider â”€â”€
            const StoreBannerSlider(),
            const SizedBox(height: 24),

            _buildSectionHeader(
              'Offers',
              'See All',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoreOffersScreen()),
              ),
            ),
            const _StoreItemsSection(
              type: StoreItemType.offer,
              emptyMessage: 'No offers added yet',
            ),
            const SizedBox(height: 16),

            _buildSectionHeader(
              'Products',
              'See All',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoreProductsScreen()),
              ),
            ),
            const _StoreItemsSection(
              type: StoreItemType.product,
              emptyMessage: 'No products added yet',
            ),
            const SizedBox(height: 16),

          ],
        ),
      ),
      // Store is pushed on top of MainShell, no bottom nav here
      bottomNavigationBar: null,
    );
  }

  Widget _buildSectionHeader(
    String title,
    String actionText,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: onTap,
            child: Text(
              actionText,
              style: const TextStyle(color: AppColors.primary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

}

class _StoreItemsSection extends StatelessWidget {
  const _StoreItemsSection({required this.type, required this.emptyMessage});

  final StoreItemType type;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: StoreRepository().streamItems(type: type, limit: 10),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 230,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final result = snapshot.data;
        if (result == null) {
          return _StoreEmptySection(message: emptyMessage);
        }

        return result.fold(
          (failure) => _StoreEmptySection(message: failure.message),
          (items) {
            if (items.isEmpty) return _StoreEmptySection(message: emptyMessage);

            return SizedBox(
              height: 250,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return StoreProductCard(
                    productId: item.id,
                    title: item.title,
                    brand: item.brand,
                    price: item.formattedPrice,
                    oldPrice: item.formattedOldPrice,
                    rating: item.formattedRating,
                    badge: item.badge,
                    imageUrl: item.imageUrl,
                    description: item.description,
                    barberId: item.barberId,
                    barberName: item.barberName,
                    itemType: item.type.value,
                    width: 160,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _StoreEmptySection extends StatelessWidget {
  const _StoreEmptySection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.textGrey),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ==========================================
// 2. PRODUCTS LIST SCREEN
// ==========================================
class StoreProductsScreen extends StatelessWidget {
  const StoreProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Products'),
        centerTitle: true,
        actions: const [StoreCartAction(), SizedBox(width: 8)],
      ),
      body: Column(
        children: [
Expanded(
            child: StreamBuilder(
              stream: StoreRepository().streamItems(
                type: StoreItemType.product,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final result = snapshot.data;
                if (result == null) {
                  return const _StoreEmptySection(
                    message: 'No products added yet',
                  );
                }

                return result.fold(
                  (failure) => _StoreEmptySection(message: failure.message),
                  (items) {
                    if (items.isEmpty) {
                      return const _StoreEmptySection(
                        message: 'No products added yet',
                      );
                    }

                    return Column(
                      children: [
Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return StoreProductCard(
                                productId: item.id,
                                title: item.title,
                                brand: item.brand,
                                price: item.formattedPrice,
                                oldPrice: item.formattedOldPrice,
                                rating: item.formattedRating,
                                badge: item.badge,
                                imageUrl: item.imageUrl,
                                description: item.description,
                                barberId: item.barberId,
                                barberName: item.barberName,
                                itemType: item.type.value,
                                isGrid: true,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }


}

// ==========================================
// 3. OFFERS LIST SCREEN
// ==========================================
class StoreOffersScreen extends StatelessWidget {
  const StoreOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Offers'),
        centerTitle: true,
        actions: const [StoreCartAction(), SizedBox(width: 8)],
      ),
      body: Column(
        children: [
Expanded(
            child: StreamBuilder(
              stream: StoreRepository().streamItems(
                type: StoreItemType.offer,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final result = snapshot.data;
                if (result == null) {
                  return const _StoreEmptySection(
                    message: 'No offers added yet',
                  );
                }

                return result.fold(
                  (failure) => _StoreEmptySection(message: failure.message),
                  (items) {
                    if (items.isEmpty) {
                      return const _StoreEmptySection(
                        message: 'No offers added yet',
                      );
                    }

                    return Column(
                      children: [
Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return StoreProductCard(
                                productId: item.id,
                                title: item.title,
                                brand: item.brand,
                                price: item.formattedPrice,
                                oldPrice: item.formattedOldPrice,
                                rating: item.formattedRating,
                                badge: item.badge,
                                imageUrl: item.imageUrl,
                                description: item.description,
                                barberId: item.barberId,
                                barberName: item.barberName,
                                itemType: item.type.value,
                                isGrid: true,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }


}

// ==========================================
// REUSABLE PRODUCT CARD
// ==========================================
class StoreProductCard extends StatelessWidget {
  final String productId;
  final String title;
  final String brand;
  final String price;
  final String? oldPrice;
  final String rating;
  final String? badge;
  final String? imageUrl;
  final String? description;
  final String? barberId;
  final String? barberName;
  final String itemType;
  final Color? badgeColor;
  final double? width;
  final bool isGrid;

  const StoreProductCard({
    super.key,
    this.productId = '',
    required this.title,
    required this.brand,
    required this.price,
    this.oldPrice,
    required this.rating,
    this.badge,
    this.imageUrl,
    this.description,
    this.barberId,
    this.barberName,
    this.itemType = 'product',
    this.badgeColor,
    this.width,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _accentForProduct(title);
    final foreground = accent.withValues(alpha: 0.92);

    void addToCart() {
      StoreCartController.addItem(
        productId: productId,
        title: title,
        brand: brand,
        price: price,
        imageUrl: imageUrl,
        barberId: barberId,
        barberName: barberName,
        type: itemType,
      );

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title added to cart'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StoreProductDetailScreen(
            productId: productId,
            title: title,
            brand: brand,
            price: price,
            oldPrice: oldPrice,
            rating: rating,
            badge: badge,
            imageUrl: imageUrl,
            description: description,
            barberId: barberId,
            barberName: barberName,
            itemType: itemType,
          ),
        ),
      ),
      child: Container(
        width: width,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: isGrid ? 138 : 150,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: 0.16),
                    accent.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildProductImage(foreground),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: addToCart,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.add_shopping_cart_outlined,
                          color: foreground,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              brand,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 11),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          price,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (oldPrice != null) ...[
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            oldPrice!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(Color foreground) {
    final url = imageUrl;
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Center(
          child: Icon(
            _iconForProduct(title),
            color: foreground,
            size: isGrid ? 38 : 44,
          ),
        ),
        errorWidget: (context, url, error) => Center(
          child: Icon(
            _iconForProduct(title),
            color: foreground,
            size: isGrid ? 38 : 44,
          ),
        ),
      );
    }

    return Center(
      child: Icon(
        _iconForProduct(title),
        color: foreground,
        size: isGrid ? 38 : 44,
      ),
    );
  }

  IconData _iconForProduct(String title) {
    final normalized = title.toLowerCase();
    if (normalized.contains('beard') || normalized.contains('oil')) {
      return Icons.spa_outlined;
    }
    if (normalized.contains('pomade') || normalized.contains('wax')) {
      return Icons.auto_awesome_outlined;
    }
    if (normalized.contains('shampoo') || normalized.contains('care')) {
      return Icons.water_drop_outlined;
    }
    if (normalized.contains('trimmer') || normalized.contains('kit')) {
      return Icons.content_cut_outlined;
    }
    return Icons.shopping_bag_outlined;
  }

  Color _accentForProduct(String title) {
    final normalized = title.toLowerCase();
    if (normalized.contains('beard') || normalized.contains('oil')) {
      return const Color(0xFF8B5E3C);
    }
    if (normalized.contains('pomade') || normalized.contains('wax')) {
      return const Color(0xFF6C63FF);
    }
    if (normalized.contains('shampoo') || normalized.contains('care')) {
      return AppColors.primary;
    }
    if (normalized.contains('trimmer') || normalized.contains('kit')) {
      return const Color(0xFF455A64);
    }
    return AppColors.primary;
  }
}

// ==========================================
// 3. PRODUCT DETAIL SCREEN
// ==========================================
class StoreProductDetailScreen extends StatefulWidget {
  final String productId;
  final String title;
  final String brand;
  final String price;
  final String? oldPrice;
  final String rating;
  final String? badge;
  final String? imageUrl;
  final String? description;
  final String? barberId;
  final String? barberName;
  final String itemType;

  const StoreProductDetailScreen({
    super.key,
    this.productId = '',
    required this.title,
    required this.brand,
    required this.price,
    this.oldPrice,
    required this.rating,
    this.badge,
    this.imageUrl,
    this.description,
    this.barberId,
    this.barberName,
    this.itemType = 'product',
  });

  @override
  State<StoreProductDetailScreen> createState() =>
      _StoreProductDetailScreenState();
}

class _StoreProductDetailScreenState extends State<StoreProductDetailScreen> {
  int _quantity = 1;

  String get _favoriteId => widget.productId.isNotEmpty
      ? widget.productId
      : '${widget.brand}_${widget.title}'.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

  DocumentReference<Map<String, dynamic>>? _favoriteRef() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(_favoriteId);
  }

  Future<void> _toggleFavorite(bool isFavorite) async {
    final ref = _favoriteRef();
    if (ref == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to save favorites')),
      );
      return;
    }

    if (isFavorite) {
      await ref.delete();
    } else {
      await ref.set({
        'id': _favoriteId,
        'productId': widget.productId,
        'title': widget.title,
        'brand': widget.brand,
        'price': widget.price,
        'oldPrice': widget.oldPrice,
        'rating': widget.rating,
        'imageUrl': widget.imageUrl,
        'description': widget.description,
        'type': 'product',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 420,
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.imageUrl == null || widget.imageUrl!.isEmpty)
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFEEF6F6), Color(0xFFDCEBEB)],
                        ),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.primary,
                        size: 96,
                      ),
                    )
                  else
                    CachedNetworkImage(
                      imageUrl: widget.imageUrl!,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      placeholder: (context, url) => Container(
                        color: AppColors.primaryLight,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.primaryLight,
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: AppColors.primary,
                          size: 96,
                        ),
                      ),
                    ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x99000000),
                          Color(0x00000000),
                          Color(0x66000000),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: topPadding + 8,
                    left: 16,
                    child: _buildHeaderIcon(
                      icon: Icons.arrow_back_ios_new,
                      onTap: (_) => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    top: topPadding + 8,
                    right: 16,
                    child: Row(
                      children: [
                        _buildHeaderIcon(
                          icon: Icons.favorite_border,
                          activeIcon: Icons.favorite,
                          activeStream: _favoriteRef()?.snapshots(),
                          onTap: _toggleFavorite,
                        ),
                        const SizedBox(width: 10),
                        ValueListenableBuilder<List<StoreCartItem>>(
                          valueListenable: StoreCartController.items,
                          builder: (context, cartItems, _) {
                            final count = cartItems.fold<int>(
                              0,
                              (total, item) => total + item.quantity,
                            );

                            return _buildHeaderIcon(
                              icon: Icons.shopping_cart_outlined,
                              onTap: (_) => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const StoreCartScreen(),
                                ),
                              ),
                              badge: count > 0 ? '$count' : null,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4F6F8),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.brand,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7E0),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.rating,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              '234 reviews',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              widget.price,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        if (widget.oldPrice != null) ...[
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              widget.oldPrice!,
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildSectionCard(
                    title: 'Quantity',
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildQuantityBtn(Icons.remove, () {
                            if (_quantity > 1) setState(() => _quantity--);
                          }),
                          SizedBox(
                            width: 54,
                            child: Center(
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ),
                          _buildQuantityBtn(Icons.add, () {
                            setState(() => _quantity++);
                          }, isAdd: true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildSectionCard(
                    title: 'Description',
                    child: Text(
                      widget.description?.isNotEmpty == true
                          ? widget.description!
                          : 'Premium quality grooming product designed for the modern man. Made with natural ingredients for the best results. Suitable for all hair types.',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        height: 1.6,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: ElevatedButton.icon(
            onPressed: () {
              StoreCartController.addItem(
                productId: widget.productId,
                title: widget.title,
                brand: widget.brand,
                price: widget.price,
                imageUrl: widget.imageUrl,
                barberId: widget.barberId,
                barberName: widget.barberName,
                type: widget.itemType,
                quantity: _quantity,
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoreCartScreen()),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined, size: 20),
            label: Text('Add $_quantity to Cart'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 58),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon({
    required IconData icon,
    required void Function(bool isActive) onTap,
    IconData? activeIcon,
    Stream<DocumentSnapshot<Map<String, dynamic>>>? activeStream,
    String? badge,
  }) {
    Widget buildIcon(bool isActive) {
      return GestureDetector(
        onTap: () => onTap(isActive),
        child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Icon(
              isActive ? activeIcon ?? icon : icon,
              color: isActive ? AppColors.dangerRed : AppColors.textDark,
              size: 20,
            ),
            if (badge != null)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        ),
      );
    }

    if (activeStream == null) {
      return buildIcon(false);
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: activeStream,
      builder: (context, snapshot) => buildIcon(snapshot.data?.exists == true),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }



  Widget _buildQuantityBtn(
    IconData icon,
    VoidCallback onTap, {
    bool isAdd = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isAdd ? AppColors.primary : Colors.white,
          border: Border.all(
            color: isAdd ? AppColors.primary : AppColors.borderGrey,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isAdd ? Colors.white : AppColors.textDark,
        ),
      ),
    );
  }
}

// ==========================================
// 4. CART SCREEN
// ==========================================
class StoreCartScreen extends StatelessWidget {
  const StoreCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('app_settings')
          .doc('store')
          .snapshots(),
      builder: (context, settingsSnapshot) {
        final configuredDeliveryFee = StoreCartController.priceValue(
          settingsSnapshot.data?.data()?['deliveryFeeEgp']?.toString() ?? '0',
        );

        return ValueListenableBuilder<List<StoreCartItem>>(
          valueListenable: StoreCartController.items,
          builder: (context, cartItems, _) {
            final subtotal = StoreCartController.subtotal(cartItems);
            final deliveryFee = cartItems.isEmpty ? 0.0 : configuredDeliveryFee;
            final total = subtotal + deliveryFee;

            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text('My Cart'),
                centerTitle: true,
              ),
              body: Builder(
                builder: (context) {
          if (cartItems.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Your cart is empty',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ...cartItems.map(_buildCartItem),
                const SizedBox(height: 40),
                _buildSummaryRow('Subtotal', StoreCartController.formatEgp(subtotal)),
                _buildSummaryRow('Delivery Fee', StoreCartController.formatEgp(deliveryFee)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),
                _buildSummaryRow('Total', StoreCartController.formatEgp(total), isTotal: true),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
              ),
              bottomSheet: PrimaryBottomButton(
                text: 'Proceed to Checkout',
                onPressed: cartItems.isEmpty
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StoreCheckoutScreen()),
                        ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCartItem(StoreCartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderGrey),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.imageUrl?.isNotEmpty == true
                ? CachedNetworkImage(imageUrl: item.imageUrl!, fit: BoxFit.cover)
                : const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => StoreCartController.updateQuantity(item, 0),
                      child: const Icon(
                        Icons.delete_outline,
                        color: AppColors.textGrey,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.brand,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.price,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        _buildSmallBtn(Icons.remove, () {
                          StoreCartController.updateQuantity(item, item.quantity - 1);
                        }, false),
                        Container(
                          width: 30,
                          alignment: Alignment.center,
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _buildSmallBtn(
                          Icons.add,
                          () => StoreCartController.updateQuantity(item, item.quantity + 1),
                          true,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBtn(IconData icon, VoidCallback onTap, bool isAdd) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isAdd ? AppColors.primary : Colors.white,
          border: Border.all(
            color: isAdd ? AppColors.primary : AppColors.borderGrey,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 14,
          color: isAdd ? Colors.white : AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? AppColors.textDark : AppColors.textGrey,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? AppColors.primary : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. CHECKOUT SCREEN
// ==========================================
class StoreCheckoutScreen extends StatelessWidget {
  const StoreCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('app_settings')
          .doc('store')
          .snapshots(),
      builder: (context, settingsSnapshot) {
        final deliveryFee = StoreCartController.priceValue(
          settingsSnapshot.data?.data()?['deliveryFeeEgp']?.toString() ?? '0',
        );

        return ValueListenableBuilder<List<StoreCartItem>>(
          valueListenable: StoreCartController.items,
          builder: (context, cartItems, _) {
            final subtotal = StoreCartController.subtotal(cartItems);
            final total = subtotal + (cartItems.isEmpty ? 0 : deliveryFee);

            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text('Checkout'),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: AppColors.primary),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'راجع الطلب واضغط تأكيد. الإدارة أو الحلاق سيستلم تفاصيل الطلب تلقائيا في الرسائل.',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Order Summary',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderGrey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: cartItems.isEmpty
                          ? const Text(
                              'Your cart is empty',
                              style: TextStyle(color: AppColors.textGrey),
                            )
                          : Column(
                              children: cartItems
                                  .map(
                                    (item) => _buildOrderSummaryRow(
                                      '${item.title} x${item.quantity}',
                                      StoreCartController.formatEgp(
                                        StoreCartController.priceValue(item.price) * item.quantity,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Payment Method',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.payments_outlined, color: AppColors.primary),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Cash on Delivery',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Icon(Icons.check_circle, color: AppColors.primary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildPriceRow('Subtotal', StoreCartController.formatEgp(subtotal)),
                    _buildPriceRow(
                      'Delivery',
                      StoreCartController.formatEgp(cartItems.isEmpty ? 0 : deliveryFee),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(),
                    ),
                    _buildPriceRow('Total', StoreCartController.formatEgp(total), isTotal: true),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              bottomSheet: PrimaryBottomButton(
                text: 'Place Order',
                onPressed: cartItems.isEmpty
                    ? null
                    : () async {
                        final order = await StoreCartController.placeOrder(
                          deliveryFee: deliveryFee,
                        );
                        if (!context.mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StoreOrderSuccessScreen(order: order),
                          ),
                        );
                      },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderSummaryRow(String item, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          Text(
            price,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? AppColors.textDark : AppColors.textGrey,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? AppColors.primary : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 6. ORDER SUCCESS SCREEN
// ==========================================
class StoreOrderSuccessScreen extends StatelessWidget {
  final StoreOrderDraft? order;

  const StoreOrderSuccessScreen({super.key, this.order});

  StoreOrderDraft? get _currentOrder => order ?? StoreCartController.lastOrder;

  @override
  Widget build(BuildContext context) {
    final currentOrder = _currentOrder;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.successGreen,
                        size: 80,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Order Placed!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your order has been successfully\n'
                      'placed. You can track your order status\n'
                      'anytime.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textGrey, height: 1.5),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderGrey),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Order Details',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            'Order Number',
                            currentOrder?.orderNumber ?? 'Pending',
                            isBoldValue: true,
                          ),
                          _buildDetailRow(
                            'Estimated Delivery',
                            _estimatedDelivery(currentOrder?.createdAt),
                            isBoldValue: true,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            'Total',
                            StoreCartController.formatEgp(currentOrder?.total ?? 0),
                            isBoldValue: true,
                            valueColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/main-shell',
                        (route) => false,
                        arguments: {'initialIndex': 1},
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Continue Shopping',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _estimatedDelivery(DateTime? createdAt) {
    final base = createdAt ?? DateTime.now();
    final estimate = base.add(const Duration(days: 4));
    return '${estimate.year}-${estimate.month.toString().padLeft(2, '0')}-${estimate.day.toString().padLeft(2, '0')}';
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBoldValue = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

















