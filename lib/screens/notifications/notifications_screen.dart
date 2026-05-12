import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String? _loadedForUid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authProvider = context.watch<AuthProvider>();
    final currentUid = authProvider.currentUser?.uid;

    if (currentUid == null ||
        authProvider.isLoading ||
        currentUid == _loadedForUid) {
      return;
    }

    _loadedForUid = currentUid;
    context.read<NotificationProvider>().loadNotifications(currentUid);
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read
    context.read<NotificationProvider>().markOneAsRead(notification.id);

    // Navigate based on type
    switch (notification.type) {
      case 'new_message':
        Navigator.of(context).pushNamed('/chat');
        break;
      case 'new_request':
      case 'request_accepted':
      case 'request_declined':
      case 'request_completed':
      case 'countered':
        Navigator.of(context).pushNamed('/requests');
        break;
      case 'review_due':
        Navigator.of(context).pushNamed('/requests');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.editorialGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text('Notifications', style: AppTextStyles.h2),
                      ],
                    ),
                    Consumer<NotificationProvider>(
                      builder: (context, notifProvider, _) {
                        final authProvider = context.read<AuthProvider>();
                        final currentUid = authProvider.currentUser?.uid;
                        return TextButton(
                          onPressed:
                              currentUid != null
                                  ? () =>
                                      notifProvider.markAllAsRead(currentUid)
                                  : null,
                          child: const Text('Mark all as read'),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<NotificationProvider>(
                  builder: (context, notifProvider, _) {
                    if (notifProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (notifProvider.notifications.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      itemCount: notifProvider.notifications.length,
                      separatorBuilder:
                          (context, index) =>
                              const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final notification = notifProvider.notifications[index];
                        return _buildNotificationCard(notification);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return GestureDetector(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color:
              notification.isRead
                  ? AppColors.surface
                  : AppColors.accentLight.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color:
                notification.isRead
                    ? AppColors.borderLight
                    : AppColors.accentLight.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            _getNotificationIcon(notification.type),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight:
                          notification.isRead
                              ? FontWeight.w500
                              : FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(notification.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    late IconData icon;
    late Color color;

    switch (type) {
      case 'new_message':
        icon = Icons.chat_bubble;
        color = AppColors.primary;
        break;
      case 'new_request':
        icon = Icons.mail;
        color = AppColors.info;
        break;
      case 'request_accepted':
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case 'request_declined':
        icon = Icons.cancel;
        color = AppColors.error;
        break;
      case 'countered':
        icon = Icons.swap_horiz;
        color = AppColors.warning;
        break;
      case 'review_due':
        icon = Icons.star;
        color = AppColors.warning;
        break;
      default:
        icon = Icons.notifications;
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No notifications yet',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
