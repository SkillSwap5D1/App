import 'package:flutter/material.dart';
import 'package:skillswap_app/theme/app_theme.dart';

class DialogHelper {
  static Future<bool> confirmDelete(
    BuildContext context, {
    required String title,
    required String message,
    String deleteLabel = 'Delete',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            contentTextStyle: AppTextStyles.bodyMedium,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  deleteLabel,
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  static Future<bool> blockUser(
    BuildContext context, {
    required String userName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Block $userName?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'They can no longer message you or see your profile.',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Block', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required Widget title,
    required Widget content,
    List<Widget>? actions,
  }) async {
    return showDialog<T>(
      context: context,
      builder:
          (context) =>
              AlertDialog(title: title, content: content, actions: actions),
    );
  }
}
