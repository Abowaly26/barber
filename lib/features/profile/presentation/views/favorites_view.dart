// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:app/features/quti_shared/quti_shared.dart';

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
                    return ListTile(
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.dangerRed.withOpacity(0.12),
                        child: const Icon(
                          Icons.favorite,
                          color: AppColors.dangerRed,
                        ),
                      ),
                      title: Text(
                        data['title']?.toString() ??
                            data['name']?.toString() ??
                            'Favorite item',
                      ),
                      subtitle: Text(data['type']?.toString() ?? 'Saved item'),
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
