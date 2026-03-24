import 'package:flutter/material.dart';

class TimeSlot {
  DateTime? date;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  TimeSlot({
    this.date,
    this.startTime,
    this.endTime,
  });

  bool get isEmpty => date == null || startTime == null || endTime == null;
}
