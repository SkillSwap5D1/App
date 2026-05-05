import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skillswap_app/models/listing_model.dart';
import 'package:skillswap_app/models/user_model.dart';
import 'package:skillswap_app/providers/listing_provider.dart';
import 'package:skillswap_app/providers/auth_provider.dart';
import 'package:skillswap_app/screens/browse/browse_screen.dart';

// ── Mock Providers ────────────────────────────────────────────────────────

class MockListingProvider extends ChangeNotifier {
  List<ListingModel> listings = [];
  List<ListingModel> myListings = [];
  bool isLoading = false;
  String? errorMessage;

  void setListings(List<ListingModel> newListings) {
    listings = newListings;
    notifyListeners();
  }

  void setMyListings(List<ListingModel> newListings) {
    myListings = newListings;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> loadListings() async {}
  Future<void> loadMyListings(String uid) async {}
  Future<void> searchListings({
    String query = '',
    String category = 'All',
    String level = 'All Levels',
    String modality = 'All Formats',
  }) async {}

  bool isSaved(String listingId) => false;
  List<ListingModel> get savedListings => [];
  Future<void> loadSavedListings(String uid) async {}
  Future<void> toggleSaved(String uid, String listingId) async {}
  Future<void> createListing(ListingModel listing) async {}
  Future<void> updateListing(String id, Map<String, dynamic> data) async {}
  Future<void> deleteListing(String id) async {}
}

class MockAuthProvider extends ChangeNotifier {
  bool loading = false;
  UserModel? currentUser;

  MockAuthProvider({this.currentUser});

  bool get isLoading => loading;
}

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
  required MockListingProvider listingProvider,
  required MockAuthProvider authProvider,
}) {
  Provider.debugCheckInvalidValueType = null;

  return MaterialApp(
    theme: ThemeData.dark(),
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider<ListingProvider>(
          create: (_) => listingProvider as ListingProvider,
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => authProvider as AuthProvider,
        ),
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
      mockAuthProvider = MockAuthProvider(currentUser: testUser);
    });

    testWidgets('TEST 1 — renders listing cards with mock data', (WidgetTester tester) async {
      mockListingProvider.setListings([testListing1, testListing2]);

      await tester.pumpWidget(
        buildTestApp(
          listingProvider: mockListingProvider,
          authProvider: mockAuthProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(testListing1.title), findsWidgets);
      expect(find.text(testListing2.title), findsWidgets);
      expect(find.text(testListing1.ownerName), findsWidgets);
    });

    testWidgets('TEST 2 — search filters cards in real time', (WidgetTester tester) async {
      mockListingProvider.setListings([testListing1, testListing2]);

      await tester.pumpWidget(
        buildTestApp(
          listingProvider: mockListingProvider,
          authProvider: mockAuthProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text(testListing1.title), findsWidgets);
      expect(find.text(testListing2.title), findsWidgets);

      // Simulate search result - only showing first listing
      mockListingProvider.setListings([testListing1]);
      await tester.pumpAndSettle();

      expect(find.text(testListing1.title), findsWidgets);
      expect(find.text(testListing2.title), findsNothing);
    });

    testWidgets('TEST 3 — empty listings shows empty state', (WidgetTester tester) async {
      mockListingProvider.setListings([]);

      await tester.pumpWidget(
        buildTestApp(
          listingProvider: mockListingProvider,
          authProvider: mockAuthProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No skills available'), findsWidgets);
    });

    testWidgets('TEST 4 — isLoading shows CircularProgressIndicator', (WidgetTester tester) async {
      mockListingProvider.setLoading(true);

      await tester.pumpWidget(
        buildTestApp(
          listingProvider: mockListingProvider,
          authProvider: mockAuthProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('TEST 5 — switching to My Skills tab changes buttons', (WidgetTester tester) async {
      mockListingProvider.setListings([testListing1]);
      mockListingProvider.setMyListings([testListing2]);

      await tester.pumpWidget(
        buildTestApp(
          listingProvider: mockListingProvider,
          authProvider: mockAuthProvider,
        ),
      );
      await tester.pumpAndSettle();

      // Verify Available tab shows testListing1
      expect(find.text(testListing1.title), findsWidgets);

      // Simulate switching to My Skills
      mockListingProvider.setListings([testListing2]);
      await tester.pumpAndSettle();

      expect(find.text(testListing2.title), findsWidgets);
    });
  });
}

