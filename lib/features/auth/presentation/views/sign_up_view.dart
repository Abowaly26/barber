import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/core/services/get_it_service.dart';
import 'package:app/core/utils/color_manager.dart';
import 'package:app/core/utils/validators.dart';
import 'package:app/core/widgets/custom_snack_bar.dart';
import 'package:app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:app/features/auth/presentation/views/sign_in_view.dart';
import 'package:app/features/main_shell/presentation/views/main_shell_view.dart';
import 'package:app/features/profile/presentation/cubit/profile_provider.dart';

class SignUpView extends StatelessWidget {
  static const String routeName = '/sign-up';

  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthCubit>(),
      child: const SignUpViewBody(),
    );
  }
}

class SignUpViewBody extends StatefulWidget {
  const SignUpViewBody({super.key});

  @override
  State<SignUpViewBody> createState() => _SignUpViewBodyState();
}

class _SignUpViewBodyState extends State<SignUpViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
    }
  }

  void _signInWithGoogle() {
    context.read<AuthCubit>().signInWithGoogle();
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: ColorManager.textPrimaryColor,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: ColorManager.textHintColor,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: ColorManager.inputFillColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: ColorManager.borderColor, width: 1),
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.backgroundColor,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Show success message
            showSuccess(context, 'Account created successfully!');

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
                        SizedBox(height: 60.h),
                        // Title
                        Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: ColorManager.textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        // Subtitle
                        Text(
                          'Create your account now to access all the exclusive benefits we have to offer.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: ColorManager.textSecondaryColor,
                          ),
                        ),
                        SizedBox(height: 40.h),

                        // Email Address
                        _buildTextField(
                          label: 'Email Address',
                          hint: 'Enter your email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 20.h),

                        // Password
                        _buildTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: Validators.validatePassword,
                          textInputAction: TextInputAction.next,
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
                        ),
                        SizedBox(height: 20.h),

                        // Confirm Password
                        _buildTextField(
                          label: 'Confirm Password',
                          hint: 'Enter your confirm password',
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          validator: (value) =>
                              Validators.validatePasswordConfirmation(
                                _passwordController.text,
                                value,
                              ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _signUp(),
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            }),
                            child: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: ColorManager.iconColor,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.authTealColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? SizedBox(
                                    width: 24.w,
                                    height: 24.h,
                                    child: const CircularProgressIndicator(
                                      color: ColorManager.whiteColor,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'Sign Up',
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

                        // Google Sign Up Button
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
                              'Sign up with Google',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: ColorManager.textPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
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
                                        SignInView.routeName,
                                      );
                                    },
                              child: Text(
                                'Login',
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
                            'Creating account...',
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
