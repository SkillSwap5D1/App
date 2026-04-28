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
        await _fetchUser(user.uid);
      } else {
        currentUser = null;
        notifyListeners();
      }
    });
  }

  // ── Private: fetch user from Firestore ────────────────────────────────────
  Future<void> _fetchUser(String uid) async {
    try {
      final user = await _userService.getUser(uid);
      currentUser = user;
      notifyListeners();
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
        await _authService.signOut();
        errorMessage = 'University verification failed. Please use your @port.ac.uk email.';
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

      // Get ID token result with custom claims
      final tokenResult = await user.getIdTokenResult();
      final claims = tokenResult.claims;
      
      final isUniversityUser = claims?['isUniversityUser'] == true;
      final emailDomain = claims?['emailDomain'] as String?;

      if (!isUniversityUser || emailDomain != 'port.ac.uk') {
        print('❌ Custom claims verification failed');
        return false;
      }

      print('✓ University claims verified');
      return true;
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
    return 'An error occurred. Please try again';
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
