import 'package:flutter/material.dart';

/// ช่วงวันที่ที่โครงการปิดรับการนัดหมาย (นับรวมทั้งวัน start และ end)
///
/// รูปแบบจาก API (field `closedDates` ของโครงการ):
/// ```json
/// [
///   {"start": "2026-09-21", "end": "2026-09-30", "note": "ปิดปรับปรุงระบบ"},
///   {"start": "2026-10-13"},
///   "2026-10-23"
/// ]
/// ```
class ClosedDateRange {
  ClosedDateRange({required DateTime start, DateTime? end, this.note})
    : start = DateUtils.dateOnly(start),
      end = DateUtils.dateOnly(end ?? start);

  final DateTime start;
  final DateTime end;
  final String? note;

  bool contains(DateTime date) {
    final day = DateUtils.dateOnly(date);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  // ใช้เฉพาะส่วน YYYY-MM-DD เพื่อกัน timezone shift กรณี backend ส่งเป็น ISO (UTC)
  static DateTime? _parseDay(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    if (text.length < 10) return null;
    return DateTime.tryParse(text.substring(0, 10));
  }

  static ClosedDateRange? tryFromJson(dynamic json) {
    if (json is Map) {
      final start = _parseDay(json['start']);
      if (start == null) return null;
      final end = _parseDay(json['end']) ?? start;
      if (end.isBefore(start)) return null;
      return ClosedDateRange(
        start: start,
        end: end,
        note: json['note']?.toString(),
      );
    }
    final day = _parseDay(json);
    return day == null ? null : ClosedDateRange(start: day);
  }

  /// ข้อมูลผิดรูปแบบจะถูกข้าม ไม่ทำให้ parse ทั้งโครงการล้ม
  static List<ClosedDateRange> listFromJson(dynamic json) {
    if (json is! List) return const [];
    return json.map(tryFromJson).whereType<ClosedDateRange>().toList();
  }

  Map<String, dynamic> toJson() => {
    'start': _format(start),
    'end': _format(end),
    if (note != null) 'note': note,
  };

  static String _format(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
