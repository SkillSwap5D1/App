import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String requestId;
  final int rating;
  final String comment;
  final bool isPublished;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.requestId,
    required this.rating,
    required this.comment,
    required this.isPublished,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id:          map['id']          ?? '',
      fromUserId:  map['fromUserId']  ?? '',
      toUserId:    map['toUserId']    ?? '',
      requestId:   map['requestId']  ?? '',
      rating:      (map['rating']    ?? 0).toInt(),
      comment:     map['comment']    ?? '',
      isPublished: map['isPublished'] ?? false,
      createdAt:   (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':          id,
      'fromUserId':  fromUserId,
      'toUserId':    toUserId,
      'requestId':   requestId,
      'rating':      rating,
      'comment':     comment,
      'isPublished': isPublished,
      'createdAt':   Timestamp.fromDate(createdAt),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? requestId,
    int? rating,
    String? comment,
    bool? isPublished,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id:          id          ?? this.id,
      fromUserId:  fromUserId  ?? this.fromUserId,
      toUserId:    toUserId    ?? this.toUserId,
      requestId:   requestId   ?? this.requestId,
      rating:      rating      ?? this.rating,
      comment:     comment     ?? this.comment,
      isPublished: isPublished ?? this.isPublished,
      createdAt:   createdAt   ?? this.createdAt,
    );
  }
}
