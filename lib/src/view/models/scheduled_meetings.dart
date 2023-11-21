import 'package:flutter/material.dart';

class Meeting {
  final String name;
  final DateTime startDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  Meeting({
    required this.name,
    required this.startDate,
    required this.startTime,
    required this.endTime,
  });
}
