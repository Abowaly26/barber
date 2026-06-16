import 'package:flutter/material.dart';
import 'package:app/features/splash/presentation/views/splash_view.dart';
import 'package:app/features/auth/presentation/views/sign_in_view.dart';
import 'package:app/features/auth/presentation/views/sign_up_view.dart';
import 'package:app/features/category_selection/presentation/views/category_selection_view.dart';
import 'package:app/features/booking_type/presentation/views/booking_type_view.dart';
import 'package:app/features/main_shell/presentation/views/main_shell_view.dart';
import 'package:app/features/available_times/presentation/views/available_times_view.dart';
import 'package:app/features/chat/presentation/views/chat_room_view.dart';
import 'package:app/features/booking/presentation/views/booking_home_screen.dart';
import 'package:app/features/booking/presentation/views/book_service_screen.dart';
import 'package:app/features/booking/presentation/views/select_date_time_screen.dart';
import 'package:app/features/booking/presentation/views/booking_review_screen.dart';
import 'package:app/features/booking/presentation/views/booking_success_screen.dart';

class AppRouter {
  AppRouter._();

  /// Generate routes for the application
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Root route - redirect to splash
      case '/':
        return MaterialPageRoute(
          builder: (_) => const SplashView(),
          settings: settings,
        );

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

      // Booking Feature
      case BookingHomeScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const BookingHomeScreen(),
          settings: settings,
        );

      case BookServiceScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const BookServiceScreen(),
          settings: settings,
        );

      case SelectDateTimeScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const SelectDateTimeScreen(),
          settings: settings,
        );

      case BookingReviewScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const BookingReviewScreen(),
          settings: settings,
        );

      case BookingSuccessScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const BookingSuccessScreen(),
          settings: settings,
        );

      case AvailableTimesView.routeName:
        return MaterialPageRoute(
          builder: (_) => const AvailableTimesView(),
          settings: settings,
        );

      case ChatRoomView.routeName:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => ChatRoomView(
            chatId: args['chatId'],
            barberId: args['barberId'] ?? '',
            barberName: args['barberName'] ?? '',
            slotDetails: args['slotDetails'],
          ),
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

