import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TagChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const TagChip({
    required this.label,
    this.backgroundColor,
    this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: textColor ?? AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
