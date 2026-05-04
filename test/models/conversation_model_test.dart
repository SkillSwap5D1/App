import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap_app/models/conversation_model.dart';

void main() {
  group('ConversationModel', () {
    test('fromMap() populates all fields correctly', () {
      final lastMessageTime = DateTime(2024, 4, 1, 12, 0);
      final model = ConversationModel.fromMap({
        'id': 'conversation_1',
        'participants': ['user_a', 'user_b'],
        'lastMessage': 'See you soon',
        'lastMessageTime': Timestamp.fromDate(lastMessageTime),
        'unreadCount': 3,
      });

      expect(model.id, 'conversation_1');
      expect(model.participants, ['user_a', 'user_b']);
      expect(model.lastMessage, 'See you soon');
      expect(model.lastMessageTime, lastMessageTime);
      expect(model.unreadCount, 3);
    });

    test('fromMap() with null fields returns safe defaults', () {
      final model = ConversationModel.fromMap(<String, dynamic>{});

      expect(model.id, '');
      expect(model.participants, isEmpty);
      expect(model.lastMessage, '');
      expect(model.lastMessageTime, isNotNull);
      expect(model.unreadCount, 0);
    });

    test('toMap() returns all expected fields', () {
      final lastMessageTime = DateTime(2024, 4, 1, 12, 0);
      final model = ConversationModel(
        id: 'conversation_1',
        participants: ['user_a', 'user_b'],
        lastMessage: 'See you soon',
        lastMessageTime: lastMessageTime,
        unreadCount: 3,
      );

      final map = model.toMap();

      expect(map['id'], 'conversation_1');
      expect(map['participants'], ['user_a', 'user_b']);
      expect(map['lastMessage'], 'See you soon');
      expect(map['lastMessageTime'], Timestamp.fromDate(lastMessageTime));
      expect(map['unreadCount'], 3);
    });

    test('toMap() round trip preserves all fields', () {
      final original = ConversationModel(
        id: 'conversation_1',
        participants: ['user_a', 'user_b'],
        lastMessage: 'See you soon',
        lastMessageTime: DateTime(2024, 4, 1, 12, 0),
        unreadCount: 3,
      );

      final roundTrip = ConversationModel.fromMap(original.toMap());

      expect(roundTrip.id, original.id);
      expect(roundTrip.participants, original.participants);
      expect(roundTrip.lastMessage, original.lastMessage);
      expect(roundTrip.lastMessageTime, original.lastMessageTime);
      expect(roundTrip.unreadCount, original.unreadCount);
    });

    test('copyWith() changes one field and keeps others unchanged', () {
      final original = ConversationModel(
        id: 'conversation_1',
        participants: ['user_a', 'user_b'],
        lastMessage: 'See you soon',
        lastMessageTime: DateTime(2024, 4, 1, 12, 0),
        unreadCount: 3,
      );

      final updated = original.copyWith(lastMessage: 'Talk later');

      expect(updated.lastMessage, 'Talk later');
      expect(updated.id, original.id);
      expect(updated.participants, original.participants);
      expect(updated.lastMessageTime, original.lastMessageTime);
      expect(updated.unreadCount, original.unreadCount);
    });

    test('copyWith() with no changes returns equivalent object', () {
      final original = ConversationModel(
        id: 'conversation_1',
        participants: ['user_a', 'user_b'],
        lastMessage: 'See you soon',
        lastMessageTime: DateTime(2024, 4, 1, 12, 0),
        unreadCount: 3,
      );

      final copied = original.copyWith();

      expect(copied.id, original.id);
      expect(copied.participants, original.participants);
      expect(copied.lastMessage, original.lastMessage);
      expect(copied.lastMessageTime, original.lastMessageTime);
      expect(copied.unreadCount, original.unreadCount);
    });

    test('getOtherUserId() returns the correct other ID', () {
      final model = ConversationModel(
        id: 'conversation_1',
        participants: ['user_a', 'user_b'],
        lastMessage: 'See you soon',
        lastMessageTime: DateTime(2024, 4, 1, 12, 0),
        unreadCount: 3,
      );

      expect(model.getOtherUserId('user_a'), 'user_b');
    });

    test('getOtherUserId() returns empty string when myUid is not in participants', () {
      final model = ConversationModel(
        id: 'conversation_1',
        participants: ['user_a', 'user_b'],
        lastMessage: 'See you soon',
        lastMessageTime: DateTime(2024, 4, 1, 12, 0),
        unreadCount: 3,
      );

      expect(model.getOtherUserId('user_c'), '');
    });
  });
}