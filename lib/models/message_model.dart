import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isRead,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id:             map['id']             ?? '',
      conversationId: map['conversationId'] ?? '',
      senderId:       map['senderId']       ?? '',
      text:           map['text']           ?? '',
      timestamp:      (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead:         map['isRead']         ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':             id,
      'conversationId': conversationId,
      'senderId':       senderId,
      'text':           text,
      'timestamp':      Timestamp.fromDate(timestamp),
      'isRead':         isRead,
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? text,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return MessageModel(
      id:             id             ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId:       senderId       ?? this.senderId,
      text:           text           ?? this.text,
      timestamp:      timestamp      ?? this.timestamp,
      isRead:         isRead         ?? this.isRead,
    );
  }
}