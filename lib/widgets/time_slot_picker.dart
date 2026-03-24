import 'package:flutter/material.dart';
import '../models/time_slot.dart';
import '../theme/app_theme.dart';

class TimeSlotPicker extends StatefulWidget {
  final TimeSlot slot;
  final VoidCallback onRemove;
  final bool showRemove;

  const TimeSlotPicker({
    Key? key,
    required this.slot,
    required this.onRemove,
    this.showRemove = false,
  }) : super(key: key);

  @override
  State<TimeSlotPicker> createState() => _TimeSlotPickerState();
}

class _TimeSlotPickerState extends State<TimeSlotPicker> {
  late TimeSlot _slot;

  @override
  void initState() {
    super.initState();
    _slot = widget.slot;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = !_slot.isEmpty && !_slot.isValid;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: hasError ? AppColors.error : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder for date and time fields
          SizedBox(height: AppSpacing.md),
          
          // Error message
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text(
                _slot.errorMessage,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          
          // Remove button
          if (widget.showRemove)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: GestureDetector(
                onTap: widget.onRemove,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    'Remove',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
