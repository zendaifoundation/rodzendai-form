import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';

class DatePickerDialogCustom {
  static Future<List<DateTime?>?> show(
    BuildContext context, {
    List<DateTime?>? value,
  }) async {
    // Implement your date picker dialog logic here
    final result = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        selectedDayHighlightColor: AppColors.primary,
        daySplashColor: AppColors.primary.withOpacity(0.2),
        currentDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 365)),
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
}
