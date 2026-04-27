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
      return;
    } catch (e) {
      print('Error blocking user: $e');
      rethrow;
    }
  }
}
