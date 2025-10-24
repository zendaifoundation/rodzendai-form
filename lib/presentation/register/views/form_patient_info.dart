import 'dart:developer';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/date_helper.dart';
import 'package:rodzendai_form/core/utils/input_formatters.dart';
import 'package:rodzendai_form/core/utils/time_picker.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/presentation/register/blocs/get_patient_bloc/get_patient_bloc.dart';
import 'package:rodzendai_form/presentation/register/blocs/hospital_bloc/hospital_bloc.dart';
import 'package:rodzendai_form/presentation/register/interfaces/patient_type.dart';
import 'package:rodzendai_form/presentation/register/interfaces/transport_ability.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_file_widget.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/responsive.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';
import 'package:rodzendai_form/widgets/divider_widget.dart';
import 'package:rodzendai_form/widgets/dropdown_field_customer.dart';
import 'package:rodzendai_form/widgets/loading_widget.dart';
import 'package:rodzendai_form/widgets/radio_group_field.dart';
import 'package:rodzendai_form/widgets/text_form_field_custom.dart';

//รายละเอียดผู้ป่วย
class FormPatientInfo extends StatelessWidget {
  const FormPatientInfo({
    super.key,
    required this.registerProvider,
    required this.getPatientBloc,
  });
  final RegisterProvider registerProvider;
  final GetPatientBloc getPatientBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HospitalBloc()..add(LoadHospitalsEvent()),
      child: _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    return BaseCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          FormHeaderWidget(title: 'รายละเอียดผู้ป่วย'),
          _buildCheckIdCardNumber(context),
          if (registerProvider.patientData != null) ...[
            DividerCustom(),
            _buildPatientInfoRow(
              label: 'ชื่อ-นามสกุล ผู้ป่วย: ',
              value: _getPatientFullName(),
            ),
            _buildPatientInfoRow(
              label: 'เบอร์โทรติดต่อ: ',
              value: registerProvider.patientData?.patient?.phone ?? '-',
            ),
            _buildPatientInfoRow(
              label: 'Line ID: ',
              value: registerProvider.patientData?.patient?.lineId ?? '-',
            ),
            _buildPatientInfoRow(
              label: 'ประเภทผู้ป่วย: ',
              value: registerProvider.patientData?.patient?.type ?? '-',
            ),
            _buildPatientInfoRow(
              label: 'ความสามารถในการเดินทาง: ',
              value:
                  registerProvider.patientData?.patient?.mobilityAbility ?? '-',
            ),
            _buildPatientInfoRow(
              label: 'ที่อยู่: ',
              value: _getPatientAddress(),
            ),
          ],

          // TextFormFielddCustom(
          //   label: 'หมายเลขบัตรประชาชน',
          //   controller: registerProvider.patientIdCardController,
          //   isRequired: true,
          //   inputFormatters: InputFormatters.citizenId,
          //   keyboardType: TextInputType.number,
          //   validator: (value) {
          //     return Validators.validateIdCardNumber(value);
          //   },
          // ),

          // TextFormFielddCustom(
          //   label: 'ชื่อ-นามสกุล ผู้ป่วย',
          //   isRequired: true,
          //   controller: registerProvider.patientNameController,
          //   validator: Validators.required('กรุณากรอกข้อมูล'),
          // ),
          // TextFormFielddCustom(
          //   label: 'เบอร์โทรติดต่อ',
          //   isRequired: true,
          //   controller: registerProvider.patientPhoneController,
          //   keyboardType: TextInputType.phone,
          //   inputFormatters: InputFormatters.phone,
          //   validator: Validators.required('กรุณากรอกข้อมูล'),
          // ),

          // TextFormFielddCustom(
          //   label: 'Line ID (ถ้ามี)',
          //   isRequired: false,
          //   controller: registerProvider.patientLineIdController,
          // ),
          // RadioGroupField<PatientType>(
          //   key: ValueKey(registerProvider.patientTypeSelected),
          //   label: 'ประเภทผู้ป่วย',
          //   isRequired: true,
          //   value: registerProvider.patientTypeSelected,
          //   options: PatientType.values
          //       .map((type) => RadioOption(value: type, label: type.value))
          //       .toList(),
          //   onChanged: (value) {
          //     registerProvider.setPatientTypeSelected(value);
          //   },
          //   validator: (value) {
          //     if (value == null) {
          //       return 'กรุณาเลือกประเภทผู้ป่วย';
          //     }
          //     return null;
          //   },
          // ),

