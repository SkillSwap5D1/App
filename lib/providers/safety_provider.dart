import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/safety_service.dart';

class SafetyProvider extends ChangeNotifier {
  final SafetyService _safetyService = SafetyService();

  List<String> _blockedUsers = [];
  List<String> _userBlockers = [];
  List<ReportModel> _userReports = [];
  bool _isLoading = false;
  String? _error;

  List<String> get blockedUsers => _blockedUsers;
  List<String> get userBlockers => _userBlockers;
  List<ReportModel> get userReports => _userReports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Load blocked users list ────────────────────────────────────────────────
  Future<void> loadBlockedUsers(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _blockedUsers = await _safetyService.getBlockedUsers(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load blocked users: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Load users who blocked current user ─────────────────────────────────────
  Future<void> loadUserBlockers(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userBlockers = await _safetyService.getUserBlockers(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load blockers: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Load user's own reports ────────────────────────────────────────────────
  Future<void> loadUserReports(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userReports = await _safetyService.getReportsByUser(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load reports: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Report a user ──────────────────────────────────────────────────────────
  Future<void> reportUser({
    required String reporterId,
    required String reporteeId,
    required String reason,
    required String description,
    String? requestId,
    List<String> evidence = const [],
  }) async {
    try {
      await _safetyService.reportUser(
        reporterId: reporterId,
        reporteeId: reporteeId,
        reason: reason,
        description: description,
        requestId: requestId,
        evidence: evidence,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Failed to report user: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ── Block a user ───────────────────────────────────────────────────────────
  Future<void> blockUser({
    required String blockerId,
    required String blockedUserId,
    String? reason,
  }) async {
    try {
      await _safetyService.blockUser(
        blockerId: blockerId,
        blockedUserId: blockedUserId,
        reason: reason,
      );
      _blockedUsers.add(blockedUserId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to block user: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ── Unblock a user ─────────────────────────────────────────────────────────
  Future<void> unblockUser({
    required String blockerId,
    required String blockedUserId,
  }) async {
    try {
      await _safetyService.unblockUser(
        blockerId: blockerId,
        blockedUserId: blockedUserId,
      );
      _blockedUsers.remove(blockedUserId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to unblock user: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ── Check if user is blocked ───────────────────────────────────────────────
  Future<bool> isUserBlocked({
    required String blockerId,
    required String blockedUserId,
  }) async {
    try {
      return await _safetyService.isUserBlocked(
        blockerId: blockerId,
        blockedUserId: blockedUserId,
      );
    } catch (e) {
      _error = 'Failed to check block status: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Check if two users can interact ────────────────────────────────────────
  Future<bool> canUsersInteract(String userId1, String userId2) async {
    try {
      return await _safetyService.canUsersInteract(userId1, userId2);
    } catch (e) {
      _error = 'Failed to check interaction: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
