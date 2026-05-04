import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap_app/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromMap() populates all fields correctly', () {
      final createdAt = DateTime(2024, 1, 15, 10, 30);
      final model = UserModel.fromMap({
        'uid': 'test_uid',
        'firstName': 'Jamie',
        'lastName': 'Smith',
        'email': 'jamie@example.com',
        'course': 'Computer Science',
        'bio': 'Enjoys teaching',
        'rating': 4.8,
        'sessionsCompleted': 12,
        'memberSince': Timestamp.fromDate(createdAt),
        'showFullName': false,
        'showCourse': true,
        'showPhoto': false,
        'savedListingIds': ['listing_1', 'listing_2'],
      });

      expect(model.uid, 'test_uid');
      expect(model.firstName, 'Jamie');
      expect(model.lastName, 'Smith');
      expect(model.email, 'jamie@example.com');
      expect(model.course, 'Computer Science');
      expect(model.bio, 'Enjoys teaching');
      expect(model.rating, 4.8);
      expect(model.sessionsCompleted, 12);
      expect(model.memberSince, createdAt);
      expect(model.showFullName, isFalse);
      expect(model.showCourse, isTrue);
      expect(model.showPhoto, isFalse);
      expect(model.savedListingIds, ['listing_1', 'listing_2']);
    });

    test('fromMap() with null fields returns safe defaults', () {
      final model = UserModel.fromMap(<String, dynamic>{});

      expect(model.uid, '');
      expect(model.firstName, '');
      expect(model.lastName, '');
      expect(model.email, '');
      expect(model.course, '');
      expect(model.bio, '');
      expect(model.rating, 0.0);
      expect(model.sessionsCompleted, 0);
      expect(model.memberSince, isNotNull);
      expect(model.showFullName, isTrue);
      expect(model.showCourse, isTrue);
      expect(model.showPhoto, isTrue);
      expect(model.savedListingIds, isEmpty);
    });

    test('toMap() returns all expected fields', () {
      final memberSince = DateTime(2024, 1, 15, 10, 30);
      final model = UserModel(
        uid: 'test_uid',
        firstName: 'Jamie',
        lastName: 'Smith',
        email: 'jamie@example.com',
        course: 'Computer Science',
        bio: 'Enjoys teaching',
        rating: 4.8,
        sessionsCompleted: 12,
        memberSince: memberSince,
        showFullName: false,
        showCourse: true,
        showPhoto: false,
        savedListingIds: ['listing_1', 'listing_2'],
      );

      final map = model.toMap();

      expect(map['uid'], 'test_uid');
      expect(map['firstName'], 'Jamie');
      expect(map['lastName'], 'Smith');
      expect(map['email'], 'jamie@example.com');
      expect(map['course'], 'Computer Science');
      expect(map['bio'], 'Enjoys teaching');
      expect(map['rating'], 4.8);
      expect(map['sessionsCompleted'], 12);
      expect(map['memberSince'], Timestamp.fromDate(memberSince));
      expect(map['showFullName'], isFalse);
      expect(map['showCourse'], isTrue);
      expect(map['showPhoto'], isFalse);
      expect(map['savedListingIds'], ['listing_1', 'listing_2']);
    });

    test('toMap() round trip preserves all fields', () {
      final original = UserModel(
        uid: 'test_uid',
        firstName: 'Jamie',
        lastName: 'Smith',
        email: 'jamie@example.com',
        course: 'Computer Science',
        bio: 'Enjoys teaching',
        rating: 4.8,
        sessionsCompleted: 12,
        memberSince: DateTime(2024, 1, 15, 10, 30),
        showFullName: false,
        showCourse: true,
        showPhoto: false,
        savedListingIds: ['listing_1', 'listing_2'],
      );

      final roundTrip = UserModel.fromMap(original.toMap());

      expect(roundTrip.uid, original.uid);
      expect(roundTrip.firstName, original.firstName);
      expect(roundTrip.lastName, original.lastName);
      expect(roundTrip.email, original.email);
      expect(roundTrip.course, original.course);
      expect(roundTrip.bio, original.bio);
      expect(roundTrip.rating, original.rating);
      expect(roundTrip.sessionsCompleted, original.sessionsCompleted);
      expect(roundTrip.memberSince, original.memberSince);
      expect(roundTrip.showFullName, original.showFullName);
      expect(roundTrip.showCourse, original.showCourse);
      expect(roundTrip.showPhoto, original.showPhoto);
      expect(roundTrip.savedListingIds, original.savedListingIds);
    });

    test('copyWith() changes one field and keeps others unchanged', () {
      final original = UserModel(
        uid: 'test_uid',
        firstName: 'Jamie',
        lastName: 'Smith',
        email: 'jamie@example.com',
        course: 'Computer Science',
        bio: 'Enjoys teaching',
        rating: 4.8,
        sessionsCompleted: 12,
        memberSince: DateTime(2024, 1, 15, 10, 30),
        showFullName: false,
        showCourse: true,
        showPhoto: false,
        savedListingIds: ['listing_1', 'listing_2'],
      );

      final updated = original.copyWith(firstName: 'Jordan');

      expect(updated.firstName, 'Jordan');
      expect(updated.uid, original.uid);
      expect(updated.lastName, original.lastName);
      expect(updated.email, original.email);
      expect(updated.course, original.course);
      expect(updated.bio, original.bio);
      expect(updated.rating, original.rating);
      expect(updated.sessionsCompleted, original.sessionsCompleted);
      expect(updated.memberSince, original.memberSince);
      expect(updated.showFullName, original.showFullName);
      expect(updated.showCourse, original.showCourse);
      expect(updated.showPhoto, original.showPhoto);
      expect(updated.savedListingIds, original.savedListingIds);
    });

    test('copyWith() with no changes returns equivalent object', () {
      final original = UserModel(
        uid: 'test_uid',
        firstName: 'Jamie',
        lastName: 'Smith',
        email: 'jamie@example.com',
        course: 'Computer Science',
        bio: 'Enjoys teaching',
        rating: 4.8,
        sessionsCompleted: 12,
        memberSince: DateTime(2024, 1, 15, 10, 30),
        showFullName: false,
        showCourse: true,
        showPhoto: false,
        savedListingIds: ['listing_1', 'listing_2'],
      );

      final copied = original.copyWith();

      expect(copied.uid, original.uid);
      expect(copied.firstName, original.firstName);
      expect(copied.lastName, original.lastName);
      expect(copied.email, original.email);
      expect(copied.course, original.course);
      expect(copied.bio, original.bio);
      expect(copied.rating, original.rating);
      expect(copied.sessionsCompleted, original.sessionsCompleted);
      expect(copied.memberSince, original.memberSince);
      expect(copied.showFullName, original.showFullName);
      expect(copied.showCourse, original.showCourse);
      expect(copied.showPhoto, original.showPhoto);
      expect(copied.savedListingIds, original.savedListingIds);
    });

    test('fullName, displayName, and initials getters return expected values', () {
      final model = UserModel(
        uid: 'test_uid',
        firstName: 'Jamie',
        lastName: 'Smith',
        email: 'jamie@example.com',
        course: 'Computer Science',
        bio: 'Enjoys teaching',
        rating: 4.8,
        sessionsCompleted: 12,
        memberSince: DateTime(2024, 1, 15, 10, 30),
        showFullName: true,
        showCourse: true,
        showPhoto: true,
      );

      expect(model.fullName, 'Jamie Smith');
      expect(model.displayName, 'Jamie S.');
      expect(model.initials, 'J');
    });
  });
}