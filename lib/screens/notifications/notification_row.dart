import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';

class NotificationRow extends StatelessWidget {
  final MockNotification notification;
  final VoidCallback onTap;

  const NotificationRow({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData _getIconForType(String type) {
    switch (type) {
      case 'message':
        return Icons.chat_bubble;
      case 'request':
        return Icons.mail;
      case 'reminder':
        return Icons.schedule;
      case 'accepted':
        return Icons.check_circle;
      case 'declined':
        return Icons.cancel;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'message':
        return AppColors.primary;
      case 'request':
        return AppColors.info;
      case 'reminder':
        return AppColors.warning;
      case 'accepted':
        return AppColors.success;
      case 'declined':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppColors.surface
                : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.border
                  : AppColors.primary,
              width: 0.5,
            ),
            boxShadow: notification.isRead
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── ICON ────────────────────────────────────────────
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getColorForType(notification.type)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getColorForType(notification.type)
                        .withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getIconForType(notification.type),
                    color: _getColorForType(notification.type),
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // ── CONTENT ────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notification.subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // ── TIMESTAMP ────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    notification.timeAgo,
                    style: AppTextStyles.caption,
                  ),
                  if (!notification.isRead)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
