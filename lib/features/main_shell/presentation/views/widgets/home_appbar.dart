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

              // Notification Icon with Badge
              const _NotificationsBadgeIcon(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Notification icon with unread count badge
class _NotificationsBadgeIcon extends StatelessWidget {
  const _NotificationsBadgeIcon();

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    // Base notification icon
    final baseIcon = Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.notifications_outlined,
        color: Colors.white,
        size: 24.w,
      ),
    );

    // If no user is logged in, show only the icon
    if (uid == null) {
      return baseIcon;
    }

    // Stream to listen for unread notifications
    final unreadStream = FirebaseFirestore.instance
        .collection('users/$uid/notifications')
        .where('read', isEqualTo: false)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: unreadStream,
      builder: (context, snapshot) {
        final int count = snapshot.hasData ? snapshot.data!.docs.length : 0;

        // If count is 0, return only the icon
        if (count == 0) {
          return baseIcon;
        }

        // If count > 0, show badge
        return Badge(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          label: Text(
            count > 99 ? '99+' : '$count',
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
          ),
          child: baseIcon,
        );
      },
    );
  }
}
