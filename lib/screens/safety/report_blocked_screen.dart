import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ReportBlockedScreen extends StatefulWidget {
  final String userName;
  final String userId;
  final VoidCallback onBlock;

  const ReportBlockedScreen({
    super.key,
    required this.userName,
    required this.userId,
    required this.onBlock,
  });

  @override
  State<ReportBlockedScreen> createState() => _ReportBlockedScreenState();
}

class _ReportBlockedScreenState extends State<ReportBlockedScreen> {
  void _handleBlock() {
    widget.onBlock();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report / Block'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What would you like to do with ${widget.userName}?',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'You can report this user for review or block them to stop future contact.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Report submitted', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                      backgroundColor: AppColors.surfaceElevated,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
                child: const Text('Report user'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleBlock,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
                child: const Text('Block user'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
