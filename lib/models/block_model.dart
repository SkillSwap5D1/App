import 'package:cloud_firestore/cloud_firestore.dart';

class BlockModel {
  final String id;
  final String blockerId;
  final String blockedUserId;
  final String? reason;
  final DateTime createdAt;

  const BlockModel({
    required this.id,
    required this.blockerId,
    required this.blockedUserId,
    this.reason,
    required this.createdAt,
  });

  factory BlockModel.fromMap(Map<String, dynamic> map) {
    return BlockModel(
      id: map['id'] ?? '',
      blockerId: map['blockerId'] ?? '',
      blockedUserId: map['blockedUserId'] ?? '',
      reason: map['reason'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'blockerId': blockerId,
      'blockedUserId': blockedUserId,
      'reason': reason,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  BlockModel copyWith({
    String? id,
    String? blockerId,
    String? blockedUserId,
    String? reason,
    DateTime? createdAt,
  }) {
    return BlockModel(
      id: id ?? this.id,
      blockerId: blockerId ?? this.blockerId,
      blockedUserId: blockedUserId ?? this.blockedUserId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
