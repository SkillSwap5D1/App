import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';
import '../home/home_shell_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading while checking auth state
        if (authProvider.isLoading && authProvider.currentUser == null) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.accent,
                ),
              ),
            ),
          );
        }

        // User is logged in
        if (authProvider.currentUser != null) {
          return const HomeShellScreen();
        }

        // User is not logged in - show LoginScreen first
        return const LoginScreen();
      },
    );
  }
}
