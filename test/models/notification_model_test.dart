import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap_app/models/notification_model.dart';

void main() {
  group('NotificationModel', () {
    test('fromMap() populates all fields correctly', () {
      final createdAt = DateTime(2024, 5, 1, 11, 30);
      final model = NotificationModel.fromMap({
        'id': 'notification_1',
        'userId': 'user_a',
        'type': 'request',
        'title': 'New request',
        'subtitle': 'Alex sent a request',
        'isRead': true,
        'createdAt': Timestamp.fromDate(createdAt),
      });

      expect(model.id, 'notification_1');
      expect(model.userId, 'user_a');
      expect(model.type, 'request');
      expect(model.title, 'New request');
      expect(model.subtitle, 'Alex sent a request');
      expect(model.isRead, isTrue);
      expect(model.createdAt, createdAt);
    });

    test('fromMap() with null fields returns safe defaults', () {
      final model = NotificationModel.fromMap(<String, dynamic>{});

      expect(model.id, '');
      expect(model.userId, '');
      expect(model.type, '');
      expect(model.title, '');
      expect(model.subtitle, '');
      expect(model.isRead, isFalse);
      expect(model.createdAt, isNotNull);
    });

    test('toMap() returns all expected fields', () {
      final createdAt = DateTime(2024, 5, 1, 11, 30);
      final model = NotificationModel(
        id: 'notification_1',
        userId: 'user_a',
        type: 'request',
        title: 'New request',
        subtitle: 'Alex sent a request',
        isRead: true,
        createdAt: createdAt,
      );

      final map = model.toMap();

      expect(map['id'], 'notification_1');
      expect(map['userId'], 'user_a');
      expect(map['type'], 'request');
      expect(map['title'], 'New request');
      expect(map['subtitle'], 'Alex sent a request');
      expect(map['isRead'], isTrue);
      expect(map['createdAt'], Timestamp.fromDate(createdAt));
    });

    test('toMap() round trip preserves all fields', () {
      final original = NotificationModel(
        id: 'notification_1',
        userId: 'user_a',
        type: 'request',
        title: 'New request',
        subtitle: 'Alex sent a request',
        isRead: true,
        createdAt: DateTime(2024, 5, 1, 11, 30),
      );

      final roundTrip = NotificationModel.fromMap(original.toMap());

      expect(roundTrip.id, original.id);
      expect(roundTrip.userId, original.userId);
      expect(roundTrip.type, original.type);
      expect(roundTrip.title, original.title);
      expect(roundTrip.subtitle, original.subtitle);
      expect(roundTrip.isRead, original.isRead);
      expect(roundTrip.createdAt, original.createdAt);
    });

    test('copyWith() changes one field and keeps others unchanged', () {
      final original = NotificationModel(
        id: 'notification_1',
        userId: 'user_a',
        type: 'request',
        title: 'New request',
        subtitle: 'Alex sent a request',
        isRead: true,
        createdAt: DateTime(2024, 5, 1, 11, 30),
      );

      final updated = original.copyWith(title: 'Updated title');

      expect(updated.title, 'Updated title');
      expect(updated.id, original.id);
      expect(updated.userId, original.userId);
      expect(updated.type, original.type);
      expect(updated.subtitle, original.subtitle);
      expect(updated.isRead, original.isRead);
      expect(updated.createdAt, original.createdAt);
    });

    test('copyWith() with no changes returns equivalent object', () {
      final original = NotificationModel(
        id: 'notification_1',
        userId: 'user_a',
        type: 'request',
        title: 'New request',
        subtitle: 'Alex sent a request',
        isRead: true,
        createdAt: DateTime(2024, 5, 1, 11, 30),
      );

      final copied = original.copyWith();

      expect(copied.id, original.id);
      expect(copied.userId, original.userId);
      expect(copied.type, original.type);
      expect(copied.title, original.title);
      expect(copied.subtitle, original.subtitle);
      expect(copied.isRead, original.isRead);
      expect(copied.createdAt, original.createdAt);
    });

    test('type helper getters return expected values', () {
      final request = NotificationModel(
        id: 'notification_1',
        userId: 'user_a',
        type: 'request',
        title: 'New request',
        subtitle: 'Alex sent a request',
        isRead: false,
        createdAt: DateTime(2024, 5, 1, 11, 30),
      );
      final message = request.copyWith(type: 'message');
      final accepted = request.copyWith(type: 'accepted');
      final declined = request.copyWith(type: 'declined');
      final reminder = request.copyWith(type: 'reminder');

      expect(request.isRequest, isTrue);
      expect(message.isMessage, isTrue);
      expect(accepted.isAccepted, isTrue);
      expect(declined.isDeclined, isTrue);
      expect(reminder.isReminder, isTrue);
    });
  });
}
