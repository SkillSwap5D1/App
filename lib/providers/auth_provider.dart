import 'package:flutter/material.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  // ── State ─────────────────────────────────────────────────────────────────
  UserModel? currentUser;
  bool isLoading = false;
  String? errorMessage;
  bool _authStateListenerFired = false;

  // ── Stream subscription ────────────────────────────────────────────────────
  StreamSubscription? _authStateSubscription;

  // ── Constructor - initialize auth state listener ──────────────────────────
  AuthProvider() {
    _setupAuthStateListener();
  }

  void _setupAuthStateListener() {
    // Cancel existing subscription if any
    _authStateSubscription?.cancel();
    _authStateListenerFired = false;

    _authStateSubscription = _authService.authStateChanges.listen(
      (user) async {
        try {
          print(
            '🔵 authStateChanges listener fired! User: ${user?.uid ?? "null"}',
          );
          _authStateListenerFired = true;

          if (user != null) {
            // Check custom claims
            try {
              final idToken = await user.getIdTokenResult();
              final isUniversityUser =
                  idToken.claims?['isUniversityUser'] ?? false;
              final emailDomain = idToken.claims?['emailDomain'] ?? 'unknown';
              print(
                '🔵 Custom claims: isUniversityUser=$isUniversityUser, emailDomain=$emailDomain',
              );
            } catch (e) {
              print('⚠️ Could not fetch custom claims: $e');
            }

            currentUser = _buildProvisionalUser(user);
            print('✅ Set provisional currentUser from Firebase: ${user.uid}');
            notifyListeners();
            await _authService.setUserOnlineStatus(user.uid, true);
            print('🔵 Called notifyListeners() from auth state listener');
            print('🔵 Calling _fetchUser to get full profile...');
            _fetchUser(user.uid);
          } else {
            currentUser = null;
            print('🔵 User logged out, currentUser set to null');
            notifyListeners();
            print(
              '🔵 Called notifyListeners() from auth state listener (logout)',
            );
          }
        } catch (e) {
          print('❌ ERROR in authStateChanges listener callback: $e');
          print('   Stack trace: ${StackTrace.current}');
        }
      },
      onError: (error) {
        print('❌ ERROR in authStateChanges stream: $error');
      },
    );
  }

  UserModel _buildProvisionalUser(dynamic user) {
    final email = (user.email as String?)?.trim().toLowerCase() ?? '';
    final displayName = (user.displayName as String?)?.trim() ?? '';
    final nameParts =
        displayName.isNotEmpty ? displayName.split(' ') : <String>[];
    final firstName =
        nameParts.isNotEmpty && nameParts.first.isNotEmpty
            ? nameParts.first
            : (email.isNotEmpty
                ? email.split('@').first.split('.').first
                : 'User');
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return UserModel(
      uid: user.uid as String,
      firstName: firstName,
      lastName: lastName,
      email: email,
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
  }

  // ── Private: fetch user from Firestore ────────────────────────────────────
  Future<void> _fetchUser(String uid) async {
    try {
      print('🔵 _fetchUser() called for $uid');
      const maxAttempts = 10;
      const delay = Duration(milliseconds: 500);

      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        final user = await _userService.getUser(uid);
        if (user != null) {
          currentUser = user;
          print(
            '✅ _fetchUser() got full profile for $uid on attempt ${attempt + 1}',
          );
          notifyListeners();
          return;
        }
        print(
          '⚠️ _fetchUser() attempt ${attempt + 1}/$maxAttempts: user not found yet',
        );

        await Future.delayed(delay);
      }

      print(
        '⚠️ User profile not available yet for $uid after ${maxAttempts * 500}ms',
      );
    } catch (e) {
      print('❌ Error fetching user: $e');
    }
  }

  // ── Sign In ───────────────────────────────────────────────────────────────
  Future<void> signIn(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    print('🔵 AuthProvider.signIn() started for $email');

    try {
      final user = await _authService.signIn(email, password);
      print('🔵 AuthService.signIn() returned: ${user?.uid ?? "null"}');

      // Set currentUser immediately from the returned value
      if (user != null) {
        currentUser = user;
        print('✅ Set currentUser immediately: ${user.uid}');
        notifyListeners();
      } else {
        print('⚠️ AuthService.signIn() returned null');
      }

      // Verify custom claims after authentication
      print('🔵 Verifying university claims...');
      final verified = await _verifyUniversityClaims();
      if (!verified) {
        print(
          '⚠️ University claims not ready yet; continuing with provisional auth state',
        );
      }
    } catch (e) {
      print('❌ SignIn error caught: $e');
      errorMessage = _handleAuthError(e.toString());
      print('📝 Error message set to: $errorMessage');
    } finally {
      isLoading = false;
      print('🔵 AuthProvider.signIn() finished. Final state:');
      print('   currentUser: ${currentUser?.uid ?? "null"}');
      print('   errorMessage: $errorMessage');
      notifyListeners();
    }
  }

  // ── Verify University Claims ──────────────────────────────────────────────
  Future<bool> _verifyUniversityClaims() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return false;

      // Sometimes custom claims take a short moment to propagate after user creation.
      // Retry a few times before giving up to avoid false negatives.
      const int maxRetries = 5;
      const Duration retryDelay = Duration(seconds: 1);

      for (int attempt = 0; attempt < maxRetries; attempt++) {
        final tokenResult = await user.getIdTokenResult(true);
        final claims = tokenResult.claims;

        final isUniversityUser = claims?['isUniversityUser'] == true;
        final emailDomain = claims?['emailDomain'] as String?;

        if (isUniversityUser && emailDomain == 'myport.ac.uk') {
          print('✓ University claims verified (attempt ${attempt + 1})');
          return true;
        }

        // If not verified yet, wait and retry
        print(
          '❗ University claims not yet present (attempt ${attempt + 1}), retrying...',
        );
        await Future.delayed(retryDelay);
      }

      print('❌ Custom claims verification failed after retries');
      return false;
    } catch (e) {
      print('Error verifying claims: $e');
      return false;
    }
  }

  // ── Get User Custom Claims ────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getUserCustomClaims() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return null;

      final tokenResult = await user.getIdTokenResult();
      return tokenResult.claims;
    } catch (e) {
      print('Error getting custom claims: $e');
      return null;
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String course,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        course: course,
      );
      if (user != null) {
        currentUser = user;
        errorMessage = null;

        // Wait a bit for the auth state listener to also fire
        int attempts = 0;
        while (attempts < 20) {
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
          if (_authStateListenerFired) {
            print('✅ Auth listener fired during registration');
            break;
          }
        }

        notifyListeners();
      } else {
        errorMessage = 'Failed to create account. Please try again.';
      }
    } catch (e) {
      errorMessage = _handleAuthError(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.signOut();
      currentUser = null;

      // Reset auth state listener flag for next sign-in
      _authStateListenerFired = false;

      print('✅ Sign out successful, resetting state for next sign-in');
    } catch (e) {
      errorMessage = e.toString();
      print('❌ Sign out error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Sign In with Google ───────────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();

      // Wait for the auth state listener to fire and populate currentUser
      int attempts = 0;
      const maxAttempts = 30; // 3 seconds max
      while (attempts < maxAttempts && currentUser == null) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (currentUser != null) {
        print('✅ Google sign-in successful, currentUser: ${currentUser!.uid}');
      } else {
        print('⚠️ currentUser not set after Google sign-in');
        errorMessage = 'Failed to load user profile. Please try again.';
      }

      // Verify custom claims after authentication
      final verified = await _verifyUniversityClaims();
      if (!verified) {
        print(
          '⚠️ Google claims not ready yet; continuing with provisional auth state',
        );
      }
    } catch (e) {
      errorMessage = _handleAuthError(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Handle auth errors ─────────────────────────────────────────────────────
  String _handleAuthError(String errorCode) {
    final error = errorCode.toLowerCase();

    // Invalid credentials (new Firebase error format)
    if (error.contains('invalid-credential')) {
      return 'Invalid email or password';
    }

    // Invalid credentials (old Firebase error format)
    if (error.contains('invalid_login_credentials')) {
      return 'Invalid email or password';
    }

    // User not found
    if (error.contains('user-not-found') || error.contains('user_not_found')) {
      return 'No account found with this email';
    }

    // Wrong password
    if (error.contains('wrong-password') || error.contains('wrong_password')) {
      return 'Incorrect password';
    }

    // Email already exists
    if (error.contains('email-already-in-use') ||
        error.contains('email_exists')) {
      return 'This email is already registered';
    }

    // Weak password
    if (error.contains('weak-password') || error.contains('weak_password')) {
      return 'Password must be at least 6 characters';
    }

    // Network errors
    if (error.contains('network') || error.contains('timeout')) {
      return 'Network error. Please check your connection';
    }

    // Permission denied (Firestore access issues)
    if (error.contains('permission-denied') ||
        error.contains('permission_denied')) {
      return 'Your account is still being set up. Please wait a few seconds and try again.';
    }

    // User profile loading issues
    if (error.contains('failed to load user profile')) {
      return 'Your profile is still being created. Please try again in a moment.';
    }

    // University email validation
    if (error.contains('university of portsmouth')) {
      return 'Please use your University of Portsmouth email (@myport.ac.uk)';
    }

    if (error.contains('@myport.ac.uk')) {
      return 'Please use your @myport.ac.uk email';
    }

    // Google sign-in errors
    if (error.contains('cancelled')) {
      return 'Sign-in was cancelled';
    }

    if (error.contains('google')) {
      return 'Google sign-in failed. Please try again';
    }

    // Generic fallback
    return errorCode.replaceFirst('Exception: ', '').split('\n').first;
  }

  // ── Refresh User Data ─────────────────────────────────────────────────────
  Future<void> refreshUser() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;
      await _fetchUser(user.uid);
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }

  // ── Update Privacy Settings ───────────────────────────────────────────────
  Future<void> updatePrivacySettings({
    required bool showFullName,
    required bool showCourse,
    required bool showPhoto,
  }) async {
    if (currentUser == null) return;

    try {
      final updates = <String, dynamic>{
        'showFullName': showFullName,
        'showCourse': showCourse,
        'showPhoto': showPhoto,
      };

      await _userService.updateUser(currentUser!.uid, updates);

      // Update local state
      currentUser = currentUser!.copyWith(
        showFullName: showFullName,
        showCourse: showCourse,
        showPhoto: showPhoto,
      );
      notifyListeners();
    } catch (e) {
      print('Error updating privacy settings: $e');
      rethrow;
    }
  }

  // ── Update Skills ─────────────────────────────────────────────────────────
  Future<void> updateSkills({
    required List<String> canTeach,
    required List<String> wantsToLearn,
  }) async {
    if (currentUser == null) return;

    try {
      final updates = <String, dynamic>{
        'canTeach': canTeach,
        'wantsToLearn': wantsToLearn,
      };

      await _userService.updateUser(currentUser!.uid, updates);

      // Update local state
      currentUser = currentUser!.copyWith(
        canTeach: canTeach,
        wantsToLearn: wantsToLearn,
      );
      notifyListeners();
    } catch (e) {
      print('Error updating skills: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    print('🔵 AuthProvider.dispose() called');
    _authStateSubscription?.cancel();
    _authStateSubscription = null;
    super.dispose();
  }
}
