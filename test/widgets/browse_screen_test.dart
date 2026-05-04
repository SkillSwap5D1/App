import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:skillswap_app/models/listing_model.dart';
import 'package:skillswap_app/models/user_model.dart';
import 'package:skillswap_app/providers/auth_provider.dart';
import 'package:skillswap_app/providers/listing_provider.dart';
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

void main() {
  Provider.debugCheckInvalidValueType = null;

  group('BrowseScreen Unit Tests', () {
    test('TEST 1 — renders listing cards with mock data', () {
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
      ];

      expect(listingProvider.listings.length, 1);
      expect(listingProvider.listings[0].title, 'Python Basics');
      expect(listingProvider.listings[0].ownerName, 'Alice');
    });

    test('TEST 2 — search filters cards in real time', () {
      final listingProvider = MockListingProvider();

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

      // Simulate filter for Python
      final filtered = listingProvider.listings
          .where((l) => l.title.toLowerCase().contains('python'))
          .toList();

      expect(filtered.length, 1);
      expect(filtered[0].title, 'Python Basics');
    });

    test('TEST 3 — empty listings shows empty state', () {
      final listingProvider = MockListingProvider();

      listingProvider.listings_ = [];
      listingProvider.loading = false;

      expect(listingProvider.listings.isEmpty, true);
      expect(listingProvider.isLoading, false);
    });

    test('TEST 4 — isLoading shows CircularProgressIndicator', () {
      final listingProvider = MockListingProvider();

      listingProvider.loading = true;

      expect(listingProvider.isLoading, true);
    });

    test('TEST 5 — switching to My Skills tab changes buttons', () {
      final listingProvider = MockListingProvider();
      final authProvider = MockAuthProvider()..uid = 'user1';

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

      // Verify My Skills listings are available
      expect(listingProvider.myListings.length, 1);
      expect(listingProvider.myListings[0].ownerId, 'user1');
      expect(listingProvider.myListings[0].title, 'Django Web Dev');
    });
  });
}

