import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import 'notification_service.dart';

class ChatService {
  // ── Firebase instance ─────────────────────────────────────────────────────
  final FirebaseFirestore _db;
  final NotificationService _notificationService;

  ChatService({FirebaseFirestore? db, NotificationService? notificationService})
    : _db = db ?? FirebaseFirestore.instance,
      _notificationService = notificationService ?? NotificationService(firestore: db ?? FirebaseFirestore.instance);

  // ── Get or create a conversation between 2 users ─────────────────────────
  Future<String> getOrCreateConversation(String uid1, String uid2) async {
    try {
      final participantIds = [uid1, uid2]..sort();
      final conversationId = participantIds.join('_');
      final docRef = _db.collection('conversations').doc(conversationId);

      final existing = await docRef.get();
      if (existing.exists) {
        return docRef.id;
      }

      final conversation = ConversationModel(
        id: docRef.id,
        participants: participantIds,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        unreadCounts: {uid1: 0, uid2: 0},
      );

      await docRef.set(conversation.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to get or create conversation: $e');
    }
  }

  // ── Send a message ────────────────────────────────────────────────────────
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    try {
      print('🔵 ChatService.sendMessage(): Starting message send');
      print('   conversationId: $conversationId');
      print('   senderId: $senderId');

      // Create new message document
      final msgRef = _db.collection('messages').doc();
      final message = MessageModel(
        id: msgRef.id,
        conversationId: conversationId,
        senderId: senderId,
        text: text,
        timestamp: DateTime.now(),
        isRead: false,
      );

      // Save message
      await msgRef.set(message.toMap());
      print('✅ Message saved: ${msgRef.id}');

      // Get conversation to find other participant
      final conversationDoc =
          await _db.collection('conversations').doc(conversationId).get();

      if (!conversationDoc.exists) {
        throw Exception(
          'Conversation $conversationId does not exist! Message was saved but conversation is missing.',
        );
      }

      final participants = List<String>.from(
        conversationDoc.data()?['participants'] ?? [],
      );
      print('🔵 Found conversation with participants: $participants');

      final otherUserId = participants.firstWhere(
        (uid) => uid != senderId,
        orElse: () => '',
      );

      if (otherUserId.isEmpty) {
        throw Exception('Could not find other participant in conversation');
      }

      print('🔵 Other user ID: $otherUserId');

      // Update conversation last message and OTHER user's unread count
      await _db.collection('conversations').doc(conversationId).update({
        'lastMessage': text,
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
        'unreadCounts.$otherUserId': FieldValue.increment(1),
      });

      print('✅ Conversation updated with new message');

      // Send notification to other participant
      if (otherUserId.isNotEmpty) {
        await _notificationService.sendNotification(
          otherUserId,
          'new_message',
          'New message from $senderName',
          text.length > 50 ? '${text.substring(0, 50)}...' : text,
          conversationId,
        );
        print('✅ Notification sent to $otherUserId');
      }

      return message;
    } catch (e) {
      print('❌ Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  // ── Real time stream of messages in a conversation ────────────────────────
  Stream<List<MessageModel>> messagesStream(String conversationId) {
    print(
      '🔵 ChatService.messagesStream(): Setting up stream for $conversationId',
    );
    return _db
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          final messages =
              snapshot.docs
                  .map((doc) => MessageModel.fromMap(doc.data()))
                  .toList();
          print(
            '🔵 ChatService.messagesStream(): Got ${messages.length} messages',
          );
          return messages;
        })
        .handleError((error) {
          print('❌ Error in messagesStream: $error');
          throw error;
        });
  }

  // ── Real time stream of all conversations for a user ─────────────────────
  Stream<List<ConversationModel>> conversationsStream(String uid) {
    print('🔵 ChatService.conversationsStream(): Setting up stream for $uid');
    return _db
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          final conversations =
              snapshot.docs.map((doc) {
                print('🔵   Found conversation: ${doc.id}');
                print('       Participants: ${doc.data()['participants']}');
                print('       Last message: ${doc.data()['lastMessage']}');
                return ConversationModel.fromMap(doc.data());
              }).toList();
          print(
            '🔵 ChatService.conversationsStream(): Got ${conversations.length} conversations for $uid',
          );
          if (conversations.isEmpty) {
            print('⚠️ WARNING: No conversations found for user $uid');
          }
          return conversations;
        })
        .handleError((error) {
          print('❌ Error in conversationsStream: $error');
          print('   Stack trace: $error');
          throw error;
        });
  }

  // ── Mark conversation as read for current user ──────────────────────────
  Future<void> markAsRead(String conversationId, String userId) async {
    try {
      await _db.collection('conversations').doc(conversationId).update({
        'unreadCounts.$userId': 0,
      });
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  // ── Get a single conversation ─────────────────────────────────────────────
  Future<ConversationModel?> getConversation(String id) async {
    try {
      final doc = await _db.collection('conversations').doc(id).get();

      if (doc.exists) {
        return ConversationModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get conversation: $e');
    }
  }
}
