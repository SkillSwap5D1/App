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
  }) : _auth = auth ?? FirebaseAuth.instance,
       _db = db ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  // ── Current user ──────────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  String _normalizePassword(String password) {
    return password.trim();
  }

  String handleAuthError(String errorCode) {
    if (errorCode.contains('invalid-credential') ||
        errorCode.contains('invalid-login-credentials') ||
        errorCode.contains('invalid-email') ||
        errorCode.contains('wrong-password')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (errorCode.contains('user-not-found')) {
      return 'No user found for that email';
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
    print('🔵 _waitForUserDocument() looking for UID: $uid');

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final doc = await _db.collection('users').doc(uid).get();
        if (doc.exists) {
          print('✅ Found user document for $uid on attempt ${attempt + 1}');
          return UserModel.fromMap(doc.data()!);
        } else {
          print(
            '⚠️ User document not found for $uid on attempt ${attempt + 1}/$maxAttempts',
          );
        }
      } catch (e) {
        print('❌ Error fetching user document attempt ${attempt + 1}: $e');
        if (attempt == maxAttempts - 1) {
          throw Exception('Failed to load user profile: $e');
        }
      }

      await Future.delayed(delay);
    }

    print(
      '❌ _waitForUserDocument() timed out: user document not found for $uid after ${maxAttempts * 500}ms',
    );
    return null;
  }

  Future<void> setUserOnlineStatus(String uid, bool isOnline) async {
    try {
      await _db.collection('users').doc(uid).set({
        'isOnline': isOnline,
        'lastSeen': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update online status: $e');
    }
  }

  // ── Auth state stream — listens to login/logout ───────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Sign In ───────────────────────────────────────────────────────────────
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final normalizedPassword = _normalizePassword(password);
      print('🔵 AuthService.signIn() starting');
      print('   Raw email: "$email" (${email.length} chars)');
      print(
        '   Normalized email: "$normalizedEmail" (${normalizedEmail.length} chars)',
      );
      print('   Raw password: "$password" (${password.length} chars)');
      print(
        '   Normalized password: "$normalizedPassword" (${normalizedPassword.length} chars)',
      );
      print(
        '   Password chars: ${normalizedPassword.split('').map((c) => '$c(${c.codeUnitAt(0)})').join(', ')}',
      );

      // Validate UoP email
      if (!normalizedEmail.endsWith('@myport.ac.uk')) {
        throw Exception('Please use your University of Portsmouth email');
      }

      // Sign in with Firebase Auth
      print('🔵 Attempting Firebase Auth.signInWithEmailAndPassword()...');
      print('   Sending email: "$normalizedEmail"');
      print('   Sending password: "$normalizedPassword"');
      final credential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: normalizedPassword,
      );
      print('🔵 Firebase Auth succeeded immediately');
      final uid = credential.user!.uid;
      print('✅ Firebase Auth successful! UID: $uid');
      print('   Account email: ${credential.user!.email}');
      print('   Account disabled?: ${credential.user!.emailVerified}');

      // Force refresh to get custom claims from Cloud Function
      await credential.user?.getIdToken(true);

      // Small delay to ensure custom claims are propagated
      await Future.delayed(const Duration(milliseconds: 500));

      print('🔵 Waiting for user document in Firestore...');
      var userModel = await _waitForUserDocument(uid);

      // If document doesn't exist, create it with basic info
      if (userModel == null) {
        print('⚠️ User document not found, creating default profile...');
        try {
          final user = credential.user!;
          final nameParts = (user.displayName ?? '').split(' ');
          final firstName =
              nameParts.isNotEmpty && nameParts[0].isNotEmpty
                  ? nameParts[0]
                  : email.split('@').first.split('.').first;
          final lastName =
              nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

          userModel = UserModel(
            uid: uid,
            firstName: firstName,
            lastName: lastName,
            email: normalizedEmail,
            course: 'Not specified',
            bio: '',
            rating: 0.0,
            sessionsCompleted: 0,
            memberSince: DateTime.now(),
            showFullName: true,
            showCourse: false,
            showPhoto: true,
            isOnline: true,
          );

          // Save to Firestore
          print('🔵 Attempting to save default user document to Firestore...');
          await _db.collection('users').doc(uid).set(userModel.toMap());
          print('✅ Created default user document for $uid');
        } catch (e) {
          print('❌ Error creating default user document: $e');
          // Even if document creation fails, we have a userModel in memory, so return it
          print(
            '⚠️ Returning in-memory userModel despite Firestore write failure',
          );
        }
      }

      print(
        '✅ AuthService.signIn() returning user: ${userModel?.uid ?? "null"}',
      );
      return userModel?.copyWith(isOnline: true) ?? userModel;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException caught!');
      print('   Code: ${e.code}');
      print('   Message: ${e.message}');
      print('   Plugin: ${e.plugin}');
      throw Exception('${e.code}: ${e.message ?? 'Auth failed'}');
    } catch (e) {
      print('❌ Unexpected error during signIn: $e');
      print('   Type: ${e.runtimeType}');
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
      final normalizedPassword = _normalizePassword(password);

      // Validate UoP email
      if (!normalizedEmail.endsWith('@myport.ac.uk')) {
        throw Exception('Please use your University of Portsmouth email');
      }

      if (normalizedPassword.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: normalizedPassword,
      );

      await credential.user?.getIdToken(true);

      // Small delay to ensure custom claims are propagated
      await Future.delayed(const Duration(milliseconds: 500));

      // Create user model
      final user = UserModel(
        uid: credential.user!.uid,
        firstName: firstName,
        lastName: lastName,
        email: normalizedEmail,
        course: course,
        bio: '',
        rating: 0.0,
        sessionsCompleted: 0,
        memberSince: DateTime.now(),
        showFullName: true,
        showCourse: true,
        showPhoto: true,
        isOnline: true,
      );

      await _db.collection('users').doc(credential.user!.uid).set(user.toMap());

      // Give Firestore a moment to settle before any downstream listeners read.
      await Future.delayed(const Duration(milliseconds: 500));

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
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await setUserOnlineStatus(uid, false);
      }
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
        throw Exception(
          'Please use your University of Portsmouth email (@myport.ac.uk)',
        );
      }

      // Get Google authentication credentials
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

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

      await firebaseUser.getIdToken(true);

      // Small delay to ensure custom claims are propagated
      await Future.delayed(const Duration(milliseconds: 500));

      final existingUser = await _waitForUserDocument(firebaseUser.uid);
      if (existingUser != null) {
        return existingUser.copyWith(isOnline: true);
      }

      // If the Cloud Function hasn't created the user doc yet, return a local
      // model so the caller can continue while the auth state listener retries.
      final nameParts = (firebaseUser.displayName ?? '').split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : 'User';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

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
