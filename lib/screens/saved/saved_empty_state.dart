import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SavedEmptyState extends StatelessWidget {
  final VoidCallback onBrowsePressed;

  const SavedEmptyState({
    super.key,
    required this.onBrowsePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.bookmark_outline,
                size: 48,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Title
          Text(
            'No saved skills yet',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Browse to find and save skills',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Browse Button
          ElevatedButton(
            onPressed: onBrowsePressed,
            child: const Text('Browse Skills'),
          ),
        ],
      ),
    );
  }
}
