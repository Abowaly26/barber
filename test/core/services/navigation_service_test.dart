import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

// Mock imports - adjust path based on your project structure
import 'package:app/core/services/navigation_service.dart';

void main() {
  late NavigationService navigationService;
  late GlobalKey<NavigatorState> navigatorKey;
  late GetIt getIt;

  setUp(() {
    // Reset GetIt before each test
    getIt = GetIt.instance;
    getIt.reset();

    // Register NavigatorKey
    navigatorKey = GlobalKey<NavigatorState>();
    getIt.registerSingleton<GlobalKey<NavigatorState>>(navigatorKey);

    // Create NavigationService
    navigationService = NavigationService();
  });

  tearDown(() {
    getIt.reset();
  });

  group('NavigationService', () {
    test('should get navigatorKey from GetIt', () {
      // Act
      final key = navigationService.navigatorKey;

      // Assert
      expect(key, equals(navigatorKey));
      expect(key, isA<GlobalKey<NavigatorState>>());
    });

    test('should access navigatorKey without throwing', () {
      // Assert
      expect(() => navigationService.navigatorKey, returnsNormally);
    });
  });

  group('Navigation Methods', () {
    testWidgets(
      'navigateTo should call pushNamed when navigator is available',
      (WidgetTester tester) async {
        // Arrange
        bool routeCalled = false;
        String? calledRouteName;
        Object? calledArguments;

        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            onGenerateRoute: (settings) {
              routeCalled = true;
              calledRouteName = settings.name;
              calledArguments = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('Test Route')),
              );
            },
            home: const Scaffold(body: Text('Home')),
          ),
        );

        // Act
        navigationService.navigateTo('/test', arguments: {'key': 'value'});
        await tester.pumpAndSettle();

        // Assert
        expect(routeCalled, isTrue);
        expect(calledRouteName, equals('/test'));
        expect(calledArguments, equals({'key': 'value'}));
      },
    );

    testWidgets(
      'navigateAndReplace should call pushReplacementNamed when navigator is available',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: navigatorKey,
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (_) => Scaffold(body: Text('Route: ${settings.name}')),
              );
            },
            home: const Scaffold(body: Text('Home')),
          ),
        );

        // Act
        navigationService.navigateAndReplace('/replaced');
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Route: /replaced'), findsOneWidget);
        expect(find.text('Home'), findsNothing);
      },
    );

    testWidgets('navigateAndRemoveUntil should remove all previous routes', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(body: Text('Route: ${settings.name}')),
            );
          },
          home: const Scaffold(body: Text('Home')),
        ),
      );

      // Navigate to multiple routes
      navigationService.navigateTo('/first');
      await tester.pumpAndSettle();
      navigationService.navigateTo('/second');
      await tester.pumpAndSettle();

      // Act - Clear stack and navigate to final route
      navigationService.navigateAndRemoveUntil('/final');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Route: /final'), findsOneWidget);

      // Try to go back - should not be able to
      navigationService.goBack();
      await tester.pumpAndSettle();

      // Still on final route (can't go back)
      expect(find.text('Route: /final'), findsOneWidget);
    });

    testWidgets('goBack should pop the current route when possible', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(body: Text('Route: ${settings.name}')),
            );
          },
          home: const Scaffold(body: Text('Home')),
        ),
      );

      // Navigate to a new route
      navigationService.navigateTo('/test');
      await tester.pumpAndSettle();
      expect(find.text('Route: /test'), findsOneWidget);

      // Act
      navigationService.goBack();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Route: /test'), findsNothing);
    });

    testWidgets('goBack should not throw when cannot pop', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Text('Home')),
        ),
      );

      // Act & Assert - Should not throw even when can't pop
      expect(() => navigationService.goBack(), returnsNormally);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('goBackWithResult should pop with result value', (
      WidgetTester tester,
    ) async {
      // Arrange
      Object? receivedResult;

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    navigationService.goBackWithResult({'status': 'success'});
                  },
                  child: const Text('Go Back'),
                ),
              ),
            );
          },
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                receivedResult = await navigationService.navigateTo('/test');
              },
              child: const Text('Navigate'),
            ),
          ),
        ),
      );

      // Navigate to test route
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Act - Tap go back button
      await tester.tap(find.text('Go Back'));
      await tester.pumpAndSettle();

      // Assert
      expect(receivedResult, equals({'status': 'success'}));
    });
  });
}
