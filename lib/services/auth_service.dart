import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  // ── Firebase instances ────────────────────────────────────────────────────
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Current user ──────────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  // ── Auth state stream — listens to login/logout ───────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Sign In ───────────────────────────────────────────────────────────────
  Future<UserModel?> signIn(String email, String password) async {
    try {
      // Validate UoP email
      if (!email.contains('@myport.ac.uk')) {
        throw Exception('Please use your University of Portsmouth email');
      }

      // Sign in with Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      final doc = await _db
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;

    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<UserModel?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String course,
  }) async {
    try {
      // Validate UoP email
      if (!email.contains('@myport.ac.uk')) {
        throw Exception('Please use your University of Portsmouth email');
      }

      // Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user model
      final user = UserModel(
        uid:               credential.user!.uid,
        firstName:         firstName,
        lastName:          lastName,
        email:             email,
        course:            course,
        bio:               '',
        rating:            0.0,
        sessionsCompleted: 0,
        memberSince:       DateTime.now(),
        showFullName:      true,
        showCourse:        true,
        showPhoto:         true,
      );

      // Save to Firestore users collection
      await _db
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toMap());

      return user;

    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // ── Handle Firebase error codes ───────────────────────────────────────────
  String _handleAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'Something went wrong. Please try again';
    }
  }
}