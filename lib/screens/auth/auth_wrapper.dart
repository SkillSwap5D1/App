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
    print('🟡 AuthWrapper.build() called');
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        print('🟡 AuthWrapper Consumer builder executing');
        print('   currentUser: ${authProvider.currentUser?.uid ?? "null"}');
        print('   isLoading: ${authProvider.isLoading}');
        print('   errorMessage: ${authProvider.errorMessage}');

        // Show loading only during initial auth state check (when we don't know if user is logged in)
        if (authProvider.isLoading && authProvider.currentUser == null) {
          print('🟡 AuthWrapper returning LOADING screen');
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
          );
        }

        // User is logged in - show home screen
        if (authProvider.currentUser != null) {
          print(
            '🟡 AuthWrapper returning HOME SHELL SCREEN (currentUser != null)',
          );
          return const HomeShellScreen();
        }

        // User is not logged in - show LoginScreen
        // This is the default state after sign out
        print('🟡 AuthWrapper returning LOGIN SCREEN (currentUser is null)');
        return const LoginScreen();
      },
    );
  }
}
