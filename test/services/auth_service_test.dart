
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skillswap_app/models/user_model.dart';
import 'package:skillswap_app/services/auth_service.dart';

class _TestGoogleSignIn extends GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signIn() async => null;

  @override
  Future<GoogleSignInAccount?> signOut() async => null;
}

class _ThrowingMockFirebaseAuth extends MockFirebaseAuth {
  _ThrowingMockFirebaseAuth({
    super.mockUser,
    this.signInError,
    this.registerError,
  });

  final FirebaseAuthException? signInError;
  final FirebaseAuthException? registerError;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (signInError != null) {
      throw signInError!;
    }
    return super.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (registerError != null) {
      throw registerError!;
    }
    return super.createUserWithEmailAndPassword(email: email, password: password);
  }
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
        email: 'jamie@myport.ac.uk',
        displayName: 'Jamie Smith',
      );
      final auth = MockFirebaseAuth(mockUser: mockUser);
      final service = _buildService(auth);

      await firestore.collection('users').doc('user_123').set(
            UserModel(
              uid: 'user_123',
              firstName: 'Jamie',
              lastName: 'Smith',
              email: 'jamie@myport.ac.uk',
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

      final result = await service.signIn('jamie@myport.ac.uk', 'password123');

      expect(result, isNotNull);
      expect(result!.uid, 'user_123');
      expect(result.firstName, 'Jamie');
      expect(auth.currentUser?.uid, 'user_123');
    });

    test('signIn() with @gmail.com email throws before Firebase call', () async {
      final auth = MockFirebaseAuth();
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
      final auth = _ThrowingMockFirebaseAuth(
        mockUser: MockUser(uid: 'user_123', email: 'jamie@myport.ac.uk'),
        signInError: FirebaseAuthException(
          code: 'wrong-password',
          message: 'Wrong password',
        ),
      );
      final service = _buildService(auth);

      await expectLater(
        service.signIn('jamie@myport.ac.uk', 'wrongpass'),
        throwsA(
          predicate((error) =>
              error is Exception && error.toString().contains('wrong-password')),
        ),
      );
    });

    test('signIn() with unregistered email throws FirebaseAuthException', () async {
      final auth = _ThrowingMockFirebaseAuth(
        signInError: FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found',
        ),
      );
      final service = _buildService(auth);

      await expectLater(
        service.signIn('jamie@myport.ac.uk', 'password123'),
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
        email: 'jamie@myport.ac.uk',
        password: 'password123',
        firstName: 'Jamie',
        lastName: 'Smith',
        course: 'Computer Science',
      );

      expect(result, isNotNull);
      expect(result!.email, 'jamie@myport.ac.uk');
      expect(auth.currentUser, isNotNull);

      final doc = await firestore.collection('users').doc(auth.currentUser!.uid).get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['firstName'], 'Jamie');
      expect(doc.data()?['lastName'], 'Smith');
      expect(doc.data()?['email'], 'jamie@myport.ac.uk');
      expect(doc.data()?['course'], 'Computer Science');
      expect(doc.data()?['showFullName'], isTrue);
      expect(doc.data()?['showCourse'], isTrue);
      expect(doc.data()?['showPhoto'], isTrue);
    });

    test('register() with @hotmail.com email throws before Firebase call', () async {
      final auth = MockFirebaseAuth();
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
      final auth = _ThrowingMockFirebaseAuth(
        registerError: FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'Email already in use',
        ),
      );
      final service = _buildService(auth);

      await expectLater(
        service.register(
          email: 'jamie@myport.ac.uk',
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
      final service = _buildService(auth);

      await expectLater(
        service.register(
          email: 'jamie@myport.ac.uk',
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
        email: 'jamie@myport.ac.uk',
        password: '123456',
        firstName: 'Jamie',
        lastName: 'Smith',
        course: 'Computer Science',
      );

      expect(result, isNotNull);
      expect(result!.email, 'jamie@myport.ac.uk');
      final doc = await firestore.collection('users').doc(auth.currentUser!.uid).get();
      expect(doc.exists, isTrue);
    });

    test('signOut() sets currentUser to null', () async {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user_123', email: 'jamie@myport.ac.uk'),
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

      expect(
        service.handleAuthError('wrong-password'),
        'Incorrect email or password. Please try again.',
      );
    });

    test('_handleAuthError("invalid-email") returns correct message', () {
      final service = _buildService(MockFirebaseAuth());

      expect(
        service.handleAuthError('invalid-email'),
        'Incorrect email or password. Please try again.',
      );
    });

    test('_handleAuthError("email-already-in-use") returns correct message', () {
      final service = _buildService(MockFirebaseAuth());

      expect(
        service.handleAuthError('email-already-in-use'),
        'This email is already registered',
      );
    });

    test('_handleAuthError("weak-password") returns correct message', () {
      final service = _buildService(MockFirebaseAuth());

      expect(
        service.handleAuthError('weak-password'),
        'Password must be at least 6 characters',
      );
    });

    test('_handleAuthError("unknown-code") returns generic fallback message', () {
      final service = _buildService(MockFirebaseAuth());

      expect(service.handleAuthError('unknown-code'), 'Something went wrong. Please try again.');
    });
  });
}