import 'package:flutter/material.dart';
import 'package:skillswap_app/theme/app_theme.dart';

class TagChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const TagChip({super.key, 
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 3.0,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.pastelGreen,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: textColor ?? AppColors.pastelGreenDeep,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
