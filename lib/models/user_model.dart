import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String course;
  final String bio;
  final double rating;
  final int sessionsCompleted;
  final DateTime memberSince;
  final bool showFullName;
  final bool showCourse;
  final bool showPhoto;

  const UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.course,
    required this.bio,
    required this.rating,
    required this.sessionsCompleted,
    required this.memberSince,
    required this.showFullName,
    required this.showCourse,
    required this.showPhoto,
  });

  // ── Convert Firestore data → Dart object ──────────────────────────────────
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid:               map['uid']               ?? '',
      firstName:         map['firstName']         ?? '',
      lastName:          map['lastName']          ?? '',
      email:             map['email']             ?? '',
      course:            map['course']            ?? '',
      bio:               map['bio']               ?? '',
      rating:            (map['rating']           ?? 0.0).toDouble(),
      sessionsCompleted: (map['sessionsCompleted']?? 0).toInt(),
      memberSince:       (map['memberSince'] as Timestamp?)?.toDate() ?? DateTime.now(),
      showFullName:      map['showFullName']       ?? true,
      showCourse:        map['showCourse']         ?? true,
      showPhoto:         map['showPhoto']          ?? true,
    );
  }

  // ── Convert Dart object → Firestore data ──────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'uid':               uid,
      'firstName':         firstName,
      'lastName':          lastName,
      'email':             email,
      'course':            course,
      'bio':               bio,
      'rating':            rating,
      'sessionsCompleted': sessionsCompleted,
      'memberSince':       Timestamp.fromDate(memberSince),
      'showFullName':      showFullName,
      'showCourse':        showCourse,
      'showPhoto':         showPhoto,
    };
  }

  // ── Update individual fields without changing others ──────────────────────
  UserModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? course,
    String? bio,
    double? rating,
    int? sessionsCompleted,
    DateTime? memberSince,
    bool? showFullName,
    bool? showCourse,
    bool? showPhoto,
  }) {
    return UserModel(
      uid:               uid               ?? this.uid,
      firstName:         firstName         ?? this.firstName,
      lastName:          lastName          ?? this.lastName,
      email:             email             ?? this.email,
      course:            course            ?? this.course,
      bio:               bio               ?? this.bio,
      rating:            rating            ?? this.rating,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      memberSince:       memberSince       ?? this.memberSince,
      showFullName:      showFullName      ?? this.showFullName,
      showCourse:        showCourse        ?? this.showCourse,
      showPhoto:         showPhoto         ?? this.showPhoto,
    );
  }

  // ── Helper getters ─────────────────────────────────────────────────────────
  String get fullName    => '$firstName $lastName';
  String get displayName => '$firstName ${lastName[0]}.';
  String get initials    => firstName[0].toUpperCase();
}