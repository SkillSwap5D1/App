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
  }) : _db = db ?? FirebaseFirestore.instance,
       _chatService = chatService ?? ChatService(),
       _notificationService = notificationService ?? NotificationService();

  // ── Send a new lesson request ─────────────────────────────────────────────
  Future<String> sendRequest(RequestModel request) async {
    try {
      print('📤 [SendRequest] Starting request send');
      print('   From: ${request.fromUserId}');
      print('   To: ${request.toUserId}');
      print('   Listing: ${request.listingId}');

      // 1. Check no pending request already exists
      print('🔍 [SendRequest] Checking for existing pending requests...');
      final existing =
          await _db
              .collection('requests')
              .where('fromUserId', isEqualTo: request.fromUserId)
              .where('listingId', isEqualTo: request.listingId)
              .where('status', isEqualTo: 'pending')
              .get();

      if (existing.docs.isNotEmpty) {
        print('❌ [SendRequest] Already has pending request');
        throw Exception('You already have a pending request for this listing');
      }

      // 2. Write document to requests collection
      print('💾 [SendRequest] Writing request document to Firestore...');
      final docRef = _db.collection('requests').doc();
      final newRequest = request.copyWith(id: docRef.id);
      await docRef.set(newRequest.toMap());
      print('✅ [SendRequest] Request document created: ${newRequest.id}');

      // 3. Create or get conversation between the two users
      print('💬 [SendRequest] Creating/getting conversation...');
      await _chatService.getOrCreateConversation(
        request.fromUserId,
        request.toUserId,
      );
      print('✅ [SendRequest] Conversation handled');

      // 4. Send notification to the recipient
      print('🔔 [SendRequest] Sending notification to ${request.toUserId}...');
      try {
        await _notificationService.sendNotification(
          request.toUserId,
          'new_request',
          'New request from ${request.fromUserName}',
          'wants to learn ${request.skillName}',
          newRequest.id,
        );
        print('✅ [SendRequest] Notification sent successfully');
      } catch (notifError) {
        print(
          '⚠️ [SendRequest] Notification error (non-blocking): $notifError',
        );
      }

      print('✅ [SendRequest] Complete! Request ID: ${newRequest.id}');
      return docRef.id;
    } catch (e) {
      print('❌ [SendRequest] Failed: $e');
      throw Exception('Failed to send request: $e');
    }
  }

  // ── Get incoming requests — real time stream ───────────────────────────────
  Stream<List<RequestModel>> getIncomingRequests(String userId) {
    print('📥 [GetIncomingRequests] Setting up stream for user: $userId');
    return _db
        .collection('requests')
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          print('❌ [GetIncomingRequests] Stream ERROR (before map): $error');
          print('   Error type: ${error.runtimeType}');
          print('   Error message: ${error.toString()}');
          return [];
        })
        .map((snapshot) {
          print(
            '📥 [GetIncomingRequests] Snapshot received with ${snapshot.docs.length} docs',
          );
          final requests =
              snapshot.docs.map((doc) {
                try {
                  final request = RequestModel.fromMap(doc.data());
                  print(
                    '   - Request from ${request.fromUserName} (${request.status})',
                  );
                  return request;
                } catch (e) {
                  print('   ⚠️ Error parsing request doc: $e');
                  rethrow;
                }
              }).toList();
          print(
            '📥 [GetIncomingRequests] Returning ${requests.length} requests',
          );
          return requests;
        });
  }

  // ── Get outgoing requests — real time stream ──────────────────────────────
  Stream<List<RequestModel>> getOutgoingRequests(String userId) {
    print('📤 [GetOutgoingRequests] Setting up stream for user: $userId');
    return _db
        .collection('requests')
        .where('fromUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          print('❌ [GetOutgoingRequests] Stream ERROR (before map): $error');
          print('   Error type: ${error.runtimeType}');
          print('   Error message: ${error.toString()}');
          return [];
        })
        .map((snapshot) {
          print(
            '📤 [GetOutgoingRequests] Snapshot received with ${snapshot.docs.length} docs',
          );
          final requests =
              snapshot.docs.map((doc) {
                try {
                  final request = RequestModel.fromMap(doc.data());
                  print(
                    '   - Request to ${request.toUserName} (${request.status})',
                  );
                  return request;
                } catch (e) {
                  print('   ⚠️ Error parsing request doc: $e');
                  rethrow;
                }
              }).toList();
          print(
            '📤 [GetOutgoingRequests] Returning ${requests.length} requests',
          );
          return requests;
        });
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
      await _db.collection('requests').doc(requestId).update({
        'status': 'accepted',
        'confirmedSlot': confirmedSlot,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // 2. Send notification to requester
      await _notificationService.sendNotification(
        requesterId,
        'request_accepted',
        'Your request was accepted!',
        '$requesterName accepted your request to learn $skillName',
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
      await _db.collection('requests').doc(requestId).update({
        'status': 'declined',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // 2. Send notification to requester
      await _notificationService.sendNotification(
        requesterId,
        'request_declined',
        'Your request was declined',
        'Unfortunately, your request to learn $skillName was declined',
        requestId,
      );
    } catch (e) {
      throw Exception('Failed to decline request: $e');
    }
  }

  // ── End a request ────────────────────────────────────────────────────────
  Future<void> endRequest(String requestId, String endedByUserId) async {
    try {
      final doc = await _db.collection('requests').doc(requestId).get();
      final data = doc.data();

      if (data == null) {
        throw Exception('Request not found');
      }

      final fromUserId = data['fromUserId'] as String? ?? '';
      final toUserId = data['toUserId'] as String? ?? '';
      final skillName = data['skillName'] as String? ?? 'this request';

      final otherUserId = endedByUserId == fromUserId ? toUserId : fromUserId;

      await doc.reference.update({
        'status': 'completed',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      if (otherUserId.isNotEmpty) {
        await _notificationService.sendNotification(
          otherUserId,
          'request_completed',
          'Request ended',
          'The request for $skillName has been ended',
          requestId,
        );
      }
    } catch (e) {
      throw Exception('Failed to end request: $e');
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
      await _db.collection('requests').doc(requestId).update({
        'status': 'countered',
        'proposedTimes': newSlots,
        'counterNote': note,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // 2. Send notification to requester about the counter offer
      await _notificationService.sendNotification(
        requesterId,
        'countered',
        'Counter offer received',
        'A counter offer was made for $skillName. Check new availability.',
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
      final snapshot =
          await _db
              .collection('requests')
              .where('status', isEqualTo: 'accepted')
              .where('reviewDue', isEqualTo: false)
              .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();

        // Check if either user is this user
        final isInvolved =
            data['fromUserId'] == userId || data['toUserId'] == userId;

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
