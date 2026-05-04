import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap_app/models/conversation_model.dart';
import 'package:skillswap_app/models/message_model.dart';
import 'package:skillswap_app/services/chat_service.dart';

void main() {
  group('ChatService', () {
    late FakeFirebaseFirestore firestore;
    late ChatService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = ChatService(db: firestore);
    });

    Future<String> seedConversation({
      required String id,
      required List<String> participants,
      required String lastMessage,
      required DateTime lastMessageTime,
      required int unreadCount,
    }) async {
      await firestore.collection('conversations').doc(id).set(
            ConversationModel(
              id: id,
              participants: participants,
              lastMessage: lastMessage,
              lastMessageTime: lastMessageTime,
              unreadCount: unreadCount,
            ).toMap(),
          );
      return id;
    }

    test('getOrCreateConversation() creates new', () async {
      final conversationId = await service.getOrCreateConversation('user_a', 'user_b');

      final doc = await firestore.collection('conversations').doc(conversationId).get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['participants'], ['user_a', 'user_b']);
      expect(doc.data()?['unreadCount'], 0);
    });

    test('getOrCreateConversation() returns existing', () async {
      await seedConversation(
        id: 'conversation_1',
        participants: ['user_a', 'user_b'],
        lastMessage: 'Hello',
        lastMessageTime: DateTime(2024, 1, 1),
        unreadCount: 0,
      );

      final conversationId = await service.getOrCreateConversation('user_a', 'user_b');

      expect(conversationId, 'conversation_1');
      final conversations = await firestore.collection('conversations').get();
      expect(conversations.docs, hasLength(1));
    });

    test('sendMessage() creates message document', () async {
      final conversationId = await seedConversation(
        id: 'conversation_1',
        participants: ['user_a', 'user_b'],
        lastMessage: '',
        lastMessageTime: DateTime(2024, 1, 1),
        unreadCount: 0,
      );

      await service.sendMessage(
        conversationId: conversationId,
        senderId: 'user_a',
        text: 'Hi there',
      );

      final messages = await firestore.collection('messages').get();
      expect(messages.docs, hasLength(1));
      expect(messages.docs.first.data()['conversationId'], conversationId);
      expect(messages.docs.first.data()['text'], 'Hi there');
    });

    test('sendMessage() updates lastMessage', () async {
      final conversationId = await seedConversation(
        id: 'conversation_1',
        participants: ['user_a', 'user_b'],
        lastMessage: '',
        lastMessageTime: DateTime(2024, 1, 1),
        unreadCount: 0,
      );

      await service.sendMessage(
        conversationId: conversationId,
        senderId: 'user_a',
        text: 'Hi there',
      );

      final doc = await firestore.collection('conversations').doc(conversationId).get();
      expect(doc.data()?['lastMessage'], 'Hi there');
    });

    test('sendMessage() increments unreadCount', () async {
      final conversationId = await seedConversation(
        id: 'conversation_1',
        participants: ['user_a', 'user_b'],
        lastMessage: '',
        lastMessageTime: DateTime(2024, 1, 1),
        unreadCount: 2,
      );

      await service.sendMessage(
        conversationId: conversationId,
        senderId: 'user_a',
        text: 'Hi there',
      );

      final doc = await firestore.collection('conversations').doc(conversationId).get();
      expect(doc.data()?['unreadCount'], 3);
    });

    test('markAsRead() sets unreadCount to 0', () async {
      final conversationId = await seedConversation(
        id: 'conversation_1',
        participants: ['user_a', 'user_b'],
        lastMessage: '',
        lastMessageTime: DateTime(2024, 1, 1),
        unreadCount: 5,
      );

      await service.markAsRead(conversationId);

      final doc = await firestore.collection('conversations').doc(conversationId).get();
      expect(doc.data()?['unreadCount'], 0);
    });

    test('messagesStream() emits correct messages', () async {
      await seedConversation(
        id: 'conversation_1',
        participants: ['user_a', 'user_b'],
        lastMessage: '',
        lastMessageTime: DateTime(2024, 1, 1),
        unreadCount: 0,
      );

      await firestore.collection('messages').doc('msg_1').set(
            MessageModel(
              id: 'msg_1',
              conversationId: 'conversation_1',
              senderId: 'user_a',
              text: 'First message',
              timestamp: DateTime(2024, 1, 1, 10, 0),
              isRead: false,
            ).toMap(),
          );

      await expectLater(
        service.messagesStream('conversation_1'),
        emits(predicate((List<MessageModel> messages) {
          return messages.length == 1 && messages.first.text == 'First message';
        })),
      );
    });

    test('conversationsStream() emits correct list', () async {
      await seedConversation(
        id: 'conversation_1',
        participants: ['user_a', 'user_b'],
        lastMessage: 'Newest',
        lastMessageTime: DateTime(2024, 1, 2),
        unreadCount: 1,
      );
      await seedConversation(
        id: 'conversation_2',
        participants: ['user_a', 'user_c'],
        lastMessage: 'Oldest',
        lastMessageTime: DateTime(2024, 1, 1),
        unreadCount: 0,
      );

      await expectLater(
        service.conversationsStream('user_a'),
        emits(predicate((List<ConversationModel> conversations) {
          return conversations.length == 2 &&
              conversations.first.id == 'conversation_1' &&
              conversations.last.id == 'conversation_2';
        })),
      );
    });
  });
}