import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final String listingId;
  final String skillName;
  final String message;
  final String status;
  final List<String> proposedTimes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RequestModel({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.listingId,
    required this.skillName,
    required this.message,
    required this.status,
    required this.proposedTimes,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── Convert Firestore data → Dart object ──────────────────────────────────
  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      id: map['id'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      fromUserName: map['fromUserName'] ?? '',
      toUserId: map['toUserId'] ?? '',
      toUserName: map['toUserName'] ?? '',
      listingId: map['listingId'] ?? '',
      skillName: map['skillName'] ?? '',
      message: map['message'] ?? '',
      status: map['status'] ?? 'pending',
      proposedTimes: List<String>.from(map['proposedTimes'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ── Convert Dart object → Firestore data ──────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'listingId': listingId,
      'skillName': skillName,
      'message': message,
      'status': status,
      'proposedTimes': proposedTimes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // ── Update individual fields ───────────────────────────────────────────────
  RequestModel copyWith({
    String? id,
    String? fromUserId,
    String? fromUserName,
    String? toUserId,
    String? toUserName,
    String? listingId,
    String? skillName,
    String? message,
    String? status,
    List<String>? proposedTimes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RequestModel(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      toUserId: toUserId ?? this.toUserId,
      toUserName: toUserName ?? this.toUserName,
      listingId: listingId ?? this.listingId,
      skillName: skillName ?? this.skillName,
      message: message ?? this.message,
      status: status ?? this.status,
      proposedTimes: proposedTimes ?? this.proposedTimes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ── Helper getters ─────────────────────────────────────────────────────────
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';
  bool get isCountered => status == 'countered';
}
