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

  static Future<List<DateTime?>?> showThai(
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
        modePickerTextHandler: ({required monthDate, bool? isMonthPicker}) {
          // แปลง header เป็นภาษาไทย (เดือน ปี พ.ศ.)
          final thaiMonth = _thaiMonths[monthDate.month - 1];
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
                  child: Text(_thaiMonths[month - 1], style: textStyle),
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
              final buddhistYear = year + 543;
              return Center(
                child: Container(
                  decoration: decoration,
                  child: Text(buddhistYear.toString(), style: textStyle),
                ),
              );
            },
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
}
