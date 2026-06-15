import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Navigation Service for centralized navigation management
/// Uses GetIt to access the GlobalKey<NavigatorState>
class NavigationService {
  /// Get the navigator key from GetIt
  GlobalKey<NavigatorState> get navigatorKey =>
      GetIt.instance<GlobalKey<NavigatorState>>();

  /// Navigate to a named route
  ///
  /// [routeName] - The name of the route to navigate to
  /// [arguments] - Optional arguments to pass to the route
  ///
  /// Returns a Future that completes with the result value when the route is popped
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate to a named route and replace the current route
  ///
  /// [routeName] - The name of the route to navigate to
  /// [arguments] - Optional arguments to pass to the route
  ///
  /// Returns a Future that completes with the result value when the new route is popped
  Future<dynamic> navigateAndReplace(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate to a named route and remove all previous routes
  ///
  /// [routeName] - The name of the route to navigate to
  /// [arguments] - Optional arguments to pass to the route
  ///
  /// Returns a Future that completes with the result value when the new route is popped
  Future<dynamic> navigateAndRemoveUntil(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Go back to the previous route
  ///
  /// Pops the current route off the navigation stack
  void goBack() {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState!.pop();
    }
  }

  /// Go back with a result value
  ///
  /// [result] - The result value to pass back to the previous route
  void goBackWithResult<T>([T? result]) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState!.pop(result);
    }
  }
}
