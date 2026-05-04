import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatService {
  // ── Firebase instance ─────────────────────────────────────────────────────
  final FirebaseFirestore _db;

  ChatService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  // ── Get or create a conversation between 2 users ─────────────────────────
  Future<String> getOrCreateConversation(
    String uid1,
    String uid2,
  ) async {
    try {
      // Check if conversation already exists
      final existing = await _db
          .collection('conversations')
          .where('participants', arrayContains: uid1)
          .get();

      for (final doc in existing.docs) {
        final participants = List<String>.from(
          doc.data()['participants'] ?? []
        );
        if (participants.contains(uid2)) {
          // Conversation already exists — return its ID
          return doc.id;
        }
      }

      // No existing conversation — create a new one
      final docRef = _db.collection('conversations').doc();
      final conversation = ConversationModel(
        id:              docRef.id,
        participants:    [uid1, uid2],
        lastMessage:     '',
        lastMessageTime: DateTime.now(),
        unreadCount:     0,
      );

      await docRef.set(conversation.toMap());
      return docRef.id;

    } catch (e) {
      throw Exception('Failed to get or create conversation: $e');
    }
  }

  // ── Send a message ────────────────────────────────────────────────────────
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    try {
      // Create new message document
      final msgRef = _db.collection('messages').doc();
      final message = MessageModel(
        id:             msgRef.id,
        conversationId: conversationId,
        senderId:       senderId,
        text:           text,
        timestamp:      DateTime.now(),
        isRead:         false,
      );

      // Save message
      await msgRef.set(message.toMap());

      // Update conversation last message
      await _db
          .collection('conversations')
          .doc(conversationId)
          .update({
            'lastMessage':     text,
            'lastMessageTime': Timestamp.fromDate(DateTime.now()),
            'unreadCount':     FieldValue.increment(1),
          });

    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // ── Real time stream of messages in a conversation ────────────────────────
  Stream<List<MessageModel>> messagesStream(String conversationId) {
    return _db
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data()))
            .toList());
  }

  // ── Real time stream of all conversations for a user ─────────────────────
  Stream<List<ConversationModel>> conversationsStream(String uid) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromMap(doc.data()))
            .toList());
  }

  // ── Mark conversation as read ─────────────────────────────────────────────
  Future<void> markAsRead(String conversationId) async {
    try {
      await _db
          .collection('conversations')
          .doc(conversationId)
          .update({'unreadCount': 0});
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  // ── Get a single conversation ─────────────────────────────────────────────
  Future<ConversationModel?> getConversation(String id) async {
    try {
      final doc = await _db
          .collection('conversations')
          .doc(id)
          .get();

      if (doc.exists) {
        return ConversationModel.fromMap(doc.data()!);
      }
      return null;

    } catch (e) {
      throw Exception('Failed to get conversation: $e');
    }
  }
}