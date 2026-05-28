import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap_app/models/listing_model.dart';
import 'package:skillswap_app/services/listing_service.dart';

void main() {
  group('ListingService', () {
    late FakeFirebaseFirestore firestore;
    late ListingService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = ListingService(db: firestore);
    });

    ListingModel listing({
      required String id,
      required String ownerId,
      required String title,
      required String description,
      required List<String> tags,
      required String category,
      required String level,
      required String modality,
      bool isActive = true,
    }) {
      return ListingModel(
        id: id,
        ownerId: ownerId,
        ownerName: 'Owner $ownerId',
        title: title,
        description: description,
        tags: tags,
        level: level,
        modality: modality,
        category: category,
        nextAvailable: 'Friday 3pm',
        isActive: isActive,
        createdAt: DateTime(2024, 1, 1),
      );
    }

    Future<void> seedListings() async {
      final listings = [
        listing(
          id: 'listing_1',
          ownerId: 'owner_1',
          title: 'Flutter Basics',
          description: 'Learn Flutter fast',
          tags: ['flutter', 'dart'],
          category: 'Programming',
          level: 'Beginner',
          modality: 'Online',
        ),
        listing(
          id: 'listing_2',
          ownerId: 'owner_1',
          title: 'Spanish Conversation',
          description: 'Practice speaking',
          tags: ['language', 'spanish'],
          category: 'Languages',
          level: 'Intermediate',
          modality: 'In-person',
        ),
        listing(
          id: 'listing_3',
          ownerId: 'owner_2',
          title: 'Python Advanced',
          description: 'Deep dive into Python',
          tags: ['python', 'coding'],
          category: 'Programming',
          level: 'Advanced',
          modality: 'Hybrid',
        ),
        listing(
          id: 'listing_4',
          ownerId: 'owner_3',
          title: 'Inactive Listing',
          description: 'Should not appear',
          tags: ['inactive'],
          category: 'Business',
          level: 'Beginner',
          modality: 'Online',
          isActive: false,
        ),
      ];

      for (final item in listings) {
        await firestore.collection('listings').doc(item.id).set(item.toMap());
      }
    }

    test('getAllListings() returns only isActive=true', () async {
      await seedListings();

      final results = await service.getAllListings();

      expect(results, hasLength(3));
      expect(results.every((listing) => listing.isActive), isTrue);
      expect(
        results.map((listing) => listing.id),
        isNot(contains('listing_4')),
      );
    });

    test('getAllListings() empty collection returns []', () async {
      final results = await service.getAllListings();

      expect(results, isEmpty);
    });

    test('getMyListings() returns only correct owner', () async {
      await seedListings();

      final results = await service.getMyListings('owner_1');

      expect(results, hasLength(2));
      expect(results.every((listing) => listing.ownerId == 'owner_1'), isTrue);
      expect(results.every((listing) => listing.isActive), isTrue);
    });

    test('createListing() document appears in Firestore', () async {
      final newListing = listing(
        id: '',
        ownerId: 'owner_9',
        title: 'New Skill',
        description: 'A brand new listing',
        tags: ['new'],
        category: 'Programming',
        level: 'Beginner',
        modality: 'Online',
      );

      await service.createListing(newListing);

      final snapshot = await firestore.collection('listings').get();
      expect(snapshot.docs, hasLength(1));
      final data = snapshot.docs.first.data();
      expect(data['ownerId'], 'owner_9');
      expect(data['title'], 'New Skill');
      expect(data['isActive'], isTrue);
      expect(data['id'], isNotEmpty);
    });

    test('deleteListing() sets isActive=false not delete', () async {
      await firestore
          .collection('listings')
          .doc('listing_1')
          .set(
            listing(
              id: 'listing_1',
              ownerId: 'owner_1',
              title: 'Flutter Basics',
              description: 'Learn Flutter fast',
              tags: ['flutter', 'dart'],
              category: 'Programming',
              level: 'Beginner',
              modality: 'Online',
            ).toMap(),
          );

      await service.deleteListing('listing_1');

      final doc = await firestore.collection('listings').doc('listing_1').get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['isActive'], isFalse);
    });

    test('deleteListing() non-existent ID throws', () async {
      await expectLater(
        service.deleteListing('missing_id'),
        throwsA(isA<Exception>()),
      );
    });

    test('searchListings() category filter works', () async {
      await seedListings();

      final results = await service.searchListings(category: 'Programming');

      expect(results, hasLength(2));
      expect(
        results.every((listing) => listing.category == 'Programming'),
        isTrue,
      );
    });

    test('searchListings() text query filter works', () async {
      await seedListings();

      final results = await service.searchListings(query: 'python');

      expect(results, hasLength(1));
      expect(results.first.id, 'listing_3');
    });

    test('searchListings() all filters = All returns all', () async {
      await seedListings();

      final results = await service.searchListings(
        query: '',
        category: 'All',
        level: 'All Levels',
        modality: 'All Formats',
      );

      expect(results, hasLength(3));
    });

    test('updateListing() only updates provided fields', () async {
      await firestore
          .collection('listings')
          .doc('listing_1')
          .set(
            listing(
              id: 'listing_1',
              ownerId: 'owner_1',
              title: 'Flutter Basics',
              description: 'Learn Flutter fast',
              tags: ['flutter', 'dart'],
              category: 'Programming',
              level: 'Beginner',
              modality: 'Online',
            ).toMap(),
          );

      await service.updateListing('listing_1', {
        'title': 'Updated Flutter Basics',
      });

      final doc = await firestore.collection('listings').doc('listing_1').get();
      final data = doc.data()!;
      expect(data['title'], 'Updated Flutter Basics');
      expect(data['ownerId'], 'owner_1');
      expect(data['description'], 'Learn Flutter fast');
      expect(data['isActive'], isTrue);
    });

    test('listingsStream() emits correct list', () async {
      await seedListings();

      final expectation = expectLater(
        service.listingsStream(),
        emits(
          predicate((List<ListingModel> listings) {
            return listings.length == 3 &&
                listings.every((listing) => listing.isActive) &&
                listings.any((listing) => listing.id == 'listing_1');
          }),
        ),
      );

      await expectation;
    });
  });
}
