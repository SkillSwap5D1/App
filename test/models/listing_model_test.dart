import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap_app/models/listing_model.dart';

void main() {
  group('ListingModel', () {
    test('fromMap() populates all fields correctly', () {
      final createdAt = DateTime(2024, 2, 10, 9, 15);
      final model = ListingModel.fromMap({
        'id': 'listing_1',
        'ownerId': 'owner_1',
        'ownerName': 'Jamie Smith',
        'title': 'Flutter Mentoring',
        'description': 'Learn Flutter basics',
        'tags': ['flutter', 'mobile', 'dart'],
        'level': 'Beginner',
        'modality': 'Online',
        'category': 'Programming',
        'nextAvailable': 'Friday 3pm',
        'isActive': false,
        'createdAt': Timestamp.fromDate(createdAt),
      });

      expect(model.id, 'listing_1');
      expect(model.ownerId, 'owner_1');
      expect(model.ownerName, 'Jamie Smith');
      expect(model.title, 'Flutter Mentoring');
      expect(model.description, 'Learn Flutter basics');
      expect(model.tags, ['flutter', 'mobile', 'dart']);
      expect(model.level, 'Beginner');
      expect(model.modality, 'Online');
      expect(model.category, 'Programming');
      expect(model.nextAvailable, 'Friday 3pm');
      expect(model.isActive, isFalse);
      expect(model.createdAt, createdAt);
      expect(model.tags, isA<List<String>>());
    });

    test('fromMap() with null fields returns safe defaults', () {
      final model = ListingModel.fromMap(<String, dynamic>{});

      expect(model.id, '');
      expect(model.ownerId, '');
      expect(model.ownerName, '');
      expect(model.title, '');
      expect(model.description, '');
      expect(model.tags, isEmpty);
      expect(model.level, '');
      expect(model.modality, '');
      expect(model.category, '');
      expect(model.nextAvailable, '');
      expect(model.isActive, isTrue);
      expect(model.createdAt, isNotNull);
    });

    test('toMap() returns all expected fields', () {
      final createdAt = DateTime(2024, 2, 10, 9, 15);
      final model = ListingModel(
        id: 'listing_1',
        ownerId: 'owner_1',
        ownerName: 'Jamie Smith',
        title: 'Flutter Mentoring',
        description: 'Learn Flutter basics',
        tags: ['flutter', 'mobile', 'dart'],
        level: 'Beginner',
        modality: 'Online',
        category: 'Programming',
        nextAvailable: 'Friday 3pm',
        isActive: false,
        createdAt: createdAt,
      );

      final map = model.toMap();

      expect(map['id'], 'listing_1');
      expect(map['ownerId'], 'owner_1');
      expect(map['ownerName'], 'Jamie Smith');
      expect(map['title'], 'Flutter Mentoring');
      expect(map['description'], 'Learn Flutter basics');
      expect(map['tags'], ['flutter', 'mobile', 'dart']);
      expect(map['level'], 'Beginner');
      expect(map['modality'], 'Online');
      expect(map['category'], 'Programming');
      expect(map['nextAvailable'], 'Friday 3pm');
      expect(map['isActive'], isFalse);
      expect(map['createdAt'], Timestamp.fromDate(createdAt));
    });

    test('toMap() round trip preserves all fields', () {
      final original = ListingModel(
        id: 'listing_1',
        ownerId: 'owner_1',
        ownerName: 'Jamie Smith',
        title: 'Flutter Mentoring',
        description: 'Learn Flutter basics',
        tags: ['flutter', 'mobile', 'dart'],
        level: 'Beginner',
        modality: 'Online',
        category: 'Programming',
        nextAvailable: 'Friday 3pm',
        isActive: false,
        createdAt: DateTime(2024, 2, 10, 9, 15),
      );

      final roundTrip = ListingModel.fromMap(original.toMap());

      expect(roundTrip.id, original.id);
      expect(roundTrip.ownerId, original.ownerId);
      expect(roundTrip.ownerName, original.ownerName);
      expect(roundTrip.title, original.title);
      expect(roundTrip.description, original.description);
      expect(roundTrip.tags, original.tags);
      expect(roundTrip.level, original.level);
      expect(roundTrip.modality, original.modality);
      expect(roundTrip.category, original.category);
      expect(roundTrip.nextAvailable, original.nextAvailable);
      expect(roundTrip.isActive, original.isActive);
      expect(roundTrip.createdAt, original.createdAt);
    });

    test('copyWith() changes one field and keeps others unchanged', () {
      final original = ListingModel(
        id: 'listing_1',
        ownerId: 'owner_1',
        ownerName: 'Jamie Smith',
        title: 'Flutter Mentoring',
        description: 'Learn Flutter basics',
        tags: ['flutter', 'mobile', 'dart'],
        level: 'Beginner',
        modality: 'Online',
        category: 'Programming',
        nextAvailable: 'Friday 3pm',
        isActive: false,
        createdAt: DateTime(2024, 2, 10, 9, 15),
      );

      final updated = original.copyWith(title: 'Advanced Flutter Mentoring');

      expect(updated.title, 'Advanced Flutter Mentoring');
      expect(updated.id, original.id);
      expect(updated.ownerId, original.ownerId);
      expect(updated.ownerName, original.ownerName);
      expect(updated.description, original.description);
      expect(updated.tags, original.tags);
      expect(updated.level, original.level);
      expect(updated.modality, original.modality);
      expect(updated.category, original.category);
      expect(updated.nextAvailable, original.nextAvailable);
      expect(updated.isActive, original.isActive);
      expect(updated.createdAt, original.createdAt);
    });

    test('copyWith() with no changes returns equivalent object', () {
      final original = ListingModel(
        id: 'listing_1',
        ownerId: 'owner_1',
        ownerName: 'Jamie Smith',
        title: 'Flutter Mentoring',
        description: 'Learn Flutter basics',
        tags: ['flutter', 'mobile', 'dart'],
        level: 'Beginner',
        modality: 'Online',
        category: 'Programming',
        nextAvailable: 'Friday 3pm',
        isActive: false,
        createdAt: DateTime(2024, 2, 10, 9, 15),
      );

      final copied = original.copyWith();

      expect(copied.id, original.id);
      expect(copied.ownerId, original.ownerId);
      expect(copied.ownerName, original.ownerName);
      expect(copied.title, original.title);
      expect(copied.description, original.description);
      expect(copied.tags, original.tags);
      expect(copied.level, original.level);
      expect(copied.modality, original.modality);
      expect(copied.category, original.category);
      expect(copied.nextAvailable, original.nextAvailable);
      expect(copied.isActive, original.isActive);
      expect(copied.createdAt, original.createdAt);
    });

    test('isActive defaults to true when null', () {
      final model = ListingModel.fromMap({
        'id': 'listing_1',
        'ownerId': 'owner_1',
        'ownerName': 'Jamie Smith',
        'title': 'Flutter Mentoring',
        'description': 'Learn Flutter basics',
        'tags': ['flutter'],
        'level': 'Beginner',
        'modality': 'Online',
        'category': 'Programming',
        'nextAvailable': 'Friday 3pm',
        'isActive': null,
      });

      expect(model.isActive, isTrue);
    });
  });
}