// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:app/core/services/get_it_service.dart';
import 'package:app/features/quti_shared/quti_shared.dart';
import 'package:app/features/profile/presentation/cubit/profile_provider.dart';
import 'package:app/features/profile/presentation/views/edit_profile_view.dart';
import 'package:app/features/profile/presentation/views/favorites_view.dart';
import 'package:app/features/profile/presentation/views/help_support_view.dart';
import 'package:app/features/profile/presentation/views/notifications_view.dart';
import 'package:app/features/profile/presentation/views/settings_view.dart';
import 'package:app/features/auth/domain/repos/auth_repo.dart';
import 'package:app/features/auth/presentation/views/sign_in_view.dart';

/// Professional Profile Tab — replaces the old _ProfileTab placeholder.
class ProfileView extends StatelessWidget {
  static const String routeName = '/profile';

  const ProfileView({super.key});

  Future<void> _signOut(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Sign Out',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.dangerRed),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && context.mounted) {
      final authRepo = getIt<AuthRepo>();
      await authRepo.signOut();

      if (context.mounted) {
        context.read<ProfileProvider>().clearUser();
        Navigator.pushNamedAndRemoveUntil(
          context,
          SignInView.routeName,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Column(
            children: [
              SizedBox(height: 26.h),
              _buildProfileHeader(context),
              SizedBox(height: 28.h),
              _buildStatsRow(context),
              SizedBox(height: 28.h),
              _buildSectionTitle('Account'),
              SizedBox(height: 10.h),
              _MenuCard(
                children: [
                  _MenuItem(
                    icon: Icons.person_outline,
                    iconBgColor: const Color(0xFFF0F7F7),
                    iconColor: AppColors.primary,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileView(),
                      ),
                    ),
                  ),
                  _MenuDivider(),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _getUnreadNotificationsStream(),
                    builder: (context, snapshot) {
                      final unreadCount = snapshot.data?.docs.length ?? 0;
                      return _MenuItem(
                        icon: Icons.notifications_outlined,
                        iconBgColor: const Color(0xFFFFF8E1),
                        iconColor: const Color(0xFFF5A623),
                        title: 'Notifications',
                        subtitle: 'Manage your alerts',
                        badge: unreadCount > 0 ? unreadCount : null,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsView(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 24.h),
              _buildSectionTitle('General'),
              SizedBox(height: 10.h),
              _MenuCard(
                children: [
                  _MenuItem(
                    icon: Icons.favorite_outline,
                    iconBgColor: const Color(0xFFFFEBEE),
                    iconColor: AppColors.dangerRed,
                    title: 'Favorites',
                    subtitle: 'Your saved items',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FavoritesView()),
                    ),
                  ),
                  _MenuDivider(),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    iconBgColor: const Color(0xFFF3E5F5),
                    iconColor: const Color(0xFFAB47BC),
                    title: 'Settings',
                    subtitle: 'App preferences & privacy',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsView()),
                    ),
                  ),
                  _MenuDivider(),
                  _MenuItem(
                    icon: Icons.help_outline,
                    iconBgColor: const Color(0xFFE3F2FD),
                    iconColor: const Color(0xFF42A5F5),
                    title: 'Help & Support',
                    subtitle: 'FAQs & contact us',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpSupportView(),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),
              _buildSectionTitle('About'),
              SizedBox(height: 10.h),
              _MenuCard(
                children: [
                  _MenuItem(
                    icon: Icons.shield_outlined,
                    iconBgColor: const Color(0xFFE8F5E9),
                    iconColor: AppColors.successGreen,
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your data',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpSupportView(
                          initialTopic: 'Privacy Policy',
                        ),
                      ),
                    ),
                  ),
                  _MenuDivider(),
                  _MenuItem(
                    icon: Icons.description_outlined,
                    iconBgColor: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFF9800),
                    title: 'Terms of Service',
                    subtitle: 'Terms and conditions',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpSupportView(
                          initialTopic: 'Terms of Service',
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 26.h),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE9EB),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18.r),
                    onTap: () => _signOut(context),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 18.h,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: AppColors.dangerRed,
                            size: 22.w,
                          ),
                          SizedBox(width: 14.w),
                          Text(
                            'Sign Out',
                            style: TextStyle(
                              color: AppColors.dangerRed,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.dangerRed,
                            size: 22.w,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 18.h),
              Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 12.sp, color: AppColors.textGrey),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── Profile Header ──
  Widget _buildProfileHeader(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        final user = provider.currentUser;
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.14),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 54.r,
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      backgroundImage:
                          user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                          ? CachedNetworkImageProvider(user.photoUrl!)
                          : null,
                      child: user?.photoUrl == null || user!.photoUrl!.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 54.w,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    user?.name ?? 'Guest User',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    user?.email ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 8.w,
              top: 8.h,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileView()),
                ),
                child: Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: AppColors.primary,
                    size: 19.w,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Stats Row ──
  Widget _buildStatsRow(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_today_outlined,
            iconColor: AppColors.primary,
            label: 'Bookings',
            stream: currentUser != null
                ? FirebaseFirestore.instance
                      .collection('appointments')
                      .where('customerId', isEqualTo: currentUser.uid)
                      .snapshots()
                : null,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatCard(
            icon: Icons.favorite_outline,
            iconColor: AppColors.dangerRed,
            label: 'Favorites',
            stream: currentUser != null
                ? FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.uid)
                      .collection('favorites')
                      .snapshots()
                : null,
          ),
        ),
      ],
    );
  }

  // ── Section Title ──
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textGrey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ── Unread Notifications Stream ──
  Stream<QuerySnapshot<Map<String, dynamic>>> _getUnreadNotificationsStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .snapshots();
  }
}

// ============================================================
// REUSABLE SUB-WIDGETS
// ============================================================

/// A white card containing menu items
class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

/// A single menu item row
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final int? badge;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: iconColor, size: 22.w),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '$badge',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Icon(
                Icons.chevron_right,
                color: AppColors.textGrey.withOpacity(0.6),
                size: 22.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Divider between menu items
class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.borderGrey.withOpacity(0.4),
      ),
    );
  }
}

/// A stat card with icon and count (from stream) or date
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Stream<QuerySnapshot<Map<String, dynamic>>>? stream;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22.w),
          SizedBox(height: 8.h),
          if (stream != null)
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: stream!,
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                return Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                );
              },
            )
          else
            Text(
              '0',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
