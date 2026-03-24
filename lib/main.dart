import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/browse/browse_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/profile/edit_profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillSwap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginScreen(),
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/browse': (context) => const BrowseScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
      },
    );
  }
}
