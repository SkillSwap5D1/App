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
}
