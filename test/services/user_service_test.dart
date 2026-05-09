
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap_app/models/user_model.dart';
import 'package:skillswap_app/services/user_service.dart';

void main() {
  group('UserService', () {
    late FakeFirebaseFirestore firestore;
    late UserService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = UserService(db: firestore);
    });

    UserModel user({
      required String uid,
      required String firstName,
      required String lastName,
      required String email,
      required String course,
      required bool showFullName,
      required bool showCourse,
      required bool showPhoto,
      List<String> savedListingIds = const [],
    }) {
      return UserModel(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        course: course,
        bio: 'Bio for $firstName',
        rating: 4.5,
        sessionsCompleted: 8,
        memberSince: DateTime(2024, 1, 1),
        showFullName: showFullName,
        showCourse: showCourse,
        showPhoto: showPhoto,
        savedListingIds: savedListingIds,
      );
    }

    test('getUser() returns correct UserModel', () async {
      await firestore.collection('users').doc('user_1').set(
            user(
              uid: 'user_1',
              firstName: 'Jamie',
              lastName: 'Smith',
              email: 'jamie@myport.ac.uk',
              course: 'Computer Science',
              showFullName: true,
              showCourse: true,
              showPhoto: false,
            ).toMap(),
          );

      final result = await service.getUser('user_1');

      expect(result, isNotNull);
      expect(result!.uid, 'user_1');
      expect(result.firstName, 'Jamie');
      expect(result.lastName, 'Smith');
      expect(result.email, 'jamie@myport.ac.uk');
      expect(result.course, 'Computer Science');
      expect(result.showPhoto, isFalse);
    });

    test('getUser() returns null when not found', () async {
      final result = await service.getUser('missing_user');

      expect(result, isNull);
    });

    test('updateUser() only changes provided fields', () async {
      await firestore.collection('users').doc('user_1').set(
            user(
              uid: 'user_1',
              firstName: 'Jamie',
              lastName: 'Smith',
              email: 'jamie@myport.ac.uk',
              course: 'Computer Science',
              showFullName: true,
              showCourse: true,
              showPhoto: false,
            ).toMap(),
          );

      await service.updateUser('user_1', {'bio': 'Updated bio'});

      final doc = await firestore.collection('users').doc('user_1').get();
      final data = doc.data()!;
      expect(data['bio'], 'Updated bio');
      expect(data['firstName'], 'Jamie');
      expect(data['course'], 'Computer Science');
      expect(data['showPhoto'], isFalse);
    });

    test('updatePrivacySettings() updates all 3 booleans', () async {
      await firestore.collection('users').doc('user_1').set(
            user(
              uid: 'user_1',
              firstName: 'Jamie',
              lastName: 'Smith',
              email: 'jamie@myport.ac.uk',
              course: 'Computer Science',
              showFullName: true,
              showCourse: true,
              showPhoto: true,
            ).toMap(),
          );

      await service.updatePrivacySettings(
        'user_1',
        showFullName: false,
        showCourse: false,
        showPhoto: true,
      );

      final doc = await firestore.collection('users').doc('user_1').get();
      final data = doc.data()!;
      expect(data['showFullName'], isFalse);
      expect(data['showCourse'], isFalse);
      expect(data['showPhoto'], isTrue);
    });

    test('userStream() emits UserModel on change', () async {
      await firestore.collection('users').doc('user_1').set(
            user(
              uid: 'user_1',
              firstName: 'Jamie',
              lastName: 'Smith',
              email: 'jamie@myport.ac.uk',
              course: 'Computer Science',
              showFullName: true,
              showCourse: true,
              showPhoto: false,
            ).toMap(),
          );

      final expectation = expectLater(
        service.userStream('user_1'),
        emitsInOrder([
          predicate((UserModel? user) => user != null && user.firstName == 'Jamie'),
          predicate((UserModel? user) => user != null && user.bio == 'Updated from stream'),
        ]),
      );

      await firestore.collection('users').doc('user_1').update({'bio': 'Updated from stream'});
      await expectation;
    });
  });
}