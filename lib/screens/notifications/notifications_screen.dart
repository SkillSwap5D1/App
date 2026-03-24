import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import 'notification_row.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // ── STATE ──────────────────────────────────────────────────────────────
  late List<MockNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(MockData.notifications);
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        // Create a new notification with isRead = true
        final index = _notifications.indexOf(notification);
        _notifications[index] = MockNotification(
          id: notification.id,
          type: notification.type,
          title: notification.title,
          subtitle: notification.subtitle,
          timeAgo: notification.timeAgo,
          isRead: true,
        );
      }
    });
  }

  void _markAsRead(int index) {
    if (!_notifications[index].isRead) {
      setState(() {
        final notification = _notifications[index];
        _notifications[index] = MockNotification(
          id: notification.id,
          type: notification.type,
          title: notification.title,
          subtitle: notification.subtitle,
          timeAgo: notification.timeAgo,
          isRead: true,
        );
      });
    }
  }

  void _handleNotificationTap(MockNotification notification) {
    // Navigator based on notification type
    switch (notification.type) {
      case 'message':
        // TODO: Navigate to chat thread
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening chat...')),
        );
        break;
      case 'request':
        // TODO: Navigate to requests screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening requests...')),
        );
        break;
      case 'reminder':
        // TODO: Navigate to relevant screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening reminder...')),
        );
        break;
      case 'accepted':
      case 'declined':
        // TODO: Navigate to requests/bookings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening status update...')),
        );
        break;
      default:
        break;
    }
  }

  void _deleteNotification(int index) {
    final notification = _notifications[index];
    setState(() {
      _notifications.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _notifications.insert(index, notification);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: AppTextStyles.h2,
                  ),
                  TextButton(
                    onPressed: () {
                      _markAllAsRead();
                    },
                    child: const Text('Mark all as read'),
                  ),
                ],
              ),
            ),

            // ── NOTIFICATIONS LIST ──────────────────────────────────
            Expanded(
              child: _notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      itemCount: _notifications.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return Dismissible(
                          key: Key(notification.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(
                              right: AppSpacing.md,
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            _deleteNotification(index);
                          },
                          child: NotificationRow(
                            notification: notification,
                            onTap: () {
                              _markAsRead(index);
                              _handleNotificationTap(notification);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No notifications yet',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
