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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFB7DEC7),
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: Color(0xFFF0FDF9),
              headerForegroundColor: Color(0xFF0F172A),
              dayForegroundColor: MaterialStatePropertyAll(Color(0xFF0F172A)),
              todayForegroundColor: MaterialStatePropertyAll(Color(0xFFB7DEC7)),
              todayBackgroundColor: MaterialStatePropertyAll(Color(0x1AB7DEC7)),
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFB7DEC7),
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteColor: Color(0xFFF0FDF9),
              hourMinuteTextColor: Color(0xFF0F172A),
              dialBackgroundColor: Color(0xFFF8FAFC),
              dialHandColor: Color(0xFFB7DEC7),
              dayPeriodColor: Color(0xFFF0FDF9),
              dayPeriodTextColor: Color(0xFF0F172A),
              entryModeIconColor: Color(0xFF0F172A),
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFB7DEC7),
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteColor: Color(0xFFF0FDF9),
              hourMinuteTextColor: Color(0xFF0F172A),
              dialBackgroundColor: Color(0xFFF8FAFC),
              dialHandColor: Color(0xFFB7DEC7),
              dayPeriodColor: Color(0xFFF0FDF9),
              dayPeriodTextColor: Color(0xFF0F172A),
              entryModeIconColor: Color(0xFF0F172A),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSet ? const Color(0xFFB7DEC7) : const Color(0xFFE2E8F0),
            width: isSet ? 1.5 : 1,
          ),
          boxShadow: [
            if (isSet)
              BoxShadow(
                color: const Color(0xFFB7DEC7).withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: isSet ? const Color(0xFFB7DEC7) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dateText,
                style: TextStyle(
                  color: isSet ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: isSet ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF94A3B8),
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
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSet ? const Color(0xFFB7DEC7) : const Color(0xFFE2E8F0),
                  width: isSet ? 1.5 : 1,
                ),
                boxShadow: [
                  if (isSet)
                    BoxShadow(
                      color: const Color(0xFFB7DEC7).withOpacity(0.08),
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
                    color: isSet ? const Color(0xFFB7DEC7) : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isSet ? time.format(context) : 'Select',
                      style: TextStyle(
                        color: isSet ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                        fontSize: 14,
                        fontWeight: isSet ? FontWeight.w600 : FontWeight.w400,
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasError
              ? const Color(0xFFEF4444)
              : (isComplete
                  ? const Color(0xFFB7DEC7).withOpacity(0.3)
                  : const Color(0xFFE2E8F0)),
          width: hasError ? 1.5 : 1,
        ),
        boxShadow: [
          if (isComplete)
            BoxShadow(
              color: const Color(0xFFB7DEC7).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        color: const Color(0xFFB7DEC7).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: const Color(0xFFB7DEC7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Time Slot',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
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
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Date field
            _buildDateField(),
            const SizedBox(height: 16),

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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _slot.errorMessage,
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 12,
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
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 12,
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
