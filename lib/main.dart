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
import 'providers/review_provider.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/home/home_shell_screen.dart';
import 'screens/browse/browse_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/chat/chat_thread_screen.dart';
import 'screens/listings/create_listing_screen.dart';
import 'screens/listings/listing_detail_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/requests/counter_offer_screen.dart';
import 'screens/requests/requests_screen.dart';
import 'screens/requests/send_request_screen.dart';
import 'screens/reviews/rate_review_screen.dart';
import 'screens/saved/saved_bookmarked_screen.dart';
import 'screens/safety/report_blocked_screen.dart';
import 'data/mock_data.dart';
import 'core/app_routes.dart';
import 'models/listing_model.dart';

ListingModel _listingFromMock(MockListing listing) {
  return ListingModel(
    id: listing.id,
    ownerId: listing.ownerId,
    ownerName: listing.ownerName,
    title: listing.title,
    description: listing.description,
    tags: listing.tags,
    level: listing.level,
    modality: listing.modality,
    category: listing.category,
    nextAvailable: listing.nextAvailable,
    isActive: true,
    createdAt: DateTime.now(),
  );
}

Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.listingDetail:
      final args = settings.arguments;
      final listing =
          args is ListingModel
              ? args
              : args is MockListing
              ? _listingFromMock(args)
              : ListingModel(
                id: '',
                ownerId: '',
                ownerName: 'Unknown',
                title: 'Listing',
                description: 'No listing data provided.',
                tags: const [],
                level: 'Beginner',
                modality: 'Online',
                category: 'General',
                nextAvailable: '',
                isActive: true,
                createdAt: DateTime.now(),
              );
      return MaterialPageRoute(
        builder: (_) => ListingDetailScreen(listing: listing),
      );
    case AppRoutes.createListing:
      final args = settings.arguments;
      final listing =
          args is ListingModel
              ? args
              : args is MockListing
              ? _listingFromMock(args)
              : null;
      return MaterialPageRoute(
        builder: (_) => CreateListingScreen(listing: listing),
      );
    case AppRoutes.sendRequest:
      final args = settings.arguments;
      final listing =
          args is ListingModel
              ? args
              : args is MockListing
              ? _listingFromMock(args)
              : ListingModel(
                id: '',
                ownerId: '',
                ownerName: 'Unknown',
                title: 'Request',
                description: 'No listing data provided.',
                tags: const [],
                level: 'Beginner',
                modality: 'Online',
                category: 'General',
                nextAvailable: '',
                isActive: true,
                createdAt: DateTime.now(),
              );
      return MaterialPageRoute(
        builder: (_) => SendRequestScreen(listing: listing),
      );
    case AppRoutes.requests:
      return MaterialPageRoute(builder: (_) => const RequestsScreen());
    case AppRoutes.saved:
      return MaterialPageRoute(builder: (_) => const SavedBookmarkedScreen());
    case AppRoutes.editProfile:
      return MaterialPageRoute(builder: (_) => const EditProfileScreen());
    case AppRoutes.rateReview:
      return MaterialPageRoute(
        builder: (_) => const RateReviewScreen(
          requestId: 'mock_request_id',
          skillTitle: 'Session',
          otherUserId: 'mock_other_user_id',
          otherUserName: 'User',
          sessionDate: 'Today',
        ),
      );
    case AppRoutes.counterOffer:
      final request =
          settings.arguments is MockRequest
              ? settings.arguments as MockRequest
              : MockData.incomingRequests.first;
      return MaterialPageRoute(
        builder: (_) => CounterOfferScreen(originalRequest: request),
      );
    case AppRoutes.chatThread:
      final args = settings.arguments;
      final conversationId =
          args is Map<String, dynamic>
              ? args['conversationId'] as String?
              : null;
      final otherUserId =
          args is Map<String, dynamic> ? args['otherUserId'] as String? : null;

      if (conversationId == null || otherUserId == null) {
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Missing chat route arguments')),
              ),
        );
      }

      return MaterialPageRoute(
        builder:
            (_) => ChatThreadScreen(
              conversationId: conversationId,
              otherUserId: otherUserId,
            ),
      );
    case AppRoutes.report:
      return MaterialPageRoute(
        builder:
            (_) => ReportBlockedScreen(
              userName: 'User',
              userId: '',
              onBlock: () {},
            ),
      );
  }
  return null;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
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
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }
}
