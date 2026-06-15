import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:app/core/utils/color_manager.dart';
import 'package:app/features/auth/presentation/views/sign_in_view.dart';
import 'package:app/features/main_shell/presentation/views/main_shell_view.dart';
import 'package:app/features/profile/presentation/cubit/profile_provider.dart';

class SplashView extends StatefulWidget {
  static const String routeName = '/splash';

  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Minimum display time: 2 seconds
    final minDisplayTime = Future.delayed(const Duration(seconds: 2));

    // Wait for minimum display time
    await minDisplayTime;

    // Check if user is already logged in
    final currentUser = FirebaseAuth.instance.currentUser;

    // Navigate based on auth state
    if (mounted) {
      if (currentUser != null) {
        // User is already logged in, fetch profile and go to home
        await context.read<ProfileProvider>().fetchUserProfile(currentUser.uid);
        if (mounted) {
          Navigator.pushReplacementNamed(context, MainShell.routeName);
        }
      } else {
        // User is not logged in, go to sign in
        Navigator.pushReplacementNamed(context, SignInView.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF458189),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Image.asset(
              'assets/removebg-preview.png',
              width: 200.w,
              height: 200.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24.h),
            // App Name
            Text(
              'QUTI',
              style: TextStyle(
                fontSize: 48.sp,
                fontWeight: FontWeight.bold,
                color: ColorManager.whiteColor,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
