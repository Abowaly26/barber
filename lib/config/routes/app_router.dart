import 'package:flutter/material.dart';
import 'package:app/features/splash/presentation/views/splash_view.dart';
import 'package:app/features/auth/presentation/views/sign_in_view.dart';
import 'package:app/features/auth/presentation/views/sign_up_view.dart';
import 'package:app/features/category_selection/presentation/views/category_selection_view.dart';
import 'package:app/features/booking_type/presentation/views/booking_type_view.dart';
import 'package:app/features/main_shell/presentation/views/main_shell_view.dart';

class AppRouter {
  AppRouter._();

  /// Generate routes for the application
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Splash Screen
      case SplashView.routeName:
        return MaterialPageRoute(
          builder: (_) => const SplashView(),
          settings: settings,
        );

      // Main Shell (Home with bottom nav)
      case MainShell.routeName:
        return MaterialPageRoute(
          builder: (_) => const MainShell(),
          settings: settings,
        );

      // Category Selection (Legacy)
      case CategorySelectionView.routeName:
        return MaterialPageRoute(
          builder: (_) => const CategorySelectionView(),
          settings: settings,
        );

      // Authentication
      case SignInView.routeName:
        return MaterialPageRoute(
          builder: (_) => const SignInView(),
          settings: settings,
        );

      case SignUpView.routeName:
        return MaterialPageRoute(
          builder: (_) => const SignUpView(),
          settings: settings,
        );

      // Quti Store Flows
      case UserSelectionScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const UserSelectionScreen(),
          settings: settings,
        );

      case BookingTypeScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const BookingTypeScreen(),
          settings: settings,
        );

      // Default route
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
