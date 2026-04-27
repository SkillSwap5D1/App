import 'package:flutter/material.dart';
import 'package:skillswap_app/theme/app_theme.dart';

class SnackBarHelper {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.surface,
        ),
      ),
      backgroundColor: isError ? AppColors.error : AppColors.primary,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: AppColors.accent,
              onPressed: onAction,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void success(BuildContext context, String message) {
    show(context, message, isError: false);
  }

  static void error(BuildContext context, String message) {
    show(context, message, isError: true);
  }
}
