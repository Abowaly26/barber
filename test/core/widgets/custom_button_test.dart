import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app/core/widgets/custom_button.dart';

void main() {
  group('CustomButton Widget Tests', () {
    testWidgets('renders button with text', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          child: MaterialApp(
            home: Scaffold(
              body: CustomButton(
                text: 'Test Button',
                onPressed: () {
                  pressed = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(pressed, false);

      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      expect(pressed, true);
    });

    testWidgets('shows loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          child: MaterialApp(
            home: Scaffold(
              body: CustomButton(
                text: 'Loading Button',
                onPressed: () {},
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Button'), findsNothing);
    });

    testWidgets('button is disabled when isDisabled is true', (
      WidgetTester tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          child: MaterialApp(
            home: Scaffold(
              body: CustomButton(
                text: 'Disabled Button',
                onPressed: () {
                  pressed = true;
                },
                isDisabled: true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      expect(pressed, false);
    });

    testWidgets('renders button with prefix and suffix icons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          child: MaterialApp(
            home: Scaffold(
              body: CustomButton(
                text: 'Icon Button',
                onPressed: () {},
                prefixIcon: const Icon(Icons.add),
                suffixIcon: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.text('Icon Button'), findsOneWidget);
    });
  });
}
