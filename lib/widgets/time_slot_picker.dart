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

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    
    final selected = await showDatePicker(
      context: context,
      initialDate: _slot.date ?? now,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 1),
    );
    
    if (selected != null) {
      setState(() {
        _slot.date = selected;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _slot.startTime ?? TimeOfDay(hour: 10, minute: 0),
    );
    
    if (selected != null) {
      setState(() {
        _slot.startTime = selected;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _slot.endTime ?? TimeOfDay(hour: 11, minute: 0),
    );
    
    if (selected != null) {
      setState(() {
        _slot.endTime = selected;
      });
    }
  }

  Widget _buildField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
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
          // Date picker
          _buildField(
            label: 'Date',
            value: _slot.date != null
                ? '${_slot.date!.month}/${_slot.date!.day}/${_slot.date!.year}'
                : 'Select date',
            onTap: _selectDate,
          ),
          SizedBox(height: AppSpacing.md),
          
          // Time pickers row
          Row(
            children: [
              Expanded(
                child: _buildField(
                  label: 'Start Time',
                  value: _slot.startTime != null
                      ? _slot.startTime!.format(context)
                      : 'Select time',
                  onTap: _selectStartTime,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildField(
                  label: 'End Time',
                  value: _slot.endTime != null
                      ? _slot.endTime!.format(context)
                      : 'Select time',
                  onTap: _selectEndTime,
                ),
              ),
            ],
          ),
          
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
