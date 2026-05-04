import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';
import 'chat_service.dart';
import 'notification_service.dart';

class RequestService {
  final FirebaseFirestore _db;
  final ChatService _chatService;
  final NotificationService _notificationService;

  RequestService({
    FirebaseFirestore? db,
    ChatService? chatService,
    NotificationService? notificationService,
  })  : _db = db ?? FirebaseFirestore.instance,
        _chatService = chatService ?? ChatService(),
        _notificationService = notificationService ?? NotificationService();

  // ── Send a new lesson request ─────────────────────────────────────────────
  Future<String> sendRequest(RequestModel request) async {
    try {
      // 1. Check no pending request already exists
      final existing = await _db
          .collection('requests')
          .where('fromUserId', isEqualTo: request.fromUserId)
          .where('listingId', isEqualTo: request.listingId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception(
          'You already have a pending request for this listing'
        );
      }

      // 2. Write document to requests collection
      final docRef = _db.collection('requests').doc();
      final newRequest = request.copyWith(id: docRef.id);
      await docRef.set(newRequest.toMap());

      // 3. Create or get conversation between the two users
      await _chatService.getOrCreateConversation(
        request.fromUserId,
        request.toUserId,
      );

      // 4. Send notification to provider
      await _notificationService.sendNotification(
        request.toUserId,
        'request',
        'New lesson request from ${request.fromUserName}',
        'wants to learn ${request.skillName}',
        request.listingId,
      );

      // 5. Return the new request ID
      return docRef.id;

    } catch (e) {
      throw Exception('Failed to send request: $e');
    }
  }

  // ── Get incoming requests — real time stream ───────────────────────────────
  Stream<List<RequestModel>> getIncomingRequests(String userId) {
    return _db
        .collection('requests')
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestModel.fromMap(doc.data()))
            .toList());
  }

  // ── Get outgoing requests — real time stream ──────────────────────────────
  Stream<List<RequestModel>> getOutgoingRequests(String userId) {
    return _db
        .collection('requests')
        .where('fromUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestModel.fromMap(doc.data()))
            .toList());
  }

  // ── Accept a request ──────────────────────────────────────────────────────
  Future<void> acceptRequest(
    String requestId,
    Map<String, String> confirmedSlot,
    String requesterName,
    String skillName,
    String requesterId,
  ) async {
    try {
      // 1. Update status and confirmed slot
      await _db
          .collection('requests')
          .doc(requestId)
          .update({
            'status':        'accepted',
            'confirmedSlot': confirmedSlot,
            'updatedAt':     Timestamp.fromDate(DateTime.now()),
          });

      // 2. Notify the requester
      await _notificationService.sendNotification(
        requesterId,
        'accepted',
        'Your request was accepted!',
        '$skillName has been confirmed',
        requestId,
      );

    } catch (e) {
      throw Exception('Failed to accept request: $e');
    }
  }

  // ── Decline a request ─────────────────────────────────────────────────────
  Future<void> declineRequest(
    String requestId,
    String requesterId,
    String skillName,
  ) async {
    try {
      // 1. Update status
      await _db
          .collection('requests')
          .doc(requestId)
          .update({
            'status':    'declined',
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });

      // 2. Notify the requester
      await _notificationService.sendNotification(
        requesterId,
        'declined',
        'Your request was declined',
        '$skillName could not be confirmed',
        requestId,
      );

    } catch (e) {
      throw Exception('Failed to decline request: $e');
    }
  }

  // ── Counter a request ─────────────────────────────────────────────────────
  Future<void> counterRequest(
    String requestId,
    List<Map<String, dynamic>> newSlots,
    String note,
    String requesterId,
    String skillName,
  ) async {
    try {
      // 1. Update status and proposed slots
      await _db
          .collection('requests')
          .doc(requestId)
          .update({
            'status':        'countered',
            'proposedTimes': newSlots,
            'counterNote':   note,
            'updatedAt':     Timestamp.fromDate(DateTime.now()),
          });

      // 2. Notify the requester
      await _notificationService.sendNotification(
        requesterId,
        'countered',
        'New time slots proposed',
        '$skillName — check the new proposed times',
        requestId,
      );

    } catch (e) {
      throw Exception('Failed to counter request: $e');
    }
  }

  // ── Check sessions due for review ─────────────────────────────────────────
  Future<void> checkSessionsDue(String userId) async {
    try {
      final now = DateTime.now();

      // Get all accepted requests for this user
      final snapshot = await _db
          .collection('requests')
          .where('status', isEqualTo: 'accepted')
          .where('reviewDue', isEqualTo: false)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();

        // Check if either user is this user
        final isInvolved =
            data['fromUserId'] == userId ||
            data['toUserId'] == userId;

        if (!isInvolved) continue;

        // Check if session end time has passed
        final confirmedSlot = data['confirmedSlot'];
        if (confirmedSlot == null) continue;

        final endTimeStr = confirmedSlot['endTime'] as String?;
        if (endTimeStr == null) continue;

        final endTime = DateTime.tryParse(endTimeStr);
        if (endTime == null) continue;

        if (now.isAfter(endTime)) {
          // Mark review as due
          await doc.reference.update({'reviewDue': true});

          // Send notification to both users
          await _notificationService.sendNotification(
            data['fromUserId'],
            'reminder',
            'How was your session?',
            'Leave a review for ${data['skillName']}',
            doc.id,
          );

          await _notificationService.sendNotification(
            data['toUserId'],
            'reminder',
            'How was your session?',
            'Leave a review for ${data['skillName']}',
            doc.id,
          );
        }
      }

    } catch (e) {
      throw Exception('Failed to check sessions due: $e');
    }
  }
}