          // RadioGroupField<TransportAbility>(
          //   key: ValueKey(registerProvider.transportAbilitySelected),
          //   label: 'ความสามารถในการเดินทาง',
          //   isRequired: true,
          //   value: registerProvider.transportAbilitySelected,
          //   options: TransportAbility.values
          //       .map(
          //         (ability) =>
          //             RadioOption(value: ability, label: ability.value),
          //       )
          //       .toList(),
          //   onChanged: (value) {
          //     registerProvider.setTransportAbilitySelected(value);
          //   },
          //   validator: (value) {
          //     if (value == null) {
          //       return 'กรุณาเลือกความสามารถในการเดินทาง';
          //     }
          //     return null;
          //   },
          // ),
          // TextFormFielddCustom(
          //   label: 'วันที่นัดหมาย',
          //   hintText: 'วันที่นัดหมาย',
          //   isReadOnly: true,
          //   onTap: () async {
          //     var results = await showCalendarDatePicker2Dialog(
          //       context: context,
          //       config: CalendarDatePicker2WithActionButtonsConfig(
          //         selectedDayHighlightColor: AppColors.primary,
          //         daySplashColor: AppColors.primary.withOpacity(0.2),
          //         currentDate: DateTime.now(),
          //         firstDate: DateTime.now(),
          //         lastDate: DateTime.now().add(Duration(days: 365)),
          //         calendarType: CalendarDatePicker2Type.single,
          //         okButtonTextStyle: AppTextStyles.regular.copyWith(
          //           color: AppColors.primary,
          //         ),
          //         cancelButtonTextStyle: AppTextStyles.regular,
          //         okButton: Text(
          //           'ตกลง',
          //           style: AppTextStyles.regular.copyWith(
          //             color: AppColors.primary,
          //           ),
          //         ),
          //         cancelButton: Text(
          //           'ยกเลิก',
          //           style: AppTextStyles.regular.copyWith(
          //             color: AppColors.textLight,
          //           ),
          //         ),
          //       ),
          //       dialogSize: const Size(325, 400),
          //       value: registerProvider.appointmentDateSelected == null
          //           ? []
          //           : [registerProvider.appointmentDateSelected],
          //       //value: [_selectedDate],
          //       borderRadius: BorderRadius.circular(8),
          //       dialogBackgroundColor: AppColors.white,
          //     );
          //     if (results == null || results.isEmpty) return;
          //     registerProvider.setAppointmentDate(results.first!);
          //   },
          //   suffixIcon: Icon(Icons.calendar_today, size: 18),
          //   controller: registerProvider.appointmentDateSelected == null
          //       ? null
          //       : TextEditingController(
          //           text: DateHelper.dateTimeThaiDefault(
          //             registerProvider
          //                 .appointmentDateSelected
          //                 ?.millisecondsSinceEpoch,
          //           ),
          //         ),
          //   validator: Validators.required('กรุณาเลือกวันที่'),
          // ),
          // TextFormFielddCustom(
          //   label: 'เวลาตามหมายนัด',
          //   hintText: 'เวลาตามหมายนัด',
          //   isRequired: true,
          //   isReadOnly: true,
          //   onTap: () async {
          //     final selectedTime = await TimePickerHelper.selectTime(
          //       context,
          //       initialTime: registerProvider.appointmentTimeSelected,
          //     );
          //     if (selectedTime == null) return;
          //     registerProvider.setAppointmentTime(selectedTime);
          //   },
          //   suffixIcon: Icon(Icons.access_time, size: 18),
          //   controller: registerProvider.appointmentTimeSelected == null
          //       ? null
          //       : TextEditingController(
          //           text:
          //               '${registerProvider.appointmentTimeSelected!.hour.toString().padLeft(2, '0')}:${registerProvider.appointmentTimeSelected!.minute.toString().padLeft(2, '0')}',
          //         ),
          //   validator: Validators.required('กรุณาเลือกเวลา'),
          // ),

