import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap_app/models/review_model.dart';

void main() {
  group('ReviewModel', () {
    test('fromMap() populates all fields correctly', () {
      final createdAt = DateTime(2024, 6, 1, 10, 0);
      final updatedAt = DateTime(2024, 6, 2, 11, 0);
      final model = ReviewModel.fromMap({
        'id': 'review_1',
        'requestId': 'request_1',
        'reviewerId': 'user_a',
        'revieweeId': 'user_b',
        'rating': 5,
        'text': 'Excellent session',
        'isPublished': true,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      });

      expect(model.id, 'review_1');
      expect(model.requestId, 'request_1');
      expect(model.reviewerId, 'user_a');
      expect(model.revieweeId, 'user_b');
      expect(model.rating, 5);
      expect(model.text, 'Excellent session');
      expect(model.isPublished, isTrue);
      expect(model.createdAt, createdAt);
      expect(model.updatedAt, updatedAt);
    });

    test('fromMap() with null fields returns safe defaults', () {
      final model = ReviewModel.fromMap(<String, dynamic>{});

      expect(model.id, '');
      expect(model.requestId, '');
      expect(model.reviewerId, '');
      expect(model.revieweeId, '');
      expect(model.rating, 0);
      expect(model.text, '');
      expect(model.isPublished, isFalse);
      expect(model.createdAt, isNotNull);
      expect(model.updatedAt, isNotNull);
    });

    test('toMap() returns all expected fields', () {
      final createdAt = DateTime(2024, 6, 1, 10, 0);
      final updatedAt = DateTime(2024, 6, 2, 11, 0);
      final model = ReviewModel(
        id: 'review_1',
        requestId: 'request_1',
        reviewerId: 'user_a',
        revieweeId: 'user_b',
        rating: 5,
        text: 'Excellent session',
        isPublished: true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final map = model.toMap();

      expect(map['id'], 'review_1');
      expect(map['requestId'], 'request_1');
      expect(map['reviewerId'], 'user_a');
      expect(map['revieweeId'], 'user_b');
      expect(map['rating'], 5);
      expect(map['text'], 'Excellent session');
      expect(map['isPublished'], isTrue);
      expect(map['createdAt'], Timestamp.fromDate(createdAt));
      expect(map['updatedAt'], Timestamp.fromDate(updatedAt));
    });

    test('toMap() round trip preserves all fields', () {
      final original = ReviewModel(
        id: 'review_1',
        requestId: 'request_1',
        reviewerId: 'user_a',
        revieweeId: 'user_b',
        rating: 5,
        text: 'Excellent session',
        isPublished: true,
        createdAt: DateTime(2024, 6, 1, 10, 0),
        updatedAt: DateTime(2024, 6, 2, 11, 0),
      );

      final roundTrip = ReviewModel.fromMap(original.toMap());

      expect(roundTrip.id, original.id);
      expect(roundTrip.requestId, original.requestId);
      expect(roundTrip.reviewerId, original.reviewerId);
      expect(roundTrip.revieweeId, original.revieweeId);
      expect(roundTrip.rating, original.rating);
      expect(roundTrip.text, original.text);
      expect(roundTrip.isPublished, original.isPublished);
      expect(roundTrip.createdAt, original.createdAt);
      expect(roundTrip.updatedAt, original.updatedAt);
    });

    test('copyWith() changes one field and keeps others unchanged', () {
      final original = ReviewModel(
        id: 'review_1',
        requestId: 'request_1',
        reviewerId: 'user_a',
        revieweeId: 'user_b',
        rating: 5,
        text: 'Excellent session',
        isPublished: true,
        createdAt: DateTime(2024, 6, 1, 10, 0),
        updatedAt: DateTime(2024, 6, 2, 11, 0),
      );

      final updated = original.copyWith(rating: 4);

      expect(updated.rating, 4);
      expect(updated.id, original.id);
      expect(updated.requestId, original.requestId);
      expect(updated.reviewerId, original.reviewerId);
      expect(updated.revieweeId, original.revieweeId);
      expect(updated.text, original.text);
      expect(updated.isPublished, original.isPublished);
      expect(updated.createdAt, original.createdAt);
      expect(updated.updatedAt, original.updatedAt);
    });

    test('copyWith() with no changes returns equivalent object', () {
      final original = ReviewModel(
        id: 'review_1',
        requestId: 'request_1',
        reviewerId: 'user_a',
        revieweeId: 'user_b',
        rating: 5,
        text: 'Excellent session',
        isPublished: true,
        createdAt: DateTime(2024, 6, 1, 10, 0),
        updatedAt: DateTime(2024, 6, 2, 11, 0),
      );

      final copied = original.copyWith();

      expect(copied.id, original.id);
      expect(copied.requestId, original.requestId);
      expect(copied.reviewerId, original.reviewerId);
      expect(copied.revieweeId, original.revieweeId);
      expect(copied.rating, original.rating);
      expect(copied.text, original.text);
      expect(copied.isPublished, original.isPublished);
      expect(copied.createdAt, original.createdAt);
      expect(copied.updatedAt, original.updatedAt);
    });
  });
}