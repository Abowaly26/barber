import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app/features/quti_shared/quti_shared.dart';
import 'package:app/core/widgets/profile_avatar.dart';
import 'package:app/features/profile/presentation/cubit/profile_provider.dart';

/// Home AppBar with user profile and notification badge
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.9),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35.r),
          bottomRight: Radius.circular(35.r),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            children: [
              // Profile Avatar
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  return ProfileAvatar(
                    imageUrl: provider.currentUser?.photoUrl,
                    userName: provider.currentUser?.name,
                    radius: 20.r,
                    showArc: false,
                    showEditOverlay: false,
                    isLoading: provider.isLoading,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    textColor: Colors.white,
                  );
                },
              ),
              SizedBox(width: 12.w),

              // Welcome Text
              Expanded(
                child: Consumer<ProfileProvider>(
                  builder: (context, provider, child) {
                    final userName = provider.currentUser?.name ?? '';
                    final displayName = userName.isEmpty
                        ? ''
                        : userName.length > 14
                        ? '${userName.substring(0, 11)}...'
                        : userName;

                    return Text(
                      displayName.isEmpty ? 'Hello!' : 'Hello, $displayName',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
