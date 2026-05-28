import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';
import '../models/block_model.dart';

class SafetyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Report a user ──────────────────────────────────────────────────────────
  // 1. Create report document in reports collection
  // 2. Set status to 'pending' for moderation review
  // 3. Store all evidence URLs
  // 4. Send notification that report was submitted
  Future<void> reportUser({
    required String reporterId,
    required String reporteeId,
    required String reason,
    required String description,
    String? requestId,
    List<String> evidence = const [],
  }) async {
    try {
      print('🚩 [SafetyService] Starting report for user: $reporteeId');

      final now = DateTime.now();
      final reportId = _db.collection('reports').doc().id;

      final report = ReportModel(
        id: reportId,
        reporterId: reporterId,
        reporteeId: reporteeId,
        reason: reason,
        description: description,
        requestId: requestId,
        evidence: evidence,
        status: 'pending',
        createdAt: now,
        updatedAt: now,
      );

      await _db.collection('reports').doc(reportId).set(report.toMap());

      print('✅ [SafetyService] Report created: $reportId');
      print('   Reason: $reason');
      print('   Status: pending');

      // Optional: Send notification to reportee (if enabled in privacy settings)
      // await _notificationService.sendNotification(
      //   reporteeId,
      //   'user_reported',
      //   'User safety report',
      //   'You have been reported. Our team will review this.',
      //   reporteeId,
      // );
    } catch (e) {
      print('❌ [SafetyService] Failed to report user: $e');
      throw Exception('Failed to report user: $e');
    }
  }

  // ── Block a user ───────────────────────────────────────────────────────────
  // 1. Create block document in blocks collection
  // 2. Block is bidirectional (affects both users' interactions)
  // 3. Check if already blocked before creating
  Future<void> blockUser({
    required String blockerId,
    required String blockedUserId,
    String? reason,
  }) async {
    try {
      print('🚫 [SafetyService] Starting block for user: $blockedUserId');

      // Check if already blocked
      final existing =
          await _db
              .collection('blocks')
              .where('blockerId', isEqualTo: blockerId)
              .where('blockedUserId', isEqualTo: blockedUserId)
              .get();

      if (existing.docs.isNotEmpty) {
        print('⚠️ [SafetyService] User already blocked');
        return;
      }

      final blockId = _db.collection('blocks').doc().id;
      final now = DateTime.now();

      final block = BlockModel(
        id: blockId,
        blockerId: blockerId,
        blockedUserId: blockedUserId,
        reason: reason,
        createdAt: now,
      );

      await _db.collection('blocks').doc(blockId).set(block.toMap());

      print('✅ [SafetyService] User blocked: $blockedUserId');
    } catch (e) {
      print('❌ [SafetyService] Failed to block user: $e');
      throw Exception('Failed to block user: $e');
    }
  }

  // ── Unblock a user ─────────────────────────────────────────────────────────
  Future<void> unblockUser({
    required String blockerId,
    required String blockedUserId,
  }) async {
    try {
      print('🔓 [SafetyService] Unblocking user: $blockedUserId by $blockerId');

      final existing =
          await _db
              .collection('blocks')
              .where('blockerId', isEqualTo: blockerId)
              .where('blockedUserId', isEqualTo: blockedUserId)
              .get();

      if (existing.docs.isNotEmpty) {
        await _db.collection('blocks').doc(existing.docs.first.id).delete();
        print('✅ [SafetyService] User unblocked');
      }
    } catch (e) {
      print('❌ [SafetyService] Failed to unblock user: $e');
      throw Exception('Failed to unblock user: $e');
    }
  }

  // ── Check if user is blocked ───────────────────────────────────────────────
  // Returns true if blockedUserId is blocked by blockerId
  Future<bool> isUserBlocked({
    required String blockerId,
    required String blockedUserId,
  }) async {
    try {
      final result =
          await _db
              .collection('blocks')
              .where('blockerId', isEqualTo: blockerId)
              .where('blockedUserId', isEqualTo: blockedUserId)
              .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      print('⚠️ [SafetyService] Error checking block status: $e');
      return false;
    }
  }

  // ── Get all blocked users for a user ───────────────────────────────────────
  // Returns list of user IDs that the user has blocked
  Future<List<String>> getBlockedUsers(String userId) async {
    try {
      final blocks =
          await _db
              .collection('blocks')
              .where('blockerId', isEqualTo: userId)
              .get();

      return blocks.docs.map((doc) => doc['blockedUserId'] as String).toList();
    } catch (e) {
      print('⚠️ [SafetyService] Error getting blocked users: $e');
      return [];
    }
  }

  // ── Get all users who blocked this user ────────────────────────────────────
  // Returns list of user IDs who have blocked this user
  Future<List<String>> getUserBlockers(String userId) async {
    try {
      final blocks =
          await _db
              .collection('blocks')
              .where('blockedUserId', isEqualTo: userId)
              .get();

      return blocks.docs.map((doc) => doc['blockerId'] as String).toList();
    } catch (e) {
      print('⚠️ [SafetyService] Error getting user blockers: $e');
      return [];
    }
  }

  // ── Get reports for moderation ─────────────────────────────────────────────
  // Query reports where status is 'pending' (for admin dashboard)
  Future<List<ReportModel>> getPendingReports() async {
    try {
      final reports =
          await _db
              .collection('reports')
              .where('status', isEqualTo: 'pending')
              .orderBy('createdAt', descending: true)
              .get();

      return reports.docs
          .map((doc) => ReportModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('⚠️ [SafetyService] Error getting pending reports: $e');
      return [];
    }
  }

  // ── Get reports about a specific user ──────────────────────────────────────
  Future<List<ReportModel>> getReportsAbout(String reporteeId) async {
    try {
      final reports =
          await _db
              .collection('reports')
              .where('reporteeId', isEqualTo: reporteeId)
              .where('status', isEqualTo: 'pending')
              .orderBy('createdAt', descending: true)
              .get();

      return reports.docs
          .map((doc) => ReportModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('⚠️ [SafetyService] Error getting reports about user: $e');
      return [];
    }
  }

  // ── Get reports by a specific user ─────────────────────────────────────────
  Future<List<ReportModel>> getReportsByUser(String reporterId) async {
    try {
      final reports =
          await _db
              .collection('reports')
              .where('reporterId', isEqualTo: reporterId)
              .orderBy('createdAt', descending: true)
              .get();

      return reports.docs
          .map((doc) => ReportModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('⚠️ [SafetyService] Error getting reports by user: $e');
      return [];
    }
  }

  // ── Update report status (for admin) ───────────────────────────────────────
  Future<void> updateReportStatus(String reportId, String newStatus) async {
    try {
      await _db.collection('reports').doc(reportId).update({
        'status': newStatus,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('✅ [SafetyService] Report status updated to: $newStatus');
    } catch (e) {
      print('❌ [SafetyService] Failed to update report status: $e');
      throw Exception('Failed to update report status: $e');
    }
  }

  // ── Check if two users can interact ────────────────────────────────────────
  // Returns true if neither user has blocked the other
  Future<bool> canUsersInteract(String userId1, String userId2) async {
    try {
      final blocked1 = await isUserBlocked(
        blockerId: userId1,
        blockedUserId: userId2,
      );
      final blocked2 = await isUserBlocked(
        blockerId: userId2,
        blockedUserId: userId1,
      );

      return !blocked1 && !blocked2;
    } catch (e) {
      print('⚠️ [SafetyService] Error checking interaction: $e');
      return false;
    }
  }
}
