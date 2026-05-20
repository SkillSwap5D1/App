import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageStatus { pending, sent, failed }

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final MessageStatus status;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isRead,
    this.status = MessageStatus.sent,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id:             map['id']             ?? '',
      conversationId: map['conversationId'] ?? '',
      senderId:       map['senderId']       ?? '',
      text:           map['text']           ?? '',
      timestamp:      (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead:         map['isRead']         ?? false,
      status:         MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${map['status'] ?? 'sent'}',
        orElse: () => MessageStatus.sent,
      ),
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
      'status':         status.toString().split('.').last,
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? text,
    DateTime? timestamp,
    bool? isRead,
    MessageStatus? status,
  }) {
    return MessageModel(
      id:             id             ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId:       senderId       ?? this.senderId,
      text:           text           ?? this.text,
      timestamp:      timestamp      ?? this.timestamp,
      isRead:         isRead         ?? this.isRead,
      status:         status         ?? this.status,
    );
  }
}