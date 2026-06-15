// مثال على استخدام Core Widgets في شاشة تسجيل الدخول
// هذا الملف للمرجعية فقط ولن يتم استخدامه في التطبيق

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/widgets/custom_button.dart';
import 'package:app/core/widgets/custom_text_field.dart';
import 'package:app/core/widgets/password_field.dart';
import 'package:app/core/utils/validators.dart';

class ExampleLoginScreen extends StatefulWidget {
  const ExampleLoginScreen({super.key});

  @override
  State<ExampleLoginScreen> createState() => _ExampleLoginScreenState();
}

class _ExampleLoginScreenState extends State<ExampleLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // محاكاة عملية تسجيل الدخول
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // الانتقال للشاشة التالية
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email Field
              CustomTextField(
                label: 'البريد الإلكتروني',
                hint: 'أدخل بريدك الإلكتروني',
                textInputType: TextInputType.emailAddress,
                controller: _emailController,
                validator: Validators.validateEmail,
                prefixIcon: const Icon(Icons.email),
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 16.h),

              // Password Field
              PasswordField(
                label: 'كلمة المرور',
                hint: 'أدخل كلمة المرور',
                controller: _passwordController,
                validator: Validators.validatePassword,
                prefixIcon: const Icon(Icons.lock),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleLogin(),
              ),
              SizedBox(height: 24.h),

              // Login Button
              CustomButton(
                text: 'تسجيل الدخول',
                onPressed: _handleLogin,
                isLoading: _isLoading,
                prefixIcon: const Icon(Icons.login, color: Colors.white),
              ),
              SizedBox(height: 16.h),

              // Sign Up Button
              CustomButton(
                text: 'إنشاء حساب جديد',
                onPressed: () {
                  // الانتقال لشاشة التسجيل
                },
                isDisabled: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