          // BlocBuilder<HospitalBloc, HospitalState>(
          //   builder: (context, state) {
          //     final isLoading = state is HospitalLoading;
          //     final hospitals = state is HospitalLoaded
          //         ? state.filteredHospitals
          //         : <String>[];
          //     final hasError = state is HospitalError;

          //     return DropdownFieldCustomer<String>(
          //       label: 'โรงพยาบาล/คลินิกปลายทาง',
          //       isRequired: true,
          //       showSearchBox: true,
          //       isLoading: isLoading,
          //       isEnabled: !hasError,
          //       value: registerProvider.selectedHospital,
          //       hintText: isLoading
          //           ? 'กำลังโหลดรายชื่อโรงพยาบาล...'
          //           : hasError
          //           ? 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง'
          //           : 'โรงพยาบาล/คลินิกปลายทาง',
          //       items: hospitals
          //           .map(
          //             (hospital) => DropdownMenuItem<String>(
          //               value: hospital,
          //               child: Text(
          //                 hospital,
          //                 style: AppTextStyles.regular,
          //                 overflow: TextOverflow.ellipsis,
          //                 maxLines: 1,
          //               ),
          //             ),
          //           )
          //           .toList(),
          //       onChanged: isLoading
          //           ? null
          //           : (value) {
          //               registerProvider.setSelectedHospital(value);
          //             },
          //       validator: Validators.required(
          //         'กรุณาเลือกโรงพยาบาล/คลินิกปลายทาง',
          //       ),
          //       suffixIcon: isLoading
          //           ? const SizedBox(
          //               width: 18,
          //               height: 18,
          //               child: LoadingWidget(),
          //             )
          //           : hasError
          //           ? IconButton(
          //               icon: const Icon(Icons.refresh, size: 18),
          //               onPressed: () {
          //                 context.read<HospitalBloc>().add(
          //                   LoadHospitalsEvent(),
          //                 );
          //               },
          //             )
          //           : const Icon(Icons.local_hospital, size: 18),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildCheckIdCardNumber(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [_buildIdCardNumber(), _buildButtonCheck(context)],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 16,
      children: [
        Expanded(child: _buildIdCardNumber()),
        _buildButtonCheck(context),
      ],
    );
  }

  _buildButtonCheck(context) {
    return SizedBox(
      height: 48,
      child: ButtonCustom(
        // key: ValueKey(
        //   registerProvider.patientIdCardController.text.trim(),
        // ),
        text: 'ตรวจสอบข้อมูล',
        //isLoading: state is DataPatientLoading,
        onPressed: () async {
          String idCardNumber = registerProvider.patientIdCardController.text
              .trim();
          log('Checking ID Card: $idCardNumber');
          getPatientBloc.add(GetPatientRequestEvent(idCardNumber));

          // _checkEligibilityBloc.add(
          //   CheckEligibilityRequestEvent(
          //     idCardNumber: idCardNumber,
          //   ),
          // );
        },
      ),
    );
  }

  TextFormFielddCustom _buildIdCardNumber() {
    return TextFormFielddCustom(
      label: 'หมายเลขบัตรประชาชน',
      hintText: 'เลขบัตรประชาชน 13 หลัก',
      controller: registerProvider.patientIdCardController,
      isRequired: true,
      inputFormatters: InputFormatters.citizenId,
      keyboardType: TextInputType.number,
      validator: (value) {
        return Validators.validateIdCardNumber(value);
      },
    );
  }

  Widget _buildPatientInfoRow({required String label, required String value}) {
    return Row(
      spacing: 8,
      children: [
        Text(label, style: AppTextStyles.bold.copyWith(fontSize: 14)),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.regular.copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }

  String _getPatientFullName() {
    final firstName = registerProvider.patientData?.patient?.firstName ?? '-';
    final lastName = registerProvider.patientData?.patient?.lastName ?? '-';
    return '$firstName $lastName';
  }

  String _getPatientAddress() {
    final address = registerProvider.patientData?.addresses?.registered;
    if (address == null) {
      return '-';
    }
    return '${address.address ?? ''} ตำบล${address.subDistrict ?? '-'} อำเภอ${address.district ?? '-'} จังหวัด${address.province ?? '-'}';
  }
}
