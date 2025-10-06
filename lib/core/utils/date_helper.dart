import 'package:flutter/src/material/time.dart';
import 'package:intl/intl.dart';

class DateHelper {
  DateHelper._();

  static dateTimeDefault(int? input) {
    if (input == null) return '-';
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(input);
    final DateFormat formatter = DateFormat('dd MMM yyyy - HH:mm');
    final String formatted = formatter.format(dateTime);
    return formatted;
  }

  static dateTimeThaiDefault(int? input) {
    if (input == null) return '-';
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(input);
    final DateFormat formatter = DateFormat('dd MMM', 'th_TH');
    final String formatted = formatter.format(dateTime);
    final int year = dateTime.year + 543;
    return '$formatted $year';
  }

  /// แปลง DateTime เป็น String ในรูปแบบ "yyyy-MM-dd"
  static String? formatDate(DateTime? date) {
    if (date == null) return null;
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  static formatTime(TimeOfDay? appointmentTimeSelected) {
    if (appointmentTimeSelected == null) return null;
    final hour = appointmentTimeSelected.hour.toString().padLeft(2, '0');
    final minute = appointmentTimeSelected.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
