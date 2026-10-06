import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/models/closed_date_range.dart';

/// ตรวจวันที่ปิดรับการนัดหมาย จาก 2 แหล่งรวมกัน
/// 1. `closedDates` ของโครงการ (มาจาก API — แต่ละโครงการตั้งต่างกันได้ ไม่ต้อง deploy ใหม่)
/// 2. [_customerClosedRanges] ปิดทั้ง customer (hardcode ตาม customerCode)
class ClosedDateHelper {
  static final Map<String, List<ClosedDateRange>> _customerClosedRanges = {
    'pattaya': [
      ClosedDateRange(start: DateTime(2026, 9, 21), end: DateTime(2026, 9, 30)),
    ],
  };

  static List<ClosedDateRange> _allRanges(
    List<ClosedDateRange> projectClosedDates,
  ) => [
    ...projectClosedDates,
    ...?_customerClosedRanges[EnvHelper.customerCode],
  ];

  static bool isClosed(
    DateTime date, {
    List<ClosedDateRange> projectClosedDates = const [],
  }) => _allRanges(projectClosedDates).any((r) => r.contains(date));
}
