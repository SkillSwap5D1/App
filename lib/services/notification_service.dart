import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseMessaging? _firebaseMessaging;
  final FirebaseFirestore _firestore;

  NotificationService({FirebaseMessaging? firebaseMessaging, FirebaseFirestore? firestore})
      : _firebaseMessaging = firebaseMessaging,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> initialize() async {
    // Request user permission for notifications
    final messaging = _firebaseMessaging ?? FirebaseMessaging.instance;
    await messaging.requestPermission();

    // Handle notification when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundNotification(message);
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleBackgroundNotificationTap(message);
    });
  }

  void _handleForegroundNotification(RemoteMessage message) {
    // TODO: Implement foreground notification handling
  }

  void _handleBackgroundNotificationTap(RemoteMessage message) {
    // TODO: Implement background notification tap handling
  }

  Future<String?> getDeviceToken() async {
    final messaging = _firebaseMessaging ?? FirebaseMessaging.instance;
    return await messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    final messaging = _firebaseMessaging ?? FirebaseMessaging.instance;
    await messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    final messaging = _firebaseMessaging ?? FirebaseMessaging.instance;
    await messaging.unsubscribeFromTopic(topic);
  }

  // Write a notification document for a user
  // Types: new_request | request_accepted | request_declined |
  // countered | new_message | review_due
  Future<void> sendNotification(
    String userId,
    String type,
    String title,
    String body,
    String relatedId,
  ) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'type': type,
        'title': title,
        'subtitle': body,
        'relatedId': relatedId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Get all notifications for a user — used on Notifications screen
  // Query notifications where userId matches
  // Order by createdAt descending
  // Return as real-time stream
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    NotificationModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList();
        });
  }

  // Get unread count — used for badge on nav bar icon
  // Query notifications where userId matches AND isRead == false
  // Return count as a stream
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark a single notification as read
  // Set isRead = true on the notification document
  Future<void> markRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  // Query all unread notifications for user
  // Use a Firestore batch write to set isRead=true on all of them
  Future<void> markAllRead(String userId) async {
    try {
      final unreadNotifications =
          await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

      final batch = _firestore.batch();

      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Get a single notification by ID
  Future<NotificationModel?> getNotificationById(String notificationId) async {
    try {
      final doc =
          await _firestore
              .collection('notifications')
              .doc(notificationId)
              .get();
      if (doc.exists) {
        return NotificationModel.fromMap({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error getting notification: $e');
      return null;
    }
  }

  // Delete a notification by ID
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
}
