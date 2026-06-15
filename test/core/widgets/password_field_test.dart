import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/widgets/password_field.dart';

void main() {
  group('PasswordField Widget Tests', () {
    testWidgets('renders password field with label and hint', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          child: MaterialApp(
            home: Scaffold(
              body: PasswordField(
                label: 'Password',
                hint: 'Enter your password',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('toggles password visibility icon on tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          child: const MaterialApp(
            home: Scaffold(
              body: PasswordField(label: 'Password', hint: 'Enter password'),
            ),
          ),
        ),
      );

      // Initially visibility_off icon should be present
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap the visibility icon
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Now visibility icon should be present
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Tap again to hide
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Back to visibility_off icon
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
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
                child: PasswordField(
                  label: 'Password',
                  hint: 'Enter password',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      validationError = 'Password is required';
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

      expect(validationError, 'Password is required');
    });

    testWidgets('updates text when user types', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          child: MaterialApp(
            home: Scaffold(
              body: PasswordField(
                label: 'Password',
                hint: 'Enter password',
                controller: controller,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'SecurePass123');
      expect(controller.text, 'SecurePass123');
    });
  });
}
