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

  // ── Stream subscription ────────────────────────────────────────────────────
  StreamSubscription? _authStateSubscription;

  // ── Constructor - initialize auth state listener ──────────────────────────
  AuthProvider() {
    _authStateSubscription = _authService.authStateChanges.listen((user) async {
      if (user != null) {
        currentUser = _buildProvisionalUser(user);
        notifyListeners();
        _fetchUser(user.uid);
      } else {
        currentUser = null;
        notifyListeners();
      }
    });
  }

  UserModel _buildProvisionalUser(dynamic user) {
    final email = (user.email as String?)?.trim().toLowerCase() ?? '';
    final displayName = (user.displayName as String?)?.trim() ?? '';
    final nameParts = displayName.isNotEmpty ? displayName.split(' ') : <String>[];
    final firstName = nameParts.isNotEmpty && nameParts.first.isNotEmpty
        ? nameParts.first
        : (email.isNotEmpty ? email.split('@').first.split('.').first : 'User');
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
    );
  }

  // ── Private: fetch user from Firestore ────────────────────────────────────
  Future<void> _fetchUser(String uid) async {
    try {
      const maxAttempts = 10;
      const delay = Duration(milliseconds: 500);

      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        final user = await _userService.getUser(uid);
        if (user != null) {
          currentUser = user;
          notifyListeners();
          return;
        }

        await Future.delayed(delay);
      }

      print('⚠️ User profile not available yet for $uid');
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  // ── Sign In ───────────────────────────────────────────────────────────────
  Future<void> signIn(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.signIn(email, password);
      // Verify custom claims after authentication
      final verified = await _verifyUniversityClaims();
      if (!verified) {
        print('⚠️ University claims not ready yet; continuing with provisional auth state');
      }
      // User fetch happens automatically via authStateChanges listener
    } catch (e) {
      errorMessage = _handleAuthError(e.toString());
    } finally {
      isLoading = false;
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
        print('❗ University claims not yet present (attempt ${attempt + 1}), retrying...');
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
      await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        course: course,
      );
      // User fetch happens automatically via authStateChanges listener
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
    } catch (e) {
      errorMessage = e.toString();
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
      // Verify custom claims after authentication
      final verified = await _verifyUniversityClaims();
      if (!verified) {
        print('⚠️ Google claims not ready yet; continuing with provisional auth state');
      }
      // User fetch happens automatically via authStateChanges listener
    } catch (e) {
      errorMessage = _handleAuthError(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Handle auth errors ─────────────────────────────────────────────────────
  String _handleAuthError(String errorCode) {
    if (errorCode.contains('INVALID_LOGIN_CREDENTIALS')) {
      return 'Invalid email or password';
    }
    if (errorCode.contains('EMAIL_EXISTS')) {
      return 'This email is already registered';
    }
    if (errorCode.contains('WEAK_PASSWORD')) {
      return 'Password is too weak';
    }
    if (errorCode.contains('network')) {
      return 'Network error. Please check your connection';
    }
    if (errorCode.contains('permission-denied')) {
      return 'Your account is still being set up. Please wait a few seconds and try again.';
    }
    if (errorCode.contains('Failed to load user profile')) {
      return 'Your profile is still being created. Please try again in a moment.';
    }
    if (errorCode.contains('University of Portsmouth')) {
      return 'Please use your University of Portsmouth email (@myport.ac.uk)';
    }
    if (errorCode.contains('@myport.ac.uk')) {
      return 'Please use your @myport.ac.uk email';
    }
    if (errorCode.contains('sign-in cancelled')) {
      return 'Google sign-in was cancelled';
    }
    if (errorCode.contains('Sign in with Google')) {
      return 'Google sign-in failed. Please check your credentials';
    }
    print('⚠️ Unhandled auth error: $errorCode');
    return errorCode.replaceFirst('Exception: ', '');
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
