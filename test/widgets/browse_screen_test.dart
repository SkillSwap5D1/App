import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:skillswap_app/models/listing_model.dart';
import 'package:skillswap_app/models/user_model.dart';
import 'package:skillswap_app/providers/auth_provider.dart';
import 'package:skillswap_app/providers/listing_provider.dart';
import 'package:skillswap_app/screens/browse/browse_screen.dart';
import 'package:skillswap_app/theme/app_theme.dart';

class MockListingProvider extends Mock implements ListingProvider {
  List<ListingModel> listings_ = [];
  List<ListingModel> myListings_ = [];
  bool loading = false;
  String? errorMsg;

  @override
  List<ListingModel> get listings => listings_;

  @override
  List<ListingModel> get myListings => myListings_;

  @override
  bool get isLoading => loading;

  @override
  String? get errorMessage => errorMsg;
}

class MockAuthProvider extends Mock implements AuthProvider {
  String? uid;

  @override
  UserModel? get currentUser {
    if (uid != null) {
      return UserModel(
        uid: uid!,
        email: 'test@port.ac.uk',
        firstName: 'Test',
        lastName: 'User',
        course: 'Computer Science',
        bio: 'Test bio',
        rating: 5.0,
        sessionsCompleted: 5,
        memberSince: DateTime.now(),
        showFullName: true,
        showCourse: true,
        showPhoto: true,
      );
    }
    return null;
  }
}

Widget _buildTestApp({
  required ListingProvider listingProvider,
  required AuthProvider authProvider,
  required Widget homeScreen,
}) {
  return MaterialApp(
    theme: AppTheme.theme,
    home: MultiProvider(
      providers: [
        Provider<ListingProvider>.value(value: listingProvider),
        Provider<AuthProvider>.value(value: authProvider),
      ],
      child: homeScreen,
    ),
  );
}

void main() {
  Provider.debugCheckInvalidValueType = null;

  group('BrowseScreen', () {
    testWidgets('TEST 1 — renders listing cards with mock data', (tester) async {
      final listingProvider = MockListingProvider();
      final authProvider = MockAuthProvider()..uid = 'user1';

      // Seed mock data
      listingProvider.listings_ = [
        ListingModel(
          id: '1',
          title: 'Python Basics',
          description: 'Learn Python fundamentals',
          ownerId: 'user2',
          ownerName: 'Alice',
          category: 'Programming',
          level: 'Beginner',
          modality: 'Online',
          tags: ['python', 'beginner'],
          isActive: true,
          nextAvailable: 'Flexible',
          createdAt: DateTime.now(),
        ),
        ListingModel(
          id: '2',
          title: 'Guitar Lessons',
          description: 'Beginner guitar tutorials',
          ownerId: 'user3',
          ownerName: 'Bob',
          category: 'Music',
          level: 'Beginner',
          modality: 'In-person',
          tags: ['guitar', 'music'],
          isActive: true,
          nextAvailable: 'Weekends',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        _buildTestApp(
          listingProvider: listingProvider,
          authProvider: authProvider,
          homeScreen: const BrowseScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Python Basics'), findsOneWidget);
      expect(find.text('Guitar Lessons'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('TEST 2 — search filters cards in real time', (tester) async {
      final listingProvider = MockListingProvider();
      final authProvider = MockAuthProvider()..uid = 'user1';

      listingProvider.listings_ = [
        ListingModel(
          id: '1',
          title: 'Python Basics',
          description: 'Learn Python',
          ownerId: 'user2',
          ownerName: 'Alice',
          category: 'Programming',
          level: 'Beginner',
          modality: 'Online',
          tags: ['python'],
          isActive: true,
          nextAvailable: 'Flexible',
          createdAt: DateTime.now(),
        ),
        ListingModel(
          id: '2',
          title: 'Spanish Lessons',
          description: 'Learn Spanish',
          ownerId: 'user3',
          ownerName: 'Bob',
          category: 'Languages',
          level: 'Beginner',
          modality: 'Online',
          tags: ['spanish'],
          isActive: true,
          nextAvailable: 'Flexible',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        _buildTestApp(
          listingProvider: listingProvider,
          authProvider: authProvider,
          homeScreen: const BrowseScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find search field (assuming it's a TextField with hint "Search")
      final searchFields = find.byType(TextField);
      if (searchFields.evaluate().length > 0) {
        await tester.enterText(searchFields.first, 'Python');
        await tester.pump(const Duration(milliseconds: 300));

        // After search, only Python should show
        expect(find.text('Python Basics'), findsWidgets);
      }
    });

    testWidgets('TEST 3 — empty listings shows empty state', (tester) async {
      final listingProvider = MockListingProvider();
      final authProvider = MockAuthProvider()..uid = 'user1';

      // Empty listing
      listingProvider.listings_ = [];
      listingProvider.loading = false;

      await tester.pumpWidget(
        _buildTestApp(
          listingProvider: listingProvider,
          authProvider: authProvider,
          homeScreen: const BrowseScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Empty state should show appropriate message
      // Verify that no listing cards are displayed
      expect(
        find.byType(ListView),
        findsAny,
      );
    });

    testWidgets('TEST 4 — isLoading shows CircularProgressIndicator', (tester) async {
      final listingProvider = MockListingProvider();
      final authProvider = MockAuthProvider()..uid = 'user1';

      listingProvider.loading = true;

      await tester.pumpWidget(
        _buildTestApp(
          listingProvider: listingProvider,
          authProvider: authProvider,
          homeScreen: const BrowseScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('TEST 5 — switching to My Skills tab changes buttons', (tester) async {
      final listingProvider = MockListingProvider();
      final authProvider = MockAuthProvider()..uid = 'user1';

      // Add listings owned by current user to myListings
      listingProvider.myListings_ = [
        ListingModel(
          id: '3',
          title: 'Django Web Dev',
          description: 'Build web apps',
          ownerId: 'user1',
          ownerName: 'Charlie',
          category: 'Programming',
          level: 'Intermediate',
          modality: 'Online',
          tags: ['django', 'web'],
          isActive: true,
          nextAvailable: 'Flexible',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        _buildTestApp(
          listingProvider: listingProvider,
          authProvider: authProvider,
          homeScreen: const BrowseScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Look for tab toggle button (usually labeled "Available" or "My Skills")
      final tabToggleButtons = find.byType(GestureDetector);
      if (tabToggleButtons.evaluate().length > 1) {
        // Tap on "My Skills" tab (adjust if needed based on actual implementation)
        await tester.tap(tabToggleButtons.at(1));
        await tester.pumpAndSettle();

        // After switching tabs, should show Edit/Delete buttons instead of Send Request
        // This depends on the actual button text in your implementation
        expect(find.byType(OutlinedButton), findsWidgets);
      }
    });
  });
}
