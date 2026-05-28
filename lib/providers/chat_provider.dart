import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  // ── State ─────────────────────────────────────────────────────────────────
  List<ConversationModel> conversations = [];
  List<MessageModel> currentMessages = [];
  String? activeConversationId;
  bool isLoading = false;

  // ──Stream subscriptions ───────────────────────────────────────────────────
  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _messagesSubscription;

  // ── Load conversations for a user ─────────────────────────────────────────
  Future<void> loadConversations(String uid) async {
    _conversationsSubscription?.cancel();
    isLoading = true;
    notifyListeners();

    try {
      _conversationsSubscription = _chatService.conversationsStream(uid).listen(
        (convs) {
          conversations = convs;
          notifyListeners();
        },
      );
      isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading conversations: $e');
      }
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Open a conversation and load messages ─────────────────────────────────
  Future<void> openConversation(String conversationId, String userId) async {
    _messagesSubscription?.cancel();
    activeConversationId = conversationId;
    currentMessages = [];
    notifyListeners();

    try {
      // Debug log for re-subscribing to messagesStream
      if (kDebugMode) {
        print(
          '🔵 ChatProvider: Re-subscribing to messagesStream for conversation $conversationId',
        );
      }

      _messagesSubscription = _chatService.messagesStream(conversationId).listen((
        messages,
      ) {
        currentMessages = messages;
        if (kDebugMode) {
          print(
            '🔵 ChatProvider: Received ${messages.length} messages for conversation $conversationId',
          );
        }
        notifyListeners();
      });

      // Mark conversation as read for current user
      if (kDebugMode) {
        print(
          '🔵 ChatProvider: Marking conversation $conversationId as read for $userId',
        );
      }
      await markAsRead(conversationId, userId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading messages: $e');
      }
    }
  }

  // ── Send a message ───────────────────────────────────────────────────────
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
    String? recipientId,
  }) async {
    try {
      if (kDebugMode) {
        print(
          '🔵 ChatProvider.sendMessage(): Sending message to $conversationId',
        );
        print('   Sender: $senderId ($senderName)');
        print('   Text length: ${text.length}');
      }

      final sentMessage = await _chatService.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        text: text,
        recipientId: recipientId,
      );

      if (activeConversationId == conversationId) {
        currentMessages = [...currentMessages, sentMessage];
        notifyListeners();
      }
      if (kDebugMode) {
        print('✅ Message sent successfully: ${sentMessage.id}');
      }
      return sentMessage;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending message: $e');
        print('   Stack trace: $e');
      }
      rethrow;
    }
  }

  // ── Mark conversation as read ───────────────────────────────────────────
  Future<void> markAsRead(String conversationId, String userId) async {
    try {
      await _chatService.markAsRead(conversationId, userId);
    } catch (e) {
      if (kDebugMode) {
        print('Error marking as read: $e');
      }
    }
  }

  // ── Get total unread count ──────────────────────────────────────────────
  int get totalUnreadCount {
    return conversations.fold(
      0,
      (sum, conv) =>
          sum +
          (conv.unreadCounts.values.isNotEmpty
              ? conv.unreadCounts.values.first
              : 0),
    );
  }

  // ── Start a new conversation ─────────────────────────────────────────────
  Future<String> startConversation(
    String currentUserId,
    String otherUserId,
  ) async {
    try {
      if (kDebugMode) {
        print(
          '🔵 ChatProvider.startConversation(): Starting chat with $otherUserId',
        );
      }
      final conversationId = await _chatService.getOrCreateConversation(
        currentUserId,
        otherUserId,
      );
      if (kDebugMode) {
        print('✅ Conversation created/fetched: $conversationId');
      }
      return conversationId;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error starting conversation: $e');
      }
      rethrow;
    }
  }

  // ── Cleanup subscriptions ────────────────────────────────────────────────
  @override
  void dispose() {
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
