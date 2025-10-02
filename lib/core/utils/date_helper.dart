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
}
