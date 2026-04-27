import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String requestId;
  final String reviewerId;
  final String revieweeId;
  final int rating;
  final String text;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReviewModel({
    required this.id,
    required this.requestId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    required this.text,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── Convert Firestore data → Dart object ──────────────────────────────────
  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      requestId: map['requestId'] ?? '',
      reviewerId: map['reviewerId'] ?? '',
      revieweeId: map['revieweeId'] ?? '',
      rating: (map['rating'] ?? 0).toInt(),
      text: map['text'] ?? '',
      isPublished: map['isPublished'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ── Convert Dart object → Firestore data ──────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requestId': requestId,
      'reviewerId': reviewerId,
      'revieweeId': revieweeId,
      'rating': rating,
      'text': text,
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // ── Update individual fields without changing others ──────────────────────
  ReviewModel copyWith({
    String? id,
    String? requestId,
    String? reviewerId,
    String? revieweeId,
    int? rating,
    String? text,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      reviewerId: reviewerId ?? this.reviewerId,
      revieweeId: revieweeId ?? this.revieweeId,
      rating: rating ?? this.rating,
      text: text ?? this.text,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
