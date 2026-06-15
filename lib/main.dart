import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'core/services/get_it_service.dart';
import 'core/services/supabase_storage_service.dart';
import 'config/routes/app_router.dart';
import 'config/themes/app_theme.dart';
import 'features/splash/presentation/views/splash_view.dart';
import 'features/profile/presentation/cubit/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await SupabaseStorageService.initSupabase();

  setupGetIt();

  runApp(const BarberBookingApp());
}

class BarberBookingApp extends StatelessWidget {
  const BarberBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852), // iPhone 14 Pro size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => ProfileProvider())],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'حلاق - Barber Booking',
            theme: AppTheme.lightTheme,
            // Navigator Key من GetIt
            navigatorKey: getIt<GlobalKey<NavigatorState>>(),
            // App Router
            onGenerateRoute: AppRouter.onGenerateRoute,
            // Initial Route - Splash Screen
            initialRoute: SplashView.routeName,
          ),
        );
      },
    );
  }
}
