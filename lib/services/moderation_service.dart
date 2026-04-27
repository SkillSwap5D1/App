import 'package:cloud_firestore/cloud_firestore.dart';
import './user_service.dart';

class ModerationService {
  static final ModerationService _instance = ModerationService._internal();

  factory ModerationService() {
    return _instance;
  }

  ModerationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Block another user
  // 1. Add targetUserId to blockedUserIds array on currentUser's document
  // 2. This is checked in ChatService.sendMessage() to prevent messages
  Future<void> blockUser(String currentUserId, String targetUserId) async {
    try {
      // Add targetUserId to blockedUserIds array on currentUser's document
      await _firestore.collection('users').doc(currentUserId).update({
        'blockedUserIds': FieldValue.arrayUnion([targetUserId]),
      });
    } catch (e) {
      print('Error blocking user: $e');
      rethrow;
    }
  }

  // Unblock a user
  // Remove targetUserId from blockedUserIds array
  Future<void> unblockUser(String currentUserId, String targetUserId) async {
    try {
      // Remove targetUserId from blockedUserIds array
      await _firestore.collection('users').doc(currentUserId).update({
        'blockedUserIds': FieldValue.arrayRemove([targetUserId]),
      });
    } catch (e) {
      print('Error unblocking user: $e');
      rethrow;
    }
  }

  // Check if a user is blocked (called before displaying chat)
  // Read currentUser document
  // Return true if targetUserId is in blockedUserIds array
  Future<bool> isBlocked(String currentUserId, String targetUserId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(currentUserId).get();
      if (userDoc.exists) {
        final blockedUserIds = List<String>.from(userDoc['blockedUserIds'] ?? []);
        return blockedUserIds.contains(targetUserId);
      }
      return false;
    } catch (e) {
      print('Error checking blocked status: $e');
      return false;
    }
  }

  // Submit a report against another user
  // Write document to reports collection
  // Set status = 'pending'
  Future<void> reportUser(String reporterId, String reportedUserId,
      String category, String description) async {
    try {
      // Write document to reports collection
      // Set status = 'pending'
      await _firestore.collection('reports').add({
        'reporterId': reporterId,
        'reportedUserId': reportedUserId,
        'category': category,
        'description': description,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error submitting report: $e');
      rethrow;
    }
  }

  // Retrieve pending reports for moderation review
  Future<List<Map<String, dynamic>>> getPendingReports() async {
    try {
      final snapshot =
          await _firestore.collection('reports').where('status', isEqualTo: 'pending').get();
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      print('Error fetching pending reports: $e');
      return [];
    }
  }
}
