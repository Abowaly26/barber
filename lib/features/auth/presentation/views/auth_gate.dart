import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/features/auth/presentation/views/sign_in_view.dart';
import 'package:app/features/main_shell/presentation/views/main_shell_view.dart';

/// Auth Gate - decides whether to show login or home based on auth state
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static const String routeName = '/auth-gate';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in, show MainShell (Home)
        if (snapshot.hasData && snapshot.data != null) {
          return const MainShell();
        }

        // Otherwise, show SignIn screen
        return const SignInView();
      },
    );
  }
}
