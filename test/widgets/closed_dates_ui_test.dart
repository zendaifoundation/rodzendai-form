import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rodzendai_form/widgets/dialog/date_picker.dart';

void main() {
  testWidgets('ปฏิทินแสดงวันปิดเป็นขีดฆ่า และกดเลือกไม่ได้', (tester) async {
    final now = DateTime.now();
    final closedDay = DateTime(now.year, now.month, 15);
    final openDay = DateTime(now.year, now.month, 16);
    List<DateTime?>? result;

    // header เดือนของ package ล้นเฉพาะในเทสต์ เพราะฟอนต์ทดสอบกว้างกว่าฟอนต์จริง
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('RenderFlex overflowed')) return;
      originalOnError?.call(details);
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await DatePickerDialogCustom.showThai(
                context,
                firstDate: DateTime(now.year, now.month, 1),
                isMulti: true,
                title: 'เลือกวันที่นัดหมาย',
                closedDayPredicate: (day) =>
                    DateUtils.isSameDay(day, closedDay),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    Finder day(String text) => find.descendant(
      of: find.byType(CalendarDatePicker2),
      matching: find.text(text),
    );

    expect(find.text('เลือกวันที่นัดหมาย'), findsOneWidget);
    expect(find.text('ยังไม่ได้เลือกวันที่'), findsOneWidget);

    final closedText = tester.widget<Text>(day('15'));
    expect(closedText.style?.decoration, TextDecoration.lineThrough);
    final openText = tester.widget<Text>(day('16'));
    expect(openText.style?.decoration, isNot(TextDecoration.lineThrough));

    await tester.tap(day('15'));
    await tester.tap(day('16'));
    await tester.pumpAndSettle();
    expect(find.text('เลือกแล้ว 1 วัน'), findsOneWidget);
    await tester.tap(find.text('ตกลง'));
    await tester.pumpAndSettle();
    FlutterError.onError = originalOnError;

    expect(result, [openDay]);
  });
}
