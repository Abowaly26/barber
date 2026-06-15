import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/core/services/get_it_service.dart';
import 'package:app/core/utils/color_manager.dart';
import 'package:app/core/utils/validators.dart';
import 'package:app/core/widgets/custom_snack_bar.dart';
import 'package:app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:app/features/auth/presentation/views/sign_up_view.dart';
import 'package:app/features/main_shell/presentation/views/main_shell_view.dart';
import 'package:app/features/profile/presentation/cubit/profile_provider.dart';

class SignInView extends StatelessWidget {
  static const String routeName = '/sign-in';

  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthCubit>(),
      child: const SignInViewBody(),
    );
  }
}

class SignInViewBody extends StatefulWidget {
  const SignInViewBody({super.key});

  @override
  State<SignInViewBody> createState() => _SignInViewBodyState();
}

class _SignInViewBodyState extends State<SignInViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _signInWithGoogle() {
    context.read<AuthCubit>().signInWithGoogle();
  }

  void _forgotPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showError(context, 'Please enter your email address first');
      return;
    }
    context.read<AuthCubit>().sendPasswordReset(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.backgroundColor,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Show success message
            showSuccess(context, 'Welcome back!');

            // Update ProfileProvider with user data
            context.read<ProfileProvider>().fetchUserProfile(
              state.userEntity.id,
            );

            // Navigate to MainShell after a short delay
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, MainShell.routeName);
              }
            });
          } else if (state is AuthError) {
            // Don't show error if user cancelled Google sign in
            if (state.message.contains('cancelled')) return;

            // Show error message
            showError(context, state.message);
          } else if (state is PasswordResetSent) {
            // Show success message for password reset
            showSuccess(
              context,
              'Password reset email sent! Check your inbox.',
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 80.h),
                        // Title
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: ColorManager.textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        // Subtitle
                        Text(
                          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: ColorManager.textSecondaryColor,
                          ),
                        ),
                        SizedBox(height: 40.h),

                        // Email Address Label
                        Text(
                          'Email Address',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: ColorManager.textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: ColorManager.textHintColor,
                            ),
                            filled: true,
                            fillColor: ColorManager.inputFillColor,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: ColorManager.borderColor,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(
                                color: ColorManager.authTealColor,
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(
                                color: ColorManager.errorColor,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(
                                color: ColorManager.errorColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: Validators.validateEmail,
                        ),
                        SizedBox(height: 20.h),

                        // Password Label
                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: ColorManager.textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: ColorManager.textHintColor,
                            ),
                            filled: true,
                            fillColor: ColorManager.inputFillColor,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () => setState(() {
                                _obscurePassword = !_obscurePassword;
                              }),
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: ColorManager.iconColor,
                                size: 20,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: ColorManager.borderColor,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(
                                color: ColorManager.authTealColor,
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(
                                color: ColorManager.errorColor,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(
                                color: ColorManager.errorColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: Validators.validatePassword,
                        ),
                        SizedBox(height: 12.h),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _forgotPassword,
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: ColorManager.authTealColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: !isLoading ? _signIn : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.authTealColor,
                              disabledBackgroundColor: ColorManager.borderColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? SizedBox(width: 24.w)
                                : Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: ColorManager.whiteColor,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // Or continue with
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                'Or continue with',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: ColorManager.textSecondaryColor,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Google Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: OutlinedButton.icon(
                            onPressed: isLoading ? null : _signInWithGoogle,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              side: BorderSide(
                                color: ColorManager.borderColor,
                                width: 1.5,
                              ),
                            ),
                            icon: SvgPicture.asset(
                              'assets/google_Icon.svg',
                              width: 24.w,
                              height: 24.h,
                            ),
                            label: Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: ColorManager.textPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: ColorManager.textSecondaryColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        SignUpView.routeName,
                                      );
                                    },
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: ColorManager.authTealColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),

              // Loading Overlay
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(32.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 48.w,
                            height: 48.h,
                            child: const CircularProgressIndicator(
                              color: ColorManager.authTealColor,
                              strokeWidth: 3,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Signing in...',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: ColorManager.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
