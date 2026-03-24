import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
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
  // Report state
  String? _selectedCategory;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmittingReport = false;
  int _descriptionCharCount = 0;

  // Categories for report
  static const List<String> _reportCategories = [
    'Harassment',
    'Spam',
    'Inappropriate Content',
    'Fake Profile',
    'Other',
  ];

  // Get icon for category
  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Harassment':
        return Icons.warning;
      case 'Spam':
        return Icons.mail_outline;
      case 'Inappropriate Content':
        return Icons.flag;
      case 'Fake Profile':
        return Icons.person_off;
      case 'Other':
        return Icons.more_horiz;
      default:
        return Icons.help_outline;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _showReportForm() {
    setState(() {
      _selectedCategory = null;
      _descriptionController.clear();
      _descriptionCharCount = 0;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (context) => _buildReportForm(),
    );
  }

  void _showBlockConfirmation() {
    showDialog(
      context: context,
      builder: (context) => ScaleTransition(
        scale: AlwaysStoppedAnimation(1.0),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          icon: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.block,
                color: AppColors.error,
                size: 28,
              ),
            ),
          ),
          title: Text(
            'Block ${widget.userName}?',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Blocking this user will stop all communication.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This action will:',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '• Hide their messages',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Remove the conversation',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Prevent future contact',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          actionsPadding: const EdgeInsets.all(AppSpacing.md),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Add to MockData blocked list
                MockData.blockUser(widget.userId);
                Navigator.pop(context);
                widget.onBlock();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.surface,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              '${widget.userName} has been blocked',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(AppSpacing.md),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: Text(
                'Block',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportForm() {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar with animation
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title with slide animation
              SlideTransition(
                position: AlwaysStoppedAnimation(const Offset(0, 0)),
                child: Text(
                  'Report ${widget.userName}',
                  style: AppTextStyles.h3,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Category dropdown with enhanced styling
              Text(
                'Category (required)',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedCategory != null
                        ? AppColors.primary
                        : AppColors.border,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  color: AppColors.background,
                ),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  hint: Row(
                    children: [
                      Icon(Icons.category, color: AppColors.textMuted),
                      const SizedBox(width: AppSpacing.sm),
                      const Text('Select a category'),
                    ],
                  ),
                  items: _reportCategories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Icon(
                                  _getIconForCategory(category),
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(category),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Description field with enhanced validation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Description (optional)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_descriptionCharCount}/1000',
                    style: AppTextStyles.caption.copyWith(
                      color: _descriptionCharCount > 900
                          ? AppColors.error
                          : _descriptionCharCount > 800
                              ? AppColors.warning
                              : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 1000,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(
                      color: _descriptionCharCount > 0
                          ? AppColors.primary.withOpacity(0.5)
                          : AppColors.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(
                      color: _descriptionCharCount > 0
                          ? AppColors.primary.withOpacity(0.5)
                          : AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  hintText: 'Tell us what happened... (be specific)',
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.background,
                ),
                onChanged: (value) {
                  setState(() {
                    _descriptionCharCount = value.length;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Submit button with enhanced styling and animation
              ScaleTransition(
                scale: AlwaysStoppedAnimation(1.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedCategory != null && !_isSubmittingReport
                        ? () {
                            setState(() => _isSubmittingReport = true);
                            Future.delayed(const Duration(seconds: 1), () {
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: AppColors.surface,
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                'Report submitted',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                'Our team will review it shortly.',
                                                style: AppTextStyles.caption,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    duration: const Duration(seconds: 3),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.all(
                                        AppSpacing.md),
                                  ),
                                );
                                setState(() => _isSubmittingReport = false);
                              }
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      backgroundColor: _selectedCategory != null
                          ? AppColors.primary
                          : AppColors.border,
                      disabledBackgroundColor: AppColors.border,
                      elevation: _selectedCategory != null ? 2 : 0,
                    ),
                    child: _isSubmittingReport
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.surface,
                              ),
                            ),
                          )
                        : Text(
                            'Submit Report',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _selectedCategory != null
                                  ? AppColors.surface
                                  : AppColors.textMuted,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This widget is accessed via methods, not directly in hierarchy
    return const SizedBox.shrink();
  }
}
