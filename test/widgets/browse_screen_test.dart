import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:skillswap_app/models/listing_model.dart';
import 'package:skillswap_app/models/user_model.dart';
import 'package:skillswap_app/providers/listing_provider.dart';
import 'package:skillswap_app/providers/auth_provider.dart';
import 'package:skillswap_app/screens/browse/browse_screen.dart';
import 'package:skillswap_app/theme/app_theme.dart';
import '../mocks.mocks.dart';

// ── Test Fixtures ──────────────────────────────────────────────────────

final testUser = UserModel(
  uid: 'user123',
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@myport.ac.uk',
  course: 'Computer Science',
  bio: 'Test user',
  rating: 4.8,
  sessionsCompleted: 5,
  memberSince: DateTime.now(),
  showFullName: true,
  showCourse: true,
  showPhoto: true,
);

final testListing1 = ListingModel(
  id: 'listing1',
  ownerId: 'user456',
  ownerName: 'Alice Smith',
  title: 'Python Programming',
  description: 'Learn Python',
  tags: const ['python'],
  level: 'Beginner',
  modality: 'Online',
  category: 'Programming',
  nextAvailable: '2026-05-10',
  isActive: true,
  createdAt: DateTime.now(),
);

final testListing2 = ListingModel(
  id: 'listing2',
  ownerId: 'user789',
  ownerName: 'Bob Johnson',
  title: 'Spanish Tutoring',
  description: 'Learn Spanish',
  tags: const ['spanish'],
  level: 'Intermediate',
  modality: 'In-person',
  category: 'Languages',
  nextAvailable: '2026-05-12',
  isActive: true,
  createdAt: DateTime.now(),
);

// ── Test Widget Builder ─────────────────────────────────────────────────

Widget buildTestApp({
  required ListingProvider listingProvider,
  required AuthProvider authProvider,
}) {
  Provider.debugCheckInvalidValueType = null;

  return MaterialApp(
    theme: AppTheme.theme,
    home: MultiProvider(
      providers: [
        Provider<ListingProvider>.value(value: listingProvider),
        Provider<AuthProvider>.value(value: authProvider),
      ],
      child: const BrowseScreen(),
    ),
  );
}

// ── Tests ───────────────────────────────────────────────────────────────

void main() {
  group('BrowseScreen Tests', () {
    late MockListingProvider mockListingProvider;
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockListingProvider = MockListingProvider();
      mockAuthProvider = MockAuthProvider();
      when(mockListingProvider.isLoading).thenReturn(false);
      when(mockListingProvider.listings).thenReturn([]);
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.currentUser).thenReturn(testUser);
    });

    testWidgets('renders listing cards with mock data', (WidgetTester tester) async {
      when(mockListingProvider.listings).thenReturn([testListing1, testListing2]);

      await tester.binding.setSurfaceSize(const Size(680, 2000));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        buildTestApp(
          listingProvider: mockListingProvider,
          authProvider: mockAuthProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(testListing1.title), findsWidgets);
      expect(find.text(testListing2.title), findsWidgets);
      expect(find.text(testListing1.category), findsWidgets);
    });

    testWidgets('search filters cards in real time', (WidgetTester tester) async {
      when(mockListingProvider.listings).thenReturn([testListing1, testListing2]);

      await tester.binding.setSurfaceSize(const Size(680, 2000));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        buildTestApp(
          listingProvider: mockListingProvider,
          authProvider: mockAuthProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(testListing1.title), findsWidgets);
      expect(find.text(testListing2.title), findsWidgets);

      await tester.enterText(find.byType(TextField).first, 'Spanish');
      await tester.pumpAndSettle();

      expect(find.text(testListing1.title), findsNothing);
      expect(find.text(testListing2.title), findsWidgets);
    });

    testWidgets('empty listings shows empty state', (WidgetTester tester) async {
      when(mockListingProvider.listings).thenReturn([]);

      await tester.binding.setSurfaceSize(const Size(680, 2000));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        buildTestApp(
          listingProvider: mockListingProvider,
          authProvider: mockAuthProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No listings match this search'), findsOneWidget);
    });

    testWidgets('my listings tab shows the owner listing', (WidgetTester tester) async {
      final ownedListing = testListing1.copyWith(
        ownerId: testUser.uid,
        ownerName: testUser.fullName,
      );
      when(mockListingProvider.listings).thenReturn([
        testListing1,
        testListing2,
        ownedListing,
      ]);

      await tester.binding.setSurfaceSize(const Size(680, 2000));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        buildTestApp(
          listingProvider: mockListingProvider,
          authProvider: mockAuthProvider,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('My Listings'));
      await tester.pumpAndSettle();

      expect(find.text('Your listings'), findsOneWidget);
      expect(find.text(ownedListing.title), findsOneWidget);
      expect(find.text(testListing2.title), findsNothing);
    });
  });
}

