import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/services/hospital_service.dart';
import 'package:rodzendai_form/core/utils/date_helper.dart';
import 'package:rodzendai_form/core/utils/time_picker.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/presentation/register/blocs/hospital_bloc/hospital_bloc.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_file_widget.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/dialog/date_picker.dart';
import 'package:rodzendai_form/widgets/dropdown_field_customer.dart';
import 'package:rodzendai_form/widgets/loading_widget.dart';
import 'package:rodzendai_form/widgets/text_form_field_custom.dart';

class FormAppointmentInfo extends StatelessWidget {
  const FormAppointmentInfo({super.key, required this.registerProvider});
  final RegisterProvider registerProvider;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HospitalBloc()..add(LoadHospitalsEvent()),
      child: BaseCardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            FormHeaderWidget(title: 'ข้อมูลการนัดหมาย'),
            // Display dynamic list of appointment fields
            ...List.generate(registerProvider.appointmentsList.length, (index) {
              final appointment = registerProvider.appointmentsList[index];
              final date = appointment['date'] as DateTime?;
              final time = appointment['time'] as TimeOfDay?;

              return Container(
                key: ValueKey(index),
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    if (registerProvider.appointmentsList.length > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'วันนัดหมายที่ ${index + 1}',
                            style: AppTextStyles.medium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            onPressed: () {
                              registerProvider.removeAppointment(index);
                            },
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    TextFormFielddCustom(
                      label: 'วันที่นัดหมาย',
                      hintText: 'วันที่นัดหมาย',
                      isReadOnly: true,
                      onTap: () async {
                        List<DateTime?>? results =
                            await DatePickerDialogCustom.show(
                              context,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 60),
                              ),
                              value: date == null ? [] : [date],
                            );
                        if (results == null || results.isEmpty) return;
                        registerProvider.setAppointmentDate(
                          index,
                          results.first!,
                        );
                      },
                      suffixIcon: Icon(Icons.calendar_today, size: 18),
                      controller: date == null
                          ? null
                          : TextEditingController(
                              text: DateHelper.dateTimeThaiDefault(
                                date.millisecondsSinceEpoch,
                              ),
                            ),
                      validator: Validators.required('กรุณาเลือกวันที่'),
                    ),
                    TextFormFielddCustom(
                      label: 'เวลาตามหมายนัด',
                      hintText: 'เวลาตามหมายนัด',
                      isRequired: true,
                      isReadOnly: true,
                      onTap: () async {
                        final selectedTime = await TimePickerHelper.selectTime(
                          context,
                        );
                        if (selectedTime == null) return;
                        registerProvider.setAppointmentTime(
                          index,
                          selectedTime,
                        );
                      },
                      suffixIcon: Icon(Icons.access_time, size: 18),
                      controller: time == null
                          ? null
                          : TextEditingController(
                              text:
                                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                            ),
                      validator: Validators.required('กรุณาเลือกเวลา'),
                    ),
                  ],
                ),
              );
            }),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    registerProvider.remainingDays <= 0
                        ? AppColors.grey
                        : AppColors.primary,
                  ),
                ),
                onPressed: registerProvider.remainingDays <= 0
                    ? null
                    : () {
                        registerProvider.addAppointment();
                      },
                icon: Icon(Icons.add, color: AppColors.white),
                label: Text(
                  'เพิ่มวันนัดหมาย',
                  style: AppTextStyles.regular.copyWith(color: AppColors.white),
                ),
              ),
            ),

            TextFormFielddCustom(
              label: 'วินิจฉัยโรค (รายละเอียดที่ต้องไปพบแพทย์)',
              controller: registerProvider.diagnosisController,
              isRequired: true,
              validator: Validators.required('กรุณากรอกข้อมูล'),
            ),
            TextFormFielddCustom(
              label: 'หมายเหตุการเดินทาง',
              hintText:
                  '(เช่น น้ำหนักเกิน อาศัยอยู่ที่พักสูง ซอยแคบ เข้าถึงผู้ป่วยลำบาก)',
              controller: registerProvider.transportNotesController,
              isRequired: true,
              maxLines: null,
              minLines: 3,
              validator: Validators.required('กรุณากรอกข้อมูล'),
            ),

            BlocBuilder<HospitalBloc, HospitalState>(
              builder: (context, state) {
                final isLoading = state is HospitalLoading;
                final hospitals = state is HospitalLoaded
                    ? state.filteredHospitals
                    : <HospitalData>[];
                final hasError = state is HospitalError;

                return DropdownFieldCustomer<String?>(
                  label: 'โรงพยาบาล/คลินิกปลายทาง',
                  isRequired: true,
                  showSearchBox: true,
                  isLoading: isLoading,
                  isEnabled: !hasError,
                  value: registerProvider.selectedHospital?.name,
                  hintText: isLoading
                      ? 'กำลังโหลดรายชื่อโรงพยาบาล...'
                      : hasError
                      ? 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง'
                      : 'โรงพยาบาล/คลินิกปลายทาง',
                  items: hospitals
                      .map(
                        (HospitalData? hospital) => DropdownMenuItem<String?>(
                          value: hospital?.name,
                          child: Text(
                            hospital?.name ?? '',
                            style: AppTextStyles.regular,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: isLoading
                      ? null
                      : (value) {
                          final selectedHospital = hospitals.firstWhereOrNull(
                            (hospital) => hospital.name == value,
                          );
                          registerProvider.setSelectedHospital(
                            selectedHospital,
                          );
                        },
                  validator: Validators.required(
                    'กรุณาเลือกโรงพยาบาล/คลินิกปลายทาง',
                  ),
                  suffixIcon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: LoadingWidget(),
                        )
                      : hasError
                      ? IconButton(
                          icon: const Icon(Icons.refresh, size: 18),
                          onPressed: () {
                            context.read<HospitalBloc>().add(
                              LoadHospitalsEvent(),
                            );
                          },
                        )
                      : const Icon(Icons.local_hospital, size: 18),
                );
              },
            ),
            BoxUploadFileWidget(
              initialValue: registerProvider.uploadedFile,
              onFilesSelected: (file) {
                registerProvider.setUploadedFile(file);
              },
              validator: (UploadedFile? file) {
                if (file == null) {
                  return 'กรุณาอัปโหลดไฟล์ใบนัดหมายแพทย์';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
