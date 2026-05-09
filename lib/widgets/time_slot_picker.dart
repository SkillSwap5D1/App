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

  String _formatDateForDisplay(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final today = DateTime(now.year, now.month, now.day);
    
    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'Today';
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final dayName = days[date.weekday - 1];
      return '$dayName, ${date.month}/${date.day}';
    }
  }

  Widget _buildDateField() {
    final isSet = _slot.date != null;
    final dateText = isSet 
        ? _formatDateForDisplay(_slot.date!)
        : 'Select date';

    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSet ? AppColors.borderActive : AppColors.border,
            width: isSet ? 1.5 : 1,
          ),
          boxShadow: [
            if (isSet)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: isSet ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dateText,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSet ? AppColors.textPrimary : AppColors.textMuted,
                  fontWeight: isSet ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    final isSet = time != null;

    return Expanded(
      child: GestureDetector(
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
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isSet ? AppColors.borderActive : AppColors.border,
                  width: isSet ? 1.5 : 1,
                ),
                boxShadow: [
                  if (isSet)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: isSet ? AppColors.primary : AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isSet ? time.format(context) : 'Select',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSet ? AppColors.textPrimary : AppColors.textMuted,
                        fontWeight: isSet ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
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
    final isComplete = _slot.date != null && _slot.startTime != null && _slot.endTime != null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasError ? AppColors.error : (isComplete ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border),
          width: hasError ? 1.5 : 1,
        ),
        boxShadow: [
          if (isComplete)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ...AppShadows.card,
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Time Slot',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (widget.showRemove)
                  GestureDetector(
                    onTap: widget.onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Date field
            _buildDateField(),
            const SizedBox(height: AppSpacing.lg),

            // Time range
            Row(
              children: [
                _buildTimeField(
                  label: 'Start Time',
                  time: _slot.startTime,
                  onTap: _selectStartTime,
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 12),
                _buildTimeField(
                  label: 'End Time',
                  time: _slot.endTime,
                  onTap: _selectEndTime,
                ),
              ],
            ),

            // Error message
            if (hasError) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _slot.errorMessage,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Success indicator
            if (isComplete && !hasError) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Time slot configured',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
