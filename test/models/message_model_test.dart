import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap_app/models/message_model.dart';

void main() {
  group('MessageModel', () {
    test('fromMap() populates all fields correctly', () {
      final timestamp = DateTime(2024, 4, 15, 16, 45);
      final model = MessageModel.fromMap({
        'id': 'message_1',
        'conversationId': 'conversation_1',
        'senderId': 'user_a',
        'text': 'Hello there',
        'timestamp': Timestamp.fromDate(timestamp),
        'isRead': true,
        'status': 'failed',
      });

      expect(model.id, 'message_1');
      expect(model.conversationId, 'conversation_1');
      expect(model.senderId, 'user_a');
      expect(model.text, 'Hello there');
      expect(model.timestamp, timestamp);
      expect(model.isRead, isTrue);
      expect(model.status, MessageStatus.failed);
    });

    test('fromMap() with null fields returns safe defaults', () {
      final model = MessageModel.fromMap(<String, dynamic>{});

      expect(model.id, '');
      expect(model.conversationId, '');
      expect(model.senderId, '');
      expect(model.text, '');
      expect(model.timestamp, isNotNull);
      expect(model.isRead, isFalse);
      expect(model.status, MessageStatus.sent);
    });

    test('toMap() returns all expected fields', () {
      final timestamp = DateTime(2024, 4, 15, 16, 45);
      final model = MessageModel(
        id: 'message_1',
        conversationId: 'conversation_1',
        senderId: 'user_a',
        text: 'Hello there',
        timestamp: timestamp,
        isRead: true,
        status: MessageStatus.pending,
      );

      final map = model.toMap();

      expect(map['id'], 'message_1');
      expect(map['conversationId'], 'conversation_1');
      expect(map['senderId'], 'user_a');
      expect(map['text'], 'Hello there');
      expect(map['timestamp'], Timestamp.fromDate(timestamp));
      expect(map['isRead'], isTrue);
      expect(map['status'], 'pending');
    });

    test('toMap() round trip preserves all fields', () {
      final original = MessageModel(
        id: 'message_1',
        conversationId: 'conversation_1',
        senderId: 'user_a',
        text: 'Hello there',
        timestamp: DateTime(2024, 4, 15, 16, 45),
        isRead: true,
        status: MessageStatus.failed,
      );

      final roundTrip = MessageModel.fromMap(original.toMap());

      expect(roundTrip.id, original.id);
      expect(roundTrip.conversationId, original.conversationId);
      expect(roundTrip.senderId, original.senderId);
      expect(roundTrip.text, original.text);
      expect(roundTrip.timestamp, original.timestamp);
      expect(roundTrip.isRead, original.isRead);
      expect(roundTrip.status, original.status);
    });

    test('copyWith() changes one field and keeps others unchanged', () {
      final original = MessageModel(
        id: 'message_1',
        conversationId: 'conversation_1',
        senderId: 'user_a',
        text: 'Hello there',
        timestamp: DateTime(2024, 4, 15, 16, 45),
        isRead: true,
        status: MessageStatus.sent,
      );

      final updated = original.copyWith(text: 'Updated message');

      expect(updated.text, 'Updated message');
      expect(updated.id, original.id);
      expect(updated.conversationId, original.conversationId);
      expect(updated.senderId, original.senderId);
      expect(updated.timestamp, original.timestamp);
      expect(updated.isRead, original.isRead);
      expect(updated.status, original.status);
    });

    test('copyWith() with no changes returns equivalent object', () {
      final original = MessageModel(
        id: 'message_1',
        conversationId: 'conversation_1',
        senderId: 'user_a',
        text: 'Hello there',
        timestamp: DateTime(2024, 4, 15, 16, 45),
        isRead: true,
        status: MessageStatus.sent,
      );

      final copied = original.copyWith();

      expect(copied.id, original.id);
      expect(copied.conversationId, original.conversationId);
      expect(copied.senderId, original.senderId);
      expect(copied.text, original.text);
      expect(copied.timestamp, original.timestamp);
      expect(copied.isRead, original.isRead);
      expect(copied.status, original.status);
    });
  });
}