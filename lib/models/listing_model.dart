import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String title;
  final String description;
  final List<String> tags;
  final String level;
  final String modality;
  final String category;
  final String nextAvailable;
  final bool isActive;
  final DateTime createdAt;

  const ListingModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.title,
    required this.description,
    required this.tags,
    required this.level,
    required this.modality,
    required this.category,
    required this.nextAvailable,
    required this.isActive,
    required this.createdAt,
  });

  // ── Convert Firestore data → Dart object ──────────────────────────────────
  factory ListingModel.fromMap(Map<String, dynamic> map) {
    return ListingModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      level: map['level'] ?? '',
      modality: map['modality'] ?? '',
      category: map['category'] ?? '',
      nextAvailable: map['nextAvailable'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ── Convert Dart object → Firestore data ──────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'title': title,
      'description': description,
      'tags': tags,
      'level': level,
      'modality': modality,
      'category': category,
      'nextAvailable': nextAvailable,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // ── Update individual fields ───────────────────────────────────────────────
  ListingModel copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? title,
    String? description,
    List<String>? tags,
    String? level,
    String? modality,
    String? category,
    String? nextAvailable,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ListingModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      level: level ?? this.level,
      modality: modality ?? this.modality,
      category: category ?? this.category,
      nextAvailable: nextAvailable ?? this.nextAvailable,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
