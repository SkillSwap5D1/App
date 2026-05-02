import 'package:flutter/material.dart';
import '../models/time_slot.dart';
import '../theme/app_theme.dart';

class TimeSlotPicker extends StatefulWidget {
  final TimeSlot slot;
  final VoidCallback onRemove;
  final bool showRemove;

  const TimeSlotPicker({
    super.key,
    required this.slot,
    required this.onRemove,
    this.showRemove = false,
  });

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surfaceElevated,
              onSurface: AppColors.textPrimary,
            ),
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: AppColors.surfaceElevated,
              headerBackgroundColor: AppColors.accentDeep,
              headerForegroundColor: AppColors.textPrimary,
              dayForegroundColor: MaterialStatePropertyAll(AppColors.textPrimary),
              todayForegroundColor: MaterialStatePropertyAll(AppColors.accentLight),
              todayBackgroundColor: MaterialStatePropertyAll(Color(0x1AA78BFA)),
              dayBackgroundColor: MaterialStatePropertyAll(Colors.transparent),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surfaceElevated,
              onSurface: AppColors.textPrimary,
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: AppColors.surfaceElevated,
              hourMinuteColor: Color(0x1A6B21A8),
              hourMinuteTextColor: AppColors.textPrimary,
              dialBackgroundColor: AppColors.surface,
              dialHandColor: AppColors.primary,
              dayPeriodColor: Color(0x1A6B21A8),
              dayPeriodTextColor: AppColors.textPrimary,
              entryModeIconColor: AppColors.textPrimary,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surfaceElevated,
              onSurface: AppColors.textPrimary,
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: AppColors.surfaceElevated,
              hourMinuteColor: Color(0x1A6B21A8),
              hourMinuteTextColor: AppColors.textPrimary,
              dialBackgroundColor: AppColors.surface,
              dialHandColor: AppColors.primary,
              dayPeriodColor: Color(0x1A6B21A8),
              dayPeriodTextColor: AppColors.textPrimary,
              entryModeIconColor: AppColors.textPrimary,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
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
    required IconData icon,
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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.accentLight),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: value.startsWith('Select')
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveButton() {
    return GestureDetector(
      onTap: widget.onRemove,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: const Color(0x14EF4444),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: const Color(0x33EF4444)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.close_rounded, size: 14, color: AppColors.error),
            const SizedBox(width: 6),
            Text(
              'Remove',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = !_slot.isEmpty && !_slot.isValid;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasError ? AppColors.error : AppColors.border,
          width: 1,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Time Slot',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              if (widget.showRemove)
                GestureDetector(
                  onTap: widget.onRemove,
                  child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildField(
            label: 'Date',
            value: _slot.date != null
                ? '${_slot.date!.month}/${_slot.date!.day}/${_slot.date!.year}'
                : 'Select date',
            icon: Icons.calendar_month_rounded,
            onTap: _selectDate,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  label: 'Start Time',
                  value: _slot.startTime != null
                      ? _slot.startTime!.format(context)
                      : 'Select time',
                  icon: Icons.schedule_rounded,
                  onTap: _selectStartTime,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildField(
                  label: 'End Time',
                  value: _slot.endTime != null
                      ? _slot.endTime!.format(context)
                      : 'Select time',
                  icon: Icons.schedule_rounded,
                  onTap: _selectEndTime,
                ),
              ),
            ],
          ),
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
          if (widget.showRemove)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: _buildRemoveButton(),
            ),
        ],
      ),
    );
  }
}
