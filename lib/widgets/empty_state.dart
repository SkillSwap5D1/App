import 'package:flutter/material.dart';
import 'package:skillswap_app/theme/app_theme.dart';

class EmptyState {
  static Widget listing({
    VoidCallback? onBrowse,
  }) {
    return _buildEmptyState(
      icon: Icons.search_rounded,
      title: 'No skills found',
      subtitle: 'Try adjusting your filters or search terms',
      action: onBrowse != null
          ? ElevatedButton(
              onPressed: onBrowse,
              child: Text('Browse Skills'),
            )
          : null,
    );
  }

  static Widget conversation() {
    return _buildEmptyState(
      icon: Icons.chat_rounded,
      title: 'No conversations yet',
      subtitle: 'Start by sending a request or receiving one',
    );
  }

  static Widget notification() {
    return _buildEmptyState(
      icon: Icons.notifications_rounded,
      title: 'No notifications',
      subtitle: 'You\'re all caught up!',
    );
  }

  static Widget saved() {
    return _buildEmptyState(
      icon: Icons.bookmark_rounded,
      title: 'No saved skills yet',
      subtitle: 'Bookmark skills you\'d like to learn',
    );
  }

  static Widget request() {
    return _buildEmptyState(
      icon: Icons.mail_rounded,
      title: 'No requests',
      subtitle: 'Requests will appear here',
    );
  }

  static Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.border,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              SizedBox(height: AppSpacing.lg),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
