// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:app/features/quti_shared/quti_shared.dart';
import 'package:app/features/store_flow/presentation/views/store_flow_view.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>>? _stream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final stream = _stream();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        title: Text(
          'Favorites',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
        ),
      ),
      body: stream == null
          ? const _EmptyFavorites(message: 'Please sign in to view favorites.')
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const _EmptyFavorites(
                    message:
                        'Saved barbers, products, and services will appear here.',
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: docs.length,
                  separatorBuilder: (_, _) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final favoriteRef = docs[index].reference;
                    final imageUrl = data['imageUrl']?.toString() ?? '';
                    final title = data['title']?.toString() ??
                        data['name']?.toString() ??
                        'Favorite item';
                    final brand = data['brand']?.toString() ?? 'QUTI Store';
                    final price = data['price']?.toString() ?? '';
                    final oldPrice = data['oldPrice']?.toString();
                    final rating = data['rating']?.toString() ?? '4.8';
                    final description = data['description']?.toString();
                    final productId = data['productId']?.toString() ?? data['id']?.toString() ?? favoriteRef.id;

                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16.r),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StoreProductDetailScreen(
                              productId: productId,
                              title: title,
                              brand: brand,
                              price: price,
                              oldPrice: oldPrice?.isEmpty == true ? null : oldPrice,
                              rating: rating,
                              imageUrl: imageUrl,
                              description: description,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        width: 64.w,
                                        height: 64.w,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 64.w,
                                        height: 64.w,
                                        color: AppColors.primaryLight,
                                        child: const Icon(
                                          Icons.shopping_bag_outlined,
                                          color: AppColors.primary,
                                        ),
                                      ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      brand,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                    if (price.isNotEmpty) ...[
                                      SizedBox(height: 6.h),
                                      Text(
                                        price,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => favoriteRef.delete(),
                                icon: const Icon(
                                  Icons.favorite,
                                  color: AppColors.dangerRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64.w,
              color: AppColors.textGrey.withOpacity(0.45),
            ),
            SizedBox(height: 16.h),
            Text(
              'No favorites yet',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}
