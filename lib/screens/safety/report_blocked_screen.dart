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

  // Categories for report
  static const List<String> _reportCategories = [
    'Harassment',
    'Spam',
    'Inappropriate Content',
    'Fake Profile',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _showReportForm() {
    setState(() {
      _selectedCategory = null;
      _descriptionController.clear();
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
      builder: (context) => AlertDialog(
        title: Text('Block ${widget.userName}?'),
        content: const Text(
          'Blocking this user will stop all communication.',
        ),
        contentPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onBlock();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.userName} has been blocked'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text(
              'Block',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
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
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                'Report ${widget.userName}',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Category dropdown
              Text(
                'Category (required)',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  hint: const Text('Select a category'),
                  items: _reportCategories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
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

              // Description field
              Text(
                'Description (optional)',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                placeholder: const Text('Tell us what happened...'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  hintText: 'Tell us what happened...',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedCategory != null
                      ? () {
                          setState(() => _isSubmittingReport = true);
                          Future.delayed(const Duration(seconds: 1), () {
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Report submitted. Our team will review it shortly.',
                                  ),
                                  duration: Duration(seconds: 3),
                                  backgroundColor: AppColors.success,
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
                      : const Text('Submit Report'),
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
