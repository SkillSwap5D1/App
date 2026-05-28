import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final MockMessage message;
  final bool showDeliveryStatus;

  const MessageBubble({
    super.key,
    required this.message,
    this.showDeliveryStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: message.isMe ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.md),
                  topRight: const Radius.circular(AppRadius.md),
                  bottomLeft: Radius.circular(message.isMe ? AppRadius.md : 2),
                  bottomRight: Radius.circular(message.isMe ? 2 : AppRadius.md),
                ),
                border: Border.all(
                  color: message.isMe ? AppColors.primary : AppColors.border,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 8.0,
              ),
              child: Text(
                message.text,
                style: AppTextStyles.bodySmall.copyWith(
                  color:
                      message.isMe ? AppColors.surface : AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.timestamp,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ).copyWith(color: AppColors.textMuted),
                  ),
                  if (message.isMe && showDeliveryStatus) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.check_circle,
                      size: 12,
                      color: AppColors.success,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
