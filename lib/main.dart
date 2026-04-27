import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/listing_provider.dart';
import 'providers/request_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/home/home_shell_screen.dart';
import 'screens/browse/browse_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/notifications/notifications_screen.dart';

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
    return MultiProvider(
      providers: [
        // Auth provider must be first as others depend on it
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // All other providers
        ChangeNotifierProvider(create: (_) => ListingProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'SkillSwap',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/home': (context) => const HomeShellScreen(),
          '/browse': (context) => const BrowseScreen(),
          '/chat': (context) => const ChatListScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/notifications': (context) => const NotificationsScreen(),
        },
      ),
    );
  }
}