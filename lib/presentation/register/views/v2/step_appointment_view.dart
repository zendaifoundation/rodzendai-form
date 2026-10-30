import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/services/auth_service.dart';
import 'package:rodzendai_form/core/services/hospital_service.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/core/utils/closed_date_helper.dart';
import 'package:rodzendai_form/core/utils/date_helper.dart';
import 'package:rodzendai_form/core/utils/time_picker.dart';
import 'package:rodzendai_form/core/utils/toast_helper.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/models/closed_date_range.dart';
import 'package:rodzendai_form/models/project_model.dart';
import 'package:rodzendai_form/presentation/register/blocs/hospital_bloc/hospital_bloc.dart';
import 'package:rodzendai_form/presentation/register/blocs/project_bloc/project_bloc.dart';
import 'package:rodzendai_form/presentation/register/interfaces/diagnosis_options.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register/views/v2/trip_details_section.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_file_widget.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/radio_card_group.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/reg_v2_text_field.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';
import 'package:rodzendai_form/widgets/dialog/date_picker.dart';
import 'package:rodzendai_form/widgets/dropdown_field_customer.dart';
import 'package:rodzendai_form/widgets/loading_widget.dart';

/// Step 2 — วินิจฉัย วัน/เวลานัดหมาย หมายเหตุ รายละเอียดการเดินทาง โรงพยาบาล และใบนัดแพทย์
///
/// ต้องมี [HospitalBloc] และ [ProjectBloc] อยู่เหนือ widget นี้
class StepAppointmentView extends StatelessWidget {
  const StepAppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterProvider>();
    final isAdmin = locator<AuthService>().loginSource == 'admin';

    // วันปิดของโครงการ: admin เลือกโครงการเองได้ จึงยึดโครงการที่เลือกก่อน
    final projectClosedDates =
        provider.selectedProject?.closedDates ??
        provider.patientData?.projectInfo?.closedDates ??
        const <ClosedDateRange>[];
    bool isClosed(DateTime day) =>
        ClosedDateHelper.isClosed(day, projectClosedDates: projectClosedDates);

    Future<void> pickDates() async {
      final allDates = provider.appointmentsList
          .map((a) => a['date'] as DateTime?)
          .whereType<DateTime>()
          .toList();
      final results = await DatePickerDialogCustom.showThai(
        context,
        firstDate: DateTime(2025, 11, 1),
        value: allDates,
        isMulti: true,
        title: 'เลือกวันที่นัดหมาย',
        closedDayPredicate: isClosed,
      );
      if (results == null || results.isEmpty) return;
      final validDates = results.whereType<DateTime>().toList();
      if (validDates.isEmpty) return;
      if (validDates.any(isClosed)) {
        if (!context.mounted) return;
        ToastHelper.showWarning(
          context: context,
          title: 'วันที่เลือกเป็นวันหยุดให้บริการ',
          description: 'กรุณาเลือกวันนัดหมายอื่น',
        );
        return;
      }
      provider.setAppointmentsFromDates(validDates);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        const RegV2SectionHeader(
          icon: Icons.medical_information_outlined,
          title: 'วินิจฉัยโรค',
          subtitle: 'รายละเอียดที่ต้องไปพบแพทย์',
        ),
        _DiagnosisDropdown(provider: provider),

        const Divider(height: 24),
        const RegV2SectionHeader(
          icon: Icons.event_outlined,
          title: 'วันและเวลานัดหมาย',
          subtitle: 'เลือกได้หลายวัน กำหนดเวลาแยกแต่ละวัน',
        ),
        for (var i = 0; i < provider.appointmentsList.length; i++)
          _AppointmentCard(
            key: ValueKey('appointment_$i'),
            index: i,
            date: provider.appointmentsList[i]['date'] as DateTime?,
            time: provider.appointmentsList[i]['time'] as TimeOfDay?,
            showDelete: provider.appointmentsList.length > 1,
            onPickDate: pickDates,
            onPickTime: () async {
              final selectedTime = await TimePickerHelper.selectTime(context);
              if (selectedTime == null) return;
              provider.setAppointmentTime(i, selectedTime);
            },
            onDelete: () => provider.removeAppointment(i),
          ),
        RegV2TextField(
          label: 'หมายเหตุการเดินทาง',
          controller: provider.transportNotesController,
          hintText:
              'เช่น น้ำหนักเกิน อาศัยอยู่ที่พักสูง ซอยแคบ เข้าถึงผู้ป่วยลำบาก',
          minLines: 3,
          maxLines: 5,
          validator: Validators.required('กรุณากรอกข้อมูล'),
        ),

        const Divider(height: 24),
        const RegV2SectionHeader(
          icon: Icons.local_hospital_outlined,
          title: 'โรงพยาบาล/คลินิกปลายทาง',
          subtitle:
              'เลือกแล้วระบบเติมที่อยู่ฝั่งโรงพยาบาลในรายละเอียดการเดินทางด้านล่างให้',
        ),
        if (isAdmin) _ProjectDropdown(provider: provider),
        _HospitalDropdown(provider: provider),

        const Divider(height: 24),
        const TripDetailsSection(),

        const Divider(height: 24),
        const RegV2SectionHeader(
          icon: Icons.upload_file_outlined,
          title: 'ใบนัดหมายแพทย์',
          subtitle: 'รองรับไฟล์ PDF / JPG / PNG',
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            const RegV2FieldLabel(text: 'ไฟล์ใบนัดหมายแพทย์', fontSize: 16),
            BoxUploadFileWidget(
              labelText: 'อัปโหลดใบนัดหมายแพทย์',
              initialValue: provider.uploadedFile,
              isRequired: true,
              onFilesSelected: provider.setUploadedFile,
              validator: (file) =>
                  file == null ? 'กรุณาอัปโหลดไฟล์ใบนัดหมายแพทย์' : null,
            ),
          ],
        ),
      ],
    );
  }
}

