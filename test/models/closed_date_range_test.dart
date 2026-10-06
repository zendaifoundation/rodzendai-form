import 'package:flutter_test/flutter_test.dart';
import 'package:rodzendai_form/models/closed_date_range.dart';
import 'package:rodzendai_form/models/project_model.dart';

void main() {
  group('ClosedDateRange', () {
    test('ช่วงวันที่นับรวมวันแรกและวันสุดท้าย', () {
      final range = ClosedDateRange.tryFromJson({
        'start': '2026-09-21',
        'end': '2026-09-30',
      })!;

      expect(range.contains(DateTime(2026, 9, 20)), isFalse);
      expect(range.contains(DateTime(2026, 9, 21)), isTrue);
      expect(range.contains(DateTime(2026, 9, 30, 23, 59)), isTrue);
      expect(range.contains(DateTime(2026, 10, 1)), isFalse);
    });

    test('รองรับวันเดียว ทั้งแบบ map ไม่มี end และแบบ string', () {
      final ranges = ClosedDateRange.listFromJson([
        {'start': '2026-10-13'},
        '2026-10-23',
      ]);

      expect(ranges, hasLength(2));
      expect(ranges[0].contains(DateTime(2026, 10, 13)), isTrue);
      expect(ranges[0].contains(DateTime(2026, 10, 14)), isFalse);
      expect(ranges[1].contains(DateTime(2026, 10, 23)), isTrue);
    });

    test('ISO แบบ UTC ไม่ทำให้วันเลื่อน', () {
      final range = ClosedDateRange.tryFromJson({
        'start': '2026-09-21T00:00:00.000Z',
        'end': '2026-09-21T23:59:59.000Z',
      })!;

      expect(range.start, DateTime(2026, 9, 21));
      expect(range.end, DateTime(2026, 9, 21));
    });

    test('ข้อมูลผิดรูปแบบถูกข้าม ไม่ throw', () {
      expect(ClosedDateRange.listFromJson(null), isEmpty);
      expect(ClosedDateRange.listFromJson('2026-09-21'), isEmpty);
      expect(
        ClosedDateRange.listFromJson([
          {'start': ''},
          {'end': '2026-09-30'},
          {'start': '2026-09-30', 'end': '2026-09-21'},
          'abc',
          null,
        ]),
        isEmpty,
      );
    });
  });

  test('ProjectModel อ่าน closedDates และไม่พังถ้าไม่มี field', () {
    final withDates = ProjectModel.fromJson({
      'id': 'p1',
      'name': 'A',
      'closedDates': [
        {'start': '2026-09-21', 'end': '2026-09-30'},
      ],
    });
    final without = ProjectModel.fromJson({'id': 'p2', 'name': 'B'});

    expect(withDates.closedDates, hasLength(1));
    expect(without.closedDates, isEmpty);
  });
}
