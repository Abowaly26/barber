import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/widgets/custom_text_field.dart';

void main() {
  group('CustomTextField Widget Tests', () {
    testWidgets('renders text field with label and hint', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          child: MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                label: 'Email',
                hint: 'Enter your email',
                textInputType: TextInputType.emailAddress,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('calls validator when form is validated', (
      WidgetTester tester,
    ) async {
      final formKey = GlobalKey<FormState>();
      String? validationError;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          child: MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: CustomTextField(
                  label: 'Name',
                  hint: 'Enter your name',
                  textInputType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      validationError = 'Name is required';
                      return validationError;
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(validationError, 'Name is required');
    });

    testWidgets('updates text when user types', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          child: MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                label: 'Username',
                hint: 'Enter username',
                textInputType: TextInputType.text,
                controller: controller,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'TestUser');
      expect(controller.text, 'TestUser');
    });

    testWidgets('renders with prefix and suffix icons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          child: MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                label: 'Search',
                hint: 'Search here',
                textInputType: TextInputType.text,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.clear),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });
  });
}