/// วินิจฉัยโรคแบบ dropdown + ช่องระบุเองเมื่อเลือก "อื่น ๆ"
class _DiagnosisDropdown extends StatelessWidget {
  const _DiagnosisDropdown({required this.provider});

  final RegisterProvider provider;

  @override
  Widget build(BuildContext context) {
    final selected = provider.diagnosisOption;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            const RegV2FieldLabel(text: 'วินิจฉัยโรค', fontSize: 16),
            DropdownButtonFormField<String>(
              key: ValueKey(selected),
              initialValue: selected,
              isExpanded: true,
              hint: Text(
                'เลือกการวินิจฉัย/เหตุผลที่ไปพบแพทย์',
                style: RegV2Text.caption,
              ),
              style: RegV2Text.body,
              borderRadius: BorderRadius.circular(RegV2Radius.tile),
              items: [
                for (final option in DiagnosisOptions.values)
                  DropdownMenuItem(value: option, child: Text(option)),
              ],
              onChanged: provider.setDiagnosisOption,
              validator: (value) =>
                  value == null ? 'กรุณาเลือกวินิจฉัยโรค' : null,
            ),
          ],
        ),
        if (selected == DiagnosisOptions.other)
          RegV2TextField(
            label: 'ระบุวินิจฉัยโรค',
            controller: provider.diagnosisOtherController,
            hintText: 'เช่น นัดฉีดยา นัดเปลี่ยนสายให้อาหาร',
            onChanged: (_) => provider.syncDiagnosisOther(),
            validator: Validators.required('กรุณาระบุวินิจฉัยโรค'),
          ),
      ],
    );
  }
}

/// การ์ดวันนัดหมาย 1 วัน (วันที่ + เวลา)
class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    super.key,
    required this.index,
    required this.date,
    required this.time,
    required this.showDelete,
    required this.onPickDate,
    required this.onPickTime,
    required this.onDelete,
  });

  final int index;
  final DateTime? date;
  final TimeOfDay? time;
  final bool showDelete;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateText = date == null
        ? null
        : DateHelper.dateTimeThaiDefault(date!.millisecondsSinceEpoch)
              as String;
    final timeText = time == null
        ? null
        : DateHelper.formatTime(time) as String;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RegV2Colors.background,
        borderRadius: BorderRadius.circular(RegV2Radius.card),
        border: Border.all(color: RegV2Colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'วันนัดหมายที่ ${index + 1}',
                  style: RegV2Text.sectionTitle.copyWith(fontSize: 16),
                ),
              ),
              if (showDelete)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: RegV2Colors.negative,
                    size: 20,
                  ),
                  tooltip: 'ลบวันนัดหมาย',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDelete,
                ),
            ],
          ),
          RegV2FieldRow(
            children: [
              _PickerField(
                label: 'วันที่นัดหมาย',
                value: dateText,
                hintText: 'เลือกวันที่',
                icon: Icons.calendar_today_rounded,
                onTap: onPickDate,
                requiredMessage: 'กรุณาเลือกวันที่',
              ),
              _PickerField(
                label: 'เวลาตามหมายนัด',
                value: timeText,
                hintText: 'เลือกเวลา',
                icon: Icons.access_time_rounded,
                onTap: onPickTime,
                requiredMessage: 'กรุณาเลือกเวลา',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ช่องอ่านอย่างเดียวที่เปิด picker เมื่อแตะ
class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.hintText,
    required this.icon,
    required this.onTap,
    required this.requiredMessage,
  });

  final String label;
  final String? value;
  final String hintText;
  final IconData icon;
  final VoidCallback onTap;
  final String requiredMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        RegV2FieldLabel(text: label, fontSize: 16),
        TextFormField(
          // key เปลี่ยนตามค่า ให้ initialValue ใหม่มีผล
          key: ValueKey(value),
          initialValue: value ?? '',
          readOnly: true,
          onTap: onTap,
          style: RegV2Text.body,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: Icon(icon, size: 18),
          ),
          validator: (text) =>
              (text ?? '').trim().isEmpty ? requiredMessage : null,
        ),
      ],
    );
  }
}

