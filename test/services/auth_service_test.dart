import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:skillswap_app/models/user_model.dart';
import 'package:skillswap_app/services/auth_service.dart';

class _TestGoogleSignIn extends GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signIn() async => null;

  @override
  Future<GoogleSignInAccount?> signOut() async => null;
}

void main() {
  group('AuthService', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    AuthService _buildService(MockFirebaseAuth auth) {
      return AuthService(
        auth: auth,
        db: firestore,
        googleSignIn: _TestGoogleSignIn(),
      );
    }

    test('signIn() with valid @myport.ac.uk email succeeds', () async {
      final mockUser = MockUser(
        uid: 'user_123',
        email: 'jamie@port.ac.uk',
        displayName: 'Jamie Smith',
      );
      final auth = MockFirebaseAuth(mockUser: mockUser);
      final service = _buildService(auth);

      await firestore.collection('users').doc('user_123').set(
            UserModel(
              uid: 'user_123',
              firstName: 'Jamie',
              lastName: 'Smith',
              email: 'jamie@port.ac.uk',
              course: 'Computer Science',
              bio: '',
              rating: 4.5,
              sessionsCompleted: 2,
              memberSince: DateTime(2024, 1, 1),
              showFullName: true,
              showCourse: true,
              showPhoto: true,
            ).toMap(),
          );

      final result = await service.signIn('jamie@port.ac.uk', 'password123');

      expect(result, isNotNull);
      expect(result!.uid, 'user_123');
      expect(result.firstName, 'Jamie');
      expect(auth.currentUser?.uid, 'user_123');
    });

    test('signIn() with @gmail.com email throws before Firebase call', () async {
      final auth = MockFirebaseAuth();
      whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
          .on(auth)
          .thenThrow(Exception('Firebase should not be called'));
      final service = _buildService(auth);

      await expectLater(
        service.signIn('jamie@gmail.com', 'password123'),
        throwsA(
          predicate((error) =>
              error is Exception && error.toString().contains('University of Portsmouth')),
        ),
      );
    });

    test('signIn() with wrong password throws FirebaseAuthException', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'user_123', email: 'jamie@port.ac.uk'),
      );
      whenCalling(
        Invocation.method(
          #signInWithEmailAndPassword,
          null,
          {#email: 'jamie@port.ac.uk', #password: 'wrongpass'},
        ),
      ).on(auth).thenThrow(
        FirebaseAuthException(code: 'wrong-password', message: 'Wrong password'),
      );
      final service = _buildService(auth);

      await expectLater(
        service.signIn('jamie@port.ac.uk', 'wrongpass'),
        throwsA(
          predicate((error) =>
              error is Exception && error.toString().contains('wrong-password')),
        ),
      );
    });

    test('signIn() with unregistered email throws FirebaseAuthException', () async {
      final auth = MockFirebaseAuth();
      whenCalling(
        Invocation.method(
          #signInWithEmailAndPassword,
          null,
          {#email: 'jamie@port.ac.uk', #password: 'password123'},
        ),
      ).on(auth).thenThrow(
        FirebaseAuthException(code: 'user-not-found', message: 'No user found'),
      );
      final service = _buildService(auth);

      await expectLater(
        service.signIn('jamie@port.ac.uk', 'password123'),
        throwsA(
          predicate((error) =>
              error is Exception && error.toString().contains('user-not-found')),
        ),
      );
    });

    test('register() with valid all fields creates user in Firestore', () async {
      final auth = MockFirebaseAuth();
      final service = _buildService(auth);

      final result = await service.register(
        email: 'jamie@port.ac.uk',
        password: 'password123',
        firstName: 'Jamie',
        lastName: 'Smith',
        course: 'Computer Science',
      );

      expect(result, isNotNull);
      expect(result!.email, 'jamie@port.ac.uk');
      expect(auth.currentUser, isNotNull);

      final doc = await firestore.collection('users').doc(auth.currentUser!.uid).get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['firstName'], 'Jamie');
      expect(doc.data()?['lastName'], 'Smith');
      expect(doc.data()?['email'], 'jamie@port.ac.uk');
      expect(doc.data()?['course'], 'Computer Science');
      expect(doc.data()?['showFullName'], isTrue);
      expect(doc.data()?['showCourse'], isTrue);
      expect(doc.data()?['showPhoto'], isTrue);
    });

    test('register() with @hotmail.com email throws before Firebase call', () async {
      final auth = MockFirebaseAuth();
      whenCalling(Invocation.method(#createUserWithEmailAndPassword, null))
          .on(auth)
          .thenThrow(Exception('Firebase should not be called'));
      final service = _buildService(auth);

      await expectLater(
        service.register(
          email: 'jamie@hotmail.com',
          password: 'password123',
          firstName: 'Jamie',
          lastName: 'Smith',
          course: 'Computer Science',
        ),
        throwsA(
          predicate((error) =>
              error is Exception && error.toString().contains('University of Portsmouth')),
        ),
      );
    });

    test('register() with duplicate email throws FirebaseAuthException', () async {
      final auth = MockFirebaseAuth();
      whenCalling(
        Invocation.method(
          #createUserWithEmailAndPassword,
          null,
          {#email: 'jamie@port.ac.uk', #password: 'password123'},
        ),
      ).on(auth).thenThrow(
        FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'Email already in use',
        ),
      );
      final service = _buildService(auth);

      await expectLater(
        service.register(
          email: 'jamie@port.ac.uk',
          password: 'password123',
          firstName: 'Jamie',
          lastName: 'Smith',
          course: 'Computer Science',
        ),
        throwsA(
          predicate((error) => error is Exception && error.toString().contains('email-already-in-use')),
        ),
      );
    });

    test('register() password less than 6 chars throws before Firebase call', () async {
      final auth = MockFirebaseAuth();
      whenCalling(Invocation.method(#createUserWithEmailAndPassword, null))
          .on(auth)
          .thenThrow(Exception('Firebase should not be called'));
      final service = _buildService(auth);

      await expectLater(
        service.register(
          email: 'jamie@port.ac.uk',
          password: '12345',
          firstName: 'Jamie',
          lastName: 'Smith',
          course: 'Computer Science',
        ),
        throwsA(
          predicate((error) => error is Exception && error.toString().contains('Password must be at least 6 characters')),
        ),
      );
    });

    test('register() password exactly 6 chars succeeds', () async {
      final auth = MockFirebaseAuth();
      final service = _buildService(auth);

      final result = await service.register(
        email: 'jamie@port.ac.uk',
        password: '123456',
        firstName: 'Jamie',
        lastName: 'Smith',
        course: 'Computer Science',
      );

      expect(result, isNotNull);
      expect(result!.email, 'jamie@port.ac.uk');
      final doc = await firestore.collection('users').doc(auth.currentUser!.uid).get();
      expect(doc.exists, isTrue);
    });

    test('signOut() sets currentUser to null', () async {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user_123', email: 'jamie@port.ac.uk'),
      );
      final service = _buildService(auth);

      expect(auth.currentUser, isNotNull);
      await service.signOut();
      expect(auth.currentUser, isNull);
    });

    test('_handleAuthError("user-not-found") returns correct message', () {
      final service = _buildService(MockFirebaseAuth());

      expect(service.handleAuthError('user-not-found'), 'No user found for that email');
    });

    test('_handleAuthError("wrong-password") returns correct message', () {
      final service = _buildService(MockFirebaseAuth());

      expect(service.handleAuthError('wrong-password'), 'Incorrect password');
    });

    test('_handleAuthError("unknown-code") returns generic fallback message', () {
      final service = _buildService(MockFirebaseAuth());

      expect(service.handleAuthError('unknown-code'), 'Something went wrong. Please try again.');
    });
  });
}