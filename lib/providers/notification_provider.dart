import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  // ── State ─────────────────────────────────────────────────────────────────
  List<NotificationModel> notifications = [];
  int unreadCount = 0;
  bool isLoading = false;

  // ── Stream subscription ───────────────────────────────────────────────────
  StreamSubscription? _notificationsSubscription;

  // ── Load notifications for a user ─────────────────────────────────────────
  Future<void> loadNotifications(String uid) async {
    _notificationsSubscription?.cancel();
    isLoading = true;
    notifyListeners();

    try {
      _notificationsSubscription = _notificationService
          .getNotifications(uid)
          .listen(
            (notifs) {
              notifications = notifs;
              unreadCount = notifs.where((n) => !n.isRead).length;
              notifyListeners();
            },
            onError: (error) {
              if (kDebugMode) {
                print('❌ Error loading notifications: $error');
              }
              isLoading = false;
              notifyListeners();
            },
          );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading notifications: $e');
      }
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Mark all as read ──────────────────────────────────────────────────────
  Future<void> markAllAsRead(String uid) async {
    try {
      await _notificationService.markAllRead(uid);
      // Small delay to ensure Firestore updates propagate
      await Future.delayed(const Duration(milliseconds: 300));
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error marking all as read: $e');
      }
    }
  }

  // ── Mark one as read ──────────────────────────────────────────────────────
  Future<void> markOneAsRead(String notificationId) async {
    try {
      await _notificationService.markRead(notificationId);
    } catch (e) {
      if (kDebugMode) {
        print('Error marking as read: $e');
      }
    }
  }

  // ── Cleanup subscription ──────────────────────────────────────────────────
  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }
}
