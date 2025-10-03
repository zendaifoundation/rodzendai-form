import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/utils/date_helper.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_file_widget.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/text_form_field_customer.dart';

//รายละเอียดผู้ป่วย
class FormPatientInfo extends StatelessWidget {
  const FormPatientInfo({super.key, required this.registerProvider});
  final RegisterProvider registerProvider;

  @override
  Widget build(BuildContext context) {
    return BaseCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          FormHeaderWidget(title: 'รายละเอียดผู้ป่วย'),

          TextFormFielddCustom(label: 'หมายเลขบัตรประชาชน', isRequired: true),
          TextFormFielddCustom(label: 'ชื่อ-นามสกุล ผู้ป่วย', isRequired: true),
          TextFormFielddCustom(label: 'เบอร์โทรติดต่อ', isRequired: true),
          TextFormFielddCustom(label: 'Line ID (ถ้ามี)', isRequired: false),

          //TextFormFielddCustom(label: 'ประเภทผู้ป่วย', isRequired: false),
          TextFormFielddCustom(
            label: 'วันที่นัดหมาย',
            hintText: 'เลือกวันที่นัดหมาย',
            isReadOnly: true,
            onTap: () async {
              var results = await showCalendarDatePicker2Dialog(
                context: context,
                config: CalendarDatePicker2WithActionButtonsConfig(
                  selectedDayHighlightColor: AppColors.primary,
                  daySplashColor: AppColors.primary.withOpacity(0.2),
                ),
                dialogSize: const Size(325, 400),

                //value: [_selectedDate],
                borderRadius: BorderRadius.circular(8),
                dialogBackgroundColor: AppColors.white,
              );
              if (results == null) return;
              // setState(() {
              //   _selectedDate = results.first;
              // });
            },
            suffixIcon: Icon(Icons.calendar_today, size: 18),
            controller: TextEditingController(
              text: DateHelper.dateTimeThaiDefault(null),
            ),
            validator: Validators.validateTravelDate,
          ),
          TextFormFielddCustom(
            label: 'เวลาตามหมายนัด',
            hintText: 'เลือกเวลาตามหมายนัด',
            isReadOnly: true,
            onTap: () async {
              //todo
            },
            suffixIcon: Icon(Icons.calendar_today, size: 18),
            controller: TextEditingController(
              text: DateHelper.dateTimeThaiDefault(null),
            ),
            validator: Validators.validateTravelDate,
          ),

          TextFormFielddCustom(
            label: 'โรงพยาบาล/คลินิกปลายทาง',
            isRequired: true,
          ),
          TextFormFielddCustom(
            label: 'วินิจฉัยโรค (รายละเอียดที่ต้องไปพบแพทย์)',
            isRequired: true,
          ),
          TextFormFielddCustom(
            label:
                'หมายเหตุการเดินทาง (เช่น น้ำหนักเกิน อาศัยอยู่ที่พักสูง ซอยแคบ เข้าถึงผู้ป่วยลำบาก)',
            isRequired: true,
            maxLines: null,
            minLines: 3,
          ),

          BoxUploadFileWidget(),
        ],
      ),
    );
  }
}
