import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';

class DatePickerDialogCustom {
  // รายชื่อเดือนภาษาไทย
  static const List<String> _thaiMonths = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  static Future<List<DateTime?>?> show(
    BuildContext context, {
    List<DateTime?>? value,
    DateTime? lastDate,
    DateTime? firstDate,
  }) async {
    // Implement your date picker dialog logic here
    final result = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        selectedDayHighlightColor: AppColors.primary,
        daySplashColor: AppColors.primary.withOpacity(0.2),
        currentDate: DateTime.now(),
        firstDate: firstDate ?? DateTime.now(),
        lastDate: lastDate ?? DateTime.now().add(Duration(days: 365)),
        calendarType: CalendarDatePicker2Type.single,
        okButtonTextStyle: AppTextStyles.regular.copyWith(
          color: AppColors.primary,
        ),
        cancelButtonTextStyle: AppTextStyles.regular,
        okButton: Text(
          'ตกลง',
          style: AppTextStyles.regular.copyWith(color: AppColors.primary),
        ),
        cancelButton: Text(
          'ยกเลิก',
          style: AppTextStyles.regular.copyWith(color: AppColors.textLight),
        ),
      ),
      dialogSize: const Size(325, 400),
      value: value ?? [],
      //value: [_selectedDate],
      borderRadius: BorderRadius.circular(8),
      dialogBackgroundColor: AppColors.white,
    );

    return result;
  }

  /// Dialog เลือกวันที่แบบไทย (เดือนภาษาไทย ปี พ.ศ.)
  static Future<List<DateTime?>?> showThai(
    BuildContext context, {
    List<DateTime?>? value,
    DateTime? lastDate,
    DateTime? firstDate,
    bool isMulti = false,
    String title = 'เลือกวันที่',
    // วันที่โครงการหยุดให้บริการ — เลือกไม่ได้ และแสดงเป็นสีแดงขีดฆ่า
    // ให้ต่างจากวันที่เลือกไม่ได้ทั่วไป (สีเทา)
    bool Function(DateTime day)? closedDayPredicate,
  }) {
    return showDialog<List<DateTime?>>(
      context: context,
      builder: (_) => _ThaiDatePickerDialog(
        title: title,
        initialValue: (value ?? []).whereType<DateTime>().toList(),
        firstDate: firstDate ?? DateTime.now(),
        lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
        isMulti: isMulti,
        closedDayPredicate: closedDayPredicate,
      ),
    );
  }
}

class _ThaiDatePickerDialog extends StatefulWidget {
  const _ThaiDatePickerDialog({
    required this.title,
    required this.initialValue,
    required this.firstDate,
    required this.lastDate,
    required this.isMulti,
    this.closedDayPredicate,
  });

  final String title;
  final List<DateTime> initialValue;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool isMulti;
  final bool Function(DateTime day)? closedDayPredicate;

  @override
  State<_ThaiDatePickerDialog> createState() => _ThaiDatePickerDialogState();
}

class _ThaiDatePickerDialogState extends State<_ThaiDatePickerDialog> {
  late List<DateTime> _selected = [...widget.initialValue];

  String _thaiDate(DateTime d) =>
      '${d.day} ${DatePickerDialogCustom._thaiMonths[d.month - 1]} ${d.year + 543}';

  String get _summary {
    if (_selected.isEmpty) return 'ยังไม่ได้เลือกวันที่';
    if (!widget.isMulti) return _thaiDate(_selected.first);
    return 'เลือกแล้ว ${_selected.length} วัน';
  }

  @override
  Widget build(BuildContext context) {
    final closedDayPredicate = widget.closedDayPredicate;

    return Dialog(
      backgroundColor: AppColors.white,
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 325),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: CalendarDatePicker2(
                  config: _buildConfig(closedDayPredicate),
                  value: _selected,
                  onValueChanged: (dates) => setState(() {
                    _selected = dates.whereType<DateTime>().toList()..sort();
                  }),
                ),
              ),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        spacing: 12,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.white,
              size: 22,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  widget.title,
                  style: AppTextStyles.regular.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
                Text(
                  _summary,
                  style: AppTextStyles.bold.copyWith(
                    color: AppColors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  CalendarDatePicker2Config _buildConfig(
    bool Function(DateTime day)? closedDayPredicate,
  ) {
    return CalendarDatePicker2Config(
      calendarType: widget.isMulti
          ? CalendarDatePicker2Type.multi
          : CalendarDatePicker2Type.single,
      currentDate: DateTime.now(),
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      selectedDayHighlightColor: AppColors.primary,
      daySplashColor: AppColors.primary.withValues(alpha: 0.2),
      selectableDayPredicate: closedDayPredicate == null
          ? null
          : (day) => !closedDayPredicate(day),
      modePickerTextHandler: ({required monthDate, bool? isMonthPicker}) {
        // แปลง header เป็นภาษาไทย (เดือน ปี พ.ศ.)
        final thaiMonth =
            DatePickerDialogCustom._thaiMonths[monthDate.month - 1];
        final buddhistYear = monthDate.year + 543;
        return (isMonthPicker ?? false) ? thaiMonth : '$buddhistYear';
      },
      monthBuilder:
          ({
            required int month,
            TextStyle? textStyle,
            BoxDecoration? decoration,
            bool? isDisabled,
            bool? isSelected,
            bool? isCurrentMonth,
          }) {
            // แสดงชื่อเดือนภาษาไทย
            return Center(
              child: Container(
                decoration: decoration,
                child: Text(
                  DatePickerDialogCustom._thaiMonths[month - 1],
                  style: textStyle,
                ),
              ),
            );
          },
      yearBuilder:
          ({
            required int year,
            BoxDecoration? decoration,
            TextStyle? textStyle,
            bool? isCurrentYear,
            bool? isDisabled,
            bool? isSelected,
          }) {
            // แปลงปี ค.ศ. เป็น พ.ศ.
            return Center(
              child: Container(
                decoration: decoration,
                child: Text('${year + 543}', style: textStyle),
              ),
            );
          },
      dayBuilder: closedDayPredicate == null
          ? null
          : ({
              required DateTime date,
              TextStyle? textStyle,
              BoxDecoration? decoration,
              bool? isSelected,
              bool? isDisabled,
              bool? isToday,
            }) {
              if (!closedDayPredicate(date)) return null;
              return Tooltip(
                message: 'หยุดให้บริการ',
                child: Center(child: _closedDayText('${date.day}')),
              );
            },
    );
  }

  Widget _closedDayText(String text) {
    return Text(
      text,
      style: AppTextStyles.regular.copyWith(
        color: AppColors.error,
        decoration: TextDecoration.lineThrough,
        decorationColor: AppColors.error,
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'ยกเลิก',
              style: AppTextStyles.regular.copyWith(color: AppColors.textLight),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop<List<DateTime?>>(_selected),
            child: Text(
              'ตกลง',
              style: AppTextStyles.regular.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
