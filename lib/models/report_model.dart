import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String reporterId;
  final String reporteeId;
  final String reason;
  final String description;
  final String? requestId; // Optional link to specific request
  final List<String> evidence; // URLs or file paths
  final String status; // pending, reviewed, resolved, dismissed
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReportModel({
    required this.id,
    required this.reporterId,
    required this.reporteeId,
    required this.reason,
    required this.description,
    this.requestId,
    required this.evidence,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] ?? '',
      reporterId: map['reporterId'] ?? '',
      reporteeId: map['reporteeId'] ?? '',
      reason: map['reason'] ?? '',
      description: map['description'] ?? '',
      requestId: map['requestId'],
      evidence: List<String>.from(map['evidence'] ?? []),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reporteeId': reporteeId,
      'reason': reason,
      'description': description,
      'requestId': requestId,
      'evidence': evidence,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ReportModel copyWith({
    String? id,
    String? reporterId,
    String? reporteeId,
    String? reason,
    String? description,
    String? requestId,
    List<String>? evidence,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reporteeId: reporteeId ?? this.reporteeId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      requestId: requestId ?? this.requestId,
      evidence: evidence ?? this.evidence,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ── Report reasons ─────────────────────────────────────────────────────────
  static const List<String> reasons = [
    'Inappropriate behavior',
    'Offensive language',
    'No-show for session',
    'Didn\'t follow agreed terms',
    'Suspicious activity',
    'Other',
  ];
}
