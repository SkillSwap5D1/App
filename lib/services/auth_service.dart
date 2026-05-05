import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  // ── Firebase instances ────────────────────────────────────────────────────
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final GoogleSignIn _googleSignIn;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  // ── Current user ──────────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  String handleAuthError(String errorCode) {
    if (errorCode.contains('user-not-found')) {
      return 'No user found for that email';
    }
    if (errorCode.contains('wrong-password')) {
      return 'Incorrect password';
    }
    if (errorCode.contains('email-already-in-use')) {
      return 'This email is already registered';
    }
    if (errorCode.contains('weak-password')) {
      return 'Password must be at least 6 characters';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<UserModel?> _waitForUserDocument(String uid) async {
    const maxAttempts = 10;
    const delay = Duration(milliseconds: 500);

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final doc = await _db.collection('users').doc(uid).get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data()!);
        }
      } catch (e) {
        if (attempt == maxAttempts - 1) {
          throw Exception('Failed to load user profile: $e');
        }
      }

      await Future.delayed(delay);
    }

    return null;
  }

  // ── Auth state stream — listens to login/logout ───────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Sign In ───────────────────────────────────────────────────────────────
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final normalizedEmail = _normalizeEmail(email);

      // Validate UoP email
      if (!normalizedEmail.endsWith('@myport.ac.uk')) {
        throw Exception('Please use your University of Portsmouth email');
      }

      // Sign in with Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      return await _waitForUserDocument(credential.user!.uid);

    } on FirebaseAuthException catch (e) {
      throw Exception('${e.code}: ${e.message ?? 'Auth failed'}');
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
      final normalizedEmail = _normalizeEmail(email);

      // Validate UoP email
      if (!normalizedEmail.endsWith('@myport.ac.uk')) {
        throw Exception('Please use your University of Portsmouth email');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      // Create user model
      final user = UserModel(
        uid:               credential.user!.uid,
        firstName:         firstName,
        lastName:          lastName,
        email:             normalizedEmail,
        course:            course,
        bio:               '',
        rating:            0.0,
        sessionsCompleted: 0,
        memberSince:       DateTime.now(),
        showFullName:      true,
        showCourse:        true,
        showPhoto:         true,
      );

      await _db.collection('users').doc(credential.user!.uid).set(user.toMap());

      return user;

    } on FirebaseAuthException catch (e) {
      throw Exception('${e.code}: ${e.message ?? 'Auth failed'}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // ── Google Sign In ────────────────────────────────────────────────────────
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }

      // Verify university email domain
      if (!googleUser.email.endsWith('@myport.ac.uk')) {
        await _googleSignIn.signOut();
        throw Exception('Please use your University of Portsmouth email (@myport.ac.uk)');
      }

      // Get Google authentication credentials
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Firebase sign-in failed');
      }

      final existingUser = await _waitForUserDocument(firebaseUser.uid);
      if (existingUser != null) {
        return existingUser;
      }

      // If the Cloud Function hasn't created the user doc yet, return a local
      // model so the caller can continue while the auth state listener retries.
      final nameParts = (firebaseUser.displayName ?? '').split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : 'User';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      return UserModel(
        uid: firebaseUser.uid,
        firstName: firstName,
        lastName: lastName,
        email: firebaseUser.email ?? googleUser.email,
        course: 'Not specified',
        bio: '',
        rating: 0.0,
        sessionsCompleted: 0,
        memberSince: DateTime.now(),
        showFullName: true,
        showCourse: false,
        showPhoto: true,
      );

    } on FirebaseAuthException catch (e) {
      throw Exception('${e.code}: ${e.message ?? 'Auth failed'}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

}