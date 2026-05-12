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
  bool _isMarkingAllAsRead = false;

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

  Future<void> _markAllAsRead() async {
    final currentUid = context.read<AuthProvider>().currentUser?.uid;
    if (currentUid == null || _isMarkingAllAsRead) return;

    setState(() => _isMarkingAllAsRead = true);

    try {
      await context.read<NotificationProvider>().markAllAsRead(currentUid);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    } finally {
      if (mounted) {
        setState(() => _isMarkingAllAsRead = false);
      }
    }
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
                        final canTap =
                            context.read<AuthProvider>().currentUser?.uid !=
                            null;

                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: canTap ? 1 : 0.5,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF4F0FF), Color(0xFFE8F1FF)],
                              ),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.accentLight.withValues(
                                  alpha: 0.28,
                                ),
                              ),
                            ),
                            child: TextButton.icon(
                              onPressed:
                                  canTap && !_isMarkingAllAsRead
                                      ? _markAllAsRead
                                      : null,
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                child:
                                    _isMarkingAllAsRead
                                        ? SizedBox(
                                          key: const ValueKey('loading'),
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.accent,
                                          ),
                                        )
                                        : Icon(
                                          Icons.done_all_rounded,
                                          key: const ValueKey('icon'),
                                          size: 16,
                                          color: AppColors.accent,
                                        ),
                              ),
                              label: Text(
                                _isMarkingAllAsRead
                                    ? 'Marking...'
                                    : 'Mark all as read',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.accent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ),
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
