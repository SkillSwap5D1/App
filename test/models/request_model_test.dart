import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap_app/models/request_model.dart';

void main() {
  group('RequestModel', () {
    test('fromMap() populates all fields correctly', () {
      final createdAt = DateTime(2024, 3, 5, 14, 0);
      final updatedAt = DateTime(2024, 3, 5, 15, 0);
      final model = RequestModel.fromMap({
        'id': 'request_1',
        'fromUserId': 'user_a',
        'fromUserName': 'Alex Brown',
        'toUserId': 'user_b',
        'listingId': 'listing_1',
        'skillName': 'Flutter',
        'message': 'Can you teach Flutter?',
        'status': 'accepted',
        'proposedTimes': ['Mon 10am', 'Tue 2pm'],
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      });

      expect(model.id, 'request_1');
      expect(model.fromUserId, 'user_a');
      expect(model.fromUserName, 'Alex Brown');
      expect(model.toUserId, 'user_b');
      expect(model.listingId, 'listing_1');
      expect(model.skillName, 'Flutter');
      expect(model.message, 'Can you teach Flutter?');
      expect(model.status, 'accepted');
      expect(model.proposedTimes, ['Mon 10am', 'Tue 2pm']);
      expect(model.createdAt, createdAt);
      expect(model.updatedAt, updatedAt);
    });

    test('fromMap() with null fields returns safe defaults', () {
      final model = RequestModel.fromMap(<String, dynamic>{});

      expect(model.id, '');
      expect(model.fromUserId, '');
      expect(model.fromUserName, '');
      expect(model.toUserId, '');
      expect(model.listingId, '');
      expect(model.skillName, '');
      expect(model.message, '');
      expect(model.status, 'pending');
      expect(model.proposedTimes, isEmpty);
      expect(model.createdAt, isNotNull);
      expect(model.updatedAt, isNotNull);
    });

    test('toMap() returns all expected fields', () {
      final createdAt = DateTime(2024, 3, 5, 14, 0);
      final updatedAt = DateTime(2024, 3, 5, 15, 0);
      final model = RequestModel(
        id: 'request_1',
        fromUserId: 'user_a',
        fromUserName: 'Alex Brown',
        toUserId: 'user_b',
        toUserName: 'Bob Smith',
        listingId: 'listing_1',
        skillName: 'Flutter',
        message: 'Can you teach Flutter?',
        status: 'accepted',
        proposedTimes: ['Mon 10am', 'Tue 2pm'],
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final map = model.toMap();

      expect(map['id'], 'request_1');
      expect(map['fromUserId'], 'user_a');
      expect(map['fromUserName'], 'Alex Brown');
      expect(map['toUserId'], 'user_b');
      expect(map['listingId'], 'listing_1');
      expect(map['skillName'], 'Flutter');
      expect(map['message'], 'Can you teach Flutter?');
      expect(map['status'], 'accepted');
      expect(map['proposedTimes'], ['Mon 10am', 'Tue 2pm']);
      expect(map['createdAt'], Timestamp.fromDate(createdAt));
      expect(map['updatedAt'], Timestamp.fromDate(updatedAt));
    });

    test('toMap() round trip preserves all fields', () {
      final original = RequestModel(
        id: 'request_1',
        fromUserId: 'user_a',
        fromUserName: 'Alex Brown',
        toUserId: 'user_b',
        toUserName: 'Bob Smith',
        listingId: 'listing_1',
        skillName: 'Flutter',
        message: 'Can you teach Flutter?',
        status: 'accepted',
        proposedTimes: ['Mon 10am', 'Tue 2pm'],
        createdAt: DateTime(2024, 3, 5, 14, 0),
        updatedAt: DateTime(2024, 3, 5, 15, 0),
      );

      final roundTrip = RequestModel.fromMap(original.toMap());

      expect(roundTrip.id, original.id);
      expect(roundTrip.fromUserId, original.fromUserId);
      expect(roundTrip.fromUserName, original.fromUserName);
      expect(roundTrip.toUserId, original.toUserId);
      expect(roundTrip.listingId, original.listingId);
      expect(roundTrip.skillName, original.skillName);
      expect(roundTrip.message, original.message);
      expect(roundTrip.status, original.status);
      expect(roundTrip.proposedTimes, original.proposedTimes);
      expect(roundTrip.createdAt, original.createdAt);
      expect(roundTrip.updatedAt, original.updatedAt);
    });

    test('copyWith() changes one field and keeps others unchanged', () {
      final original = RequestModel(
        id: 'request_1',
        fromUserId: 'user_a',
        fromUserName: 'Alex Brown',
        toUserId: 'user_b',
        toUserName: 'Bob Smith',
        listingId: 'listing_1',
        skillName: 'Flutter',
        message: 'Can you teach Flutter?',
        status: 'accepted',
        proposedTimes: ['Mon 10am', 'Tue 2pm'],
        createdAt: DateTime(2024, 3, 5, 14, 0),
        updatedAt: DateTime(2024, 3, 5, 15, 0),
      );

      final updated = original.copyWith(status: 'countered');

      expect(updated.status, 'countered');
      expect(updated.id, original.id);
      expect(updated.fromUserId, original.fromUserId);
      expect(updated.fromUserName, original.fromUserName);
      expect(updated.toUserId, original.toUserId);
      expect(updated.listingId, original.listingId);
      expect(updated.skillName, original.skillName);
      expect(updated.message, original.message);
      expect(updated.proposedTimes, original.proposedTimes);
      expect(updated.createdAt, original.createdAt);
      expect(updated.updatedAt, original.updatedAt);
    });

    test('copyWith() with no changes returns equivalent object', () {
      final original = RequestModel(
        id: 'request_1',
        fromUserId: 'user_a',
        fromUserName: 'Alex Brown',
        toUserId: 'user_b',
        toUserName: 'Bob Smith',
        listingId: 'listing_1',
        skillName: 'Flutter',
        message: 'Can you teach Flutter?',
        status: 'accepted',
        proposedTimes: ['Mon 10am', 'Tue 2pm'],
        createdAt: DateTime(2024, 3, 5, 14, 0),
        updatedAt: DateTime(2024, 3, 5, 15, 0),
      );

      final copied = original.copyWith();

      expect(copied.id, original.id);
      expect(copied.fromUserId, original.fromUserId);
      expect(copied.fromUserName, original.fromUserName);
      expect(copied.toUserId, original.toUserId);
      expect(copied.listingId, original.listingId);
      expect(copied.skillName, original.skillName);
      expect(copied.message, original.message);
      expect(copied.status, original.status);
      expect(copied.proposedTimes, original.proposedTimes);
      expect(copied.createdAt, original.createdAt);
      expect(copied.updatedAt, original.updatedAt);
    });

    test('status helper getters return expected values', () {
      final pending = RequestModel(
        id: 'request_1',
        fromUserId: 'user_a',
        fromUserName: 'Alex Brown',
        toUserId: 'user_b',
        toUserName: 'Bob Smith',
        listingId: 'listing_1',
        skillName: 'Flutter',
        message: 'Can you teach Flutter?',
        status: 'pending',
        proposedTimes: const [],
        createdAt: DateTime(2024, 3, 5, 14, 0),
        updatedAt: DateTime(2024, 3, 5, 15, 0),
      );
      final accepted = pending.copyWith(status: 'accepted');
      final declined = pending.copyWith(status: 'declined');
      final countered = pending.copyWith(status: 'countered');

      expect(pending.isPending, isTrue);
      expect(accepted.isPending, isFalse);
      expect(accepted.isAccepted, isTrue);
      expect(declined.isDeclined, isTrue);
      expect(countered.isCountered, isTrue);
    });
  });
}
