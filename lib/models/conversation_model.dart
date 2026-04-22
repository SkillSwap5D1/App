import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  const ConversationModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id:              map['id']          ?? '',
      participants:    List<String>.from(map['participants'] ?? []),
      lastMessage:     map['lastMessage'] ?? '',
      lastMessageTime: (map['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount:     (map['unreadCount'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':              id,
      'participants':    participants,
      'lastMessage':     lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCount':     unreadCount,
    };
  }

  ConversationModel copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return ConversationModel(
      id:              id              ?? this.id,
      participants:    participants    ?? this.participants,
      lastMessage:     lastMessage     ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount:     unreadCount     ?? this.unreadCount,
    );
  }

  // ── Helper — get the other user's ID ─────────────────────────────────────
  String getOtherUserId(String myUid) {
    return participants.firstWhere(
      (id) => id != myUid,
      orElse: () => '',
    );
  }
}