/// โครงการ (เฉพาะ admin) — ค่าเริ่มต้นตามโครงการของผู้ป่วย
class _ProjectDropdown extends StatelessWidget {
  const _ProjectDropdown({required this.provider});

  final RegisterProvider provider;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectBloc, ProjectState>(
      listenWhen: (prev, curr) => curr is ProjectLoaded,
      listener: (context, state) {
        if (state is! ProjectLoaded) return;
        if (provider.selectedProject != null) return;

        final defaultName = provider.patientData?.projectInfo?.name;
        final defaultId = provider.patientData?.projectInfo?.id;
        if (defaultName == null && defaultId == null) return;

        final match = state.projects.firstWhereOrNull(
          (p) =>
              (defaultId != null && p.id == defaultId) ||
              (defaultName != null && p.name == defaultName),
        );
        if (match != null) provider.setSelectedProject(match);
      },
      builder: (context, state) {
        final isLoading = state is ProjectLoading;
        final hasError = state is ProjectError;
        final projects = state is ProjectLoaded
            ? state.projects
            : <ProjectModel>[];

        return DropdownFieldCustomer<String?>(
          label: 'โครงการ',
          isRequired: true,
          showSearchBox: true,
          isLoading: isLoading,
          isEnabled: !hasError,
          value: provider.selectedProject?.id,
          hintText: isLoading
              ? 'กำลังโหลดรายการโครงการ...'
              : hasError
              ? 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง'
              : 'เลือกโครงการ',
          items: projects
              .map(
                (project) => DropdownMenuItem<String?>(
                  value: project.id,
                  child: Text(
                    project.name,
                    style: AppTextStyles.regular,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              )
              .toList(),
          onChanged: isLoading
              ? null
              : (value) => provider.setSelectedProject(
                  projects.firstWhereOrNull((p) => p.id == value),
                ),
          validator: Validators.required('กรุณาเลือกโครงการ'),
          suffixIcon: isLoading
              ? const SizedBox(width: 18, height: 18, child: LoadingWidget())
              : hasError
              ? IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: () =>
                      context.read<ProjectBloc>().add(LoadProjectsEvent()),
                )
              : const Icon(Icons.folder_outlined, size: 18),
        );
      },
    );
  }
}

/// โรงพยาบาล/คลินิกปลายทาง (ค้นหาได้)
class _HospitalDropdown extends StatelessWidget {
  const _HospitalDropdown({required this.provider});

  final RegisterProvider provider;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HospitalBloc, HospitalState>(
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
          value: provider.selectedHospital?.name,
          hintText: isLoading
              ? 'กำลังโหลดรายชื่อโรงพยาบาล...'
              : hasError
              ? 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง'
              : 'ค้นหาโรงพยาบาล/คลินิกปลายทาง',
          items: hospitals
              .map(
                (hospital) => DropdownMenuItem<String?>(
                  value: hospital.name,
                  child: Text(
                    hospital.displayName,
                    style: AppTextStyles.regular,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              )
              .toList(),
          onChanged: isLoading
              ? null
              : (value) => provider.setSelectedHospital(
                  hospitals.firstWhereOrNull((h) => h.name == value),
                ),
          validator: Validators.required('กรุณาเลือกโรงพยาบาล/คลินิกปลายทาง'),
          suffixIcon: isLoading
              ? const SizedBox(width: 18, height: 18, child: LoadingWidget())
              : hasError
              ? IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: () =>
                      context.read<HospitalBloc>().add(LoadHospitalsEvent()),
                )
              : const Icon(Icons.local_hospital_outlined, size: 18),
        );
      },
    );
  }
}
