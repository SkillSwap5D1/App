import 'package:flutter/material.dart';

class TimeSlot {
  DateTime? date;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  TimeSlot({this.date, this.startTime, this.endTime});

  bool get isEmpty => date == null || startTime == null || endTime == null;

  bool get isValid {
    if (isEmpty) return false;

    // Check if date is in the past
    final now = DateTime.now();
    final dateToCheck = DateTime(date!.year, date!.month, date!.day);
    final today = DateTime(now.year, now.month, now.day);

    if (dateToCheck.isBefore(today)) return false;

    // Check if time is in the past (if today)
    if (dateToCheck.isAtSameMomentAs(today)) {
      final startTotalMinutes = startTime!.hour * 60 + startTime!.minute;
      final nowTotalMinutes = now.hour * 60 + now.minute;
      if (startTotalMinutes < nowTotalMinutes) return false;
    }

    // Check if end time is after start time
    final startTotalMinutes = startTime!.hour * 60 + startTime!.minute;
    final endTotalMinutes = endTime!.hour * 60 + endTime!.minute;
    if (endTotalMinutes <= startTotalMinutes) return false;

    return true;
  }

  String get errorMessage {
    if (date == null || startTime == null || endTime == null) {
      return 'All fields required';
    }

    final now = DateTime.now();
    final dateToCheck = DateTime(date!.year, date!.month, date!.day);
    final today = DateTime(now.year, now.month, now.day);

    if (dateToCheck.isBefore(today)) {
      return 'Date cannot be in the past';
    }

    if (dateToCheck.isAtSameMomentAs(today)) {
      final startTotalMinutes = startTime!.hour * 60 + startTime!.minute;
      final nowTotalMinutes = now.hour * 60 + now.minute;
      if (startTotalMinutes < nowTotalMinutes) {
        return 'Time cannot be in the past';
      }
    }

    final startTotalMinutes = startTime!.hour * 60 + startTime!.minute;
    final endTotalMinutes = endTime!.hour * 60 + endTime!.minute;
    if (endTotalMinutes <= startTotalMinutes) {
      return 'End time must be after start time';
    }

    return '';
  }
}
