import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/home/home_shell_screen.dart';
import 'screens/browse/browse_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/reviews/rate_review_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        '/register':    (context) => const RegisterScreen(),
        '/onboarding':  (context) => const OnboardingScreen(),
        '/home':        (context) => const HomeShellScreen(),
        '/browse':      (context) => const BrowseScreen(),
        '/chat':        (context) => const ChatListScreen(),
        '/profile':     (context) => const ProfileScreen(),
        '/edit-profile':(context) => const EditProfileScreen(),
        '/rate-review': (context) => const RateReviewScreen(
          skillTitle: 'Placeholder Skill',
          otherUserName: 'Placeholder User',
          sessionDate: 'Placeholder Date',
        ),
      },
    );
  }
}