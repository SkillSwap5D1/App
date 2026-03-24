import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/browse/browse_screen.dart';
import 'screens/listings/listing_detail_screen.dart';
import 'screens/requests/send_request_screen.dart';
import 'data/mock_data.dart';

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
      home: const BrowseScreen(),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
          case '/browse':
            return MaterialPageRoute(
              builder: (_) => const BrowseScreen(),
            );
          case '/listing-detail':
            final listing = settings.arguments as MockListing?;
            return MaterialPageRoute(
              builder: (_) => ListingDetailScreen(
                listing: listing ?? _sampleListing,
              ),
            );
          case '/send-request':
            final listing = settings.arguments as MockListing?;
            return MaterialPageRoute(
              builder: (_) => SendRequestScreen(
                listing: listing ?? _sampleListing,
              ),
            );
          case '/profile':
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                  child: Text('Profile Screen (Coming Soon)'),
                ),
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const BrowseScreen(),
            );
        }
      },
    );
  }

  static final _sampleListing = MockListing(
    id: 'skill_001',
    ownerId: 'user_001',
    ownerName: 'Sarah Anderson',
    ownerRating: 4.8,
    ownerReviewCount: 24,
    title: 'Web Development Bootcamp',
    description: 'Learn modern web development with React and Node.js.',
    tags: ['React', 'JavaScript', 'Web Development'],
    level: 'Intermediate',
    modality: 'Online',
    category: 'Programming',
    nextAvailable: 'Tomorrow, 3 PM',
    isBookmarked: false,
  );
}
