import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/core/utils/input_formatters.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/models/patient_response_model.dart';
import 'package:rodzendai_form/presentation/register/blocs/get_patient_bloc/get_patient_bloc.dart';
import 'package:rodzendai_form/presentation/register/dialogs/edit_current_address_dialog.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/radio_card_group.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/reg_v2_text_field.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';

/// Step 1 — ตรวจสอบสิทธิ์จากเลขบัตรประชาชน แล้วแสดงข้อมูลผู้ป่วยในระบบ
class StepPatientView extends StatelessWidget {
  const StepPatientView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterProvider>();
    final patient = provider.patientData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        const RegV2SectionHeader(
          icon: Icons.badge_outlined,
          title: 'ตรวจสอบสิทธิ์ผู้ป่วย',
          subtitle: 'กรอกเลขบัตรประชาชนของผู้ป่วยแล้วกด "ตรวจสอบข้อมูล"',
        ),
        _IdCardField(
          provider: provider,
          onCheck: () {
            final idCardNumber = provider.patientIdCardController.text.trim();
            log('Checking ID Card: $idCardNumber');
            context.read<GetPatientBloc>().add(
              GetPatientRequestEvent(idCardNumber),
            );
          },
        ),
        if (patient != null) ...[
          const Divider(height: 24),
          const RegV2SectionHeader(
            icon: Icons.person_outline_rounded,
            title: 'ข้อมูลผู้ป่วยในระบบ',
            subtitle:
                'ข้อมูลจากการลงทะเบียนรับสิทธิ์ แก้ไขได้เฉพาะที่อยู่ปัจจุบัน',
          ),
          _PatientSummary(provider: provider),
          const Divider(height: 24),
          const RegV2SectionHeader(
            icon: Icons.people_outline_rounded,
            title: 'ผู้ติดตามที่ลงทะเบียนไว้',
            subtitle:
                'นำไปใช้ในขั้นตอนผู้ติดตามได้ด้วยปุ่ม "ใช้ข้อมูลผู้ติดตาม"',
          ),
          _CompanionSummary(companion: patient.companion),
        ],
      ],
    );
  }
}

/// ช่องเลขบัตร + ปุ่มตรวจสอบ (เหมือนฟอร์มลงทะเบียนรับสิทธิ์ v2)
class _IdCardField extends StatelessWidget {
  const _IdCardField({required this.provider, required this.onCheck});

  final RegisterProvider provider;
  final VoidCallback onCheck;

  /// ตรวจแล้ว และเลขบัตรในช่องยังตรงกับผู้ป่วยที่ตรวจ
  bool get _checked {
    final patient = provider.patientData?.patient;
    if (patient == null) return false;
    return patient.idCardNumber == provider.patientIdCardController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final checked = _checked;

    final field = TextFormField(
      controller: provider.patientIdCardController,
      keyboardType: TextInputType.number,
      inputFormatters: InputFormatters.citizenId,
      style: RegV2Text.body.copyWith(letterSpacing: 1),
      decoration: InputDecoration(
        hintText: 'เลขบัตรประชาชน 13 หลัก',
        suffixIcon: checked
            ? const Icon(Icons.verified_rounded, color: RegV2Colors.positive)
            : null,
      ),
      validator: (value) =>
          Validators.validateIdCardNumber(value?.trim()) ??
          (checked ? null : 'กรุณากด "ตรวจสอบข้อมูล" ก่อนไปขั้นตอนถัดไป'),
    );

    final button = ValueListenableBuilder(
      valueListenable: provider.patientIdCardController,
      builder: (context, value, _) => SizedBox(
        height: 50,
        child: FilledButton.icon(
          onPressed: value.text.trim().length == 13 && !checked
              ? onCheck
              : null,
          icon: const Icon(Icons.search_rounded, size: 20),
          label: const Text('ตรวจสอบข้อมูล'),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        const RegV2FieldLabel(text: 'เลขประจำตัวประชาชน', fontSize: 16),
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 480
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Expanded(child: field),
                    button,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 10,
                  children: [field, button],
                ),
        ),
        if (checked)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: RegV2Colors.positiveSoft,
              borderRadius: BorderRadius.circular(RegV2Radius.input),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: RegV2Colors.positive,
                ),
                Flexible(
                  child: Text(
                    'ตรวจสอบแล้ว สามารถใช้บริการจองรถได้',
                    style: AppTextStyles.medium.copyWith(
                      fontSize: 14,
                      color: RegV2Colors.positive,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// การ์ดสรุปข้อมูลผู้ป่วยที่ดึงจากระบบ
class _PatientSummary extends StatelessWidget {
  const _PatientSummary({required this.provider});

  final RegisterProvider provider;

  String get _fullName {
    final patient = provider.patientData?.patient;
    return '${patient?.firstName ?? '-'} ${patient?.lastName ?? '-'}';
  }

  void _editCurrentAddress(BuildContext context) {
    final patientData = provider.patientData;
    if (patientData == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<GetLocationDetailBloc>(),
        child: EditCurrentAddressDialog(
          patientData: patientData,
          onSaved: () {
            // รีเฟรชข้อมูลผู้ป่วยหลังบันทึก
            context.read<GetPatientBloc>().add(
              GetPatientRequestEvent(
                provider.patientIdCardController.text.trim(),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = provider.patientData;
    final patient = data?.patient;
    final remainingRights = math.max(
      0,
      data?.remainingRights?.remainingRights ?? 0,
    );
    // โครงการที่ไม่จำกัดสิทธิ์ (maxUsage == 0) ไม่ต้องแสดงจำนวนคงเหลือ
    log(
      'Project: ${data?.projectInfo?.name}, maxUsage: ${data?.projectInfo?.maxUsage}, remainingRights: $remainingRights',
    );
    // แสดงเฉพาะโครงการที่จำกัดสิทธิ์: maxUsage ต้องมีค่าและมากกว่า 0
    // (null หรือ 0 = ไม่จำกัด)
    final maxUsage = data?.projectInfo?.maxUsage;
    final showRemainingRights = maxUsage != null && maxUsage > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RegV2Colors.background,
        borderRadius: BorderRadius.circular(RegV2Radius.card),
        border: Border.all(color: RegV2Colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'ชื่อ-นามสกุล', value: _fullName),
          _InfoRow(label: 'เบอร์โทรติดต่อ', value: patient?.phone),
          _InfoRow(label: 'Line ID', value: patient?.lineId?.toString()),
          _InfoRow(label: 'ประเภทผู้ป่วย', value: patient?.type),
          _InfoRow(
            label: 'ความสามารถในการเดินทาง',
            value: data?.transportation?.ability,
          ),
          _InfoRow(
            label: 'ที่อยู่ตามทะเบียนบ้าน',
            value: provider.getPatientAddress(),
          ),
          _InfoRow(
            label: 'ที่อยู่ปัจจุบัน',
            value: provider.getPatientCurrentAddress(),
            trailing: IconButton(
              icon: const Icon(
                Icons.edit_location_alt_outlined,
                size: 20,
                color: RegV2Colors.primary,
              ),
              tooltip: 'แก้ไขที่อยู่ปัจจุบัน',
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              onPressed: () => _editCurrentAddress(context),
            ),
          ),
          _InfoRow(
            label: 'Plus Code',
            value: data?.addresses?.current?.pickupPlusCode,
            emptyText: 'ไม่มีข้อมูล',
          ),
          _InfoRow(
            label: 'โครงการ',
            value: data?.projectInfo?.name,
            emptyText: 'ไม่มีข้อมูล',
            isLast: !showRemainingRights,
          ),
          if (showRemainingRights)
            _InfoRow(
              label: 'จำนวนสิทธิ์คงเหลือ',
              value: '$remainingRights ครั้ง',
              isLast: true,
            ),
        ],
      ),
    );
  }
}

/// การ์ดข้อมูลผู้ติดตามที่ลงทะเบียนไว้กับผู้ป่วย
class _CompanionSummary extends StatelessWidget {
  const _CompanionSummary({required this.companion});

  final Companion? companion;

  @override
  Widget build(BuildContext context) {
    final c = companion;
    final name = '${c?.firstName ?? ''} ${c?.lastName ?? ''}'.trim();
    final hasData =
        c != null && (name.isNotEmpty || (c.phone ?? '').trim().isNotEmpty);

    if (!hasData) {
      return const InfoBox(
        icon: Icons.person_off_outlined,
        text: 'ยังไม่มีข้อมูลผู้ติดตามที่ลงทะเบียนไว้ กรอกได้ในขั้นตอนที่ 3',
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RegV2Colors.background,
        borderRadius: BorderRadius.circular(RegV2Radius.card),
        border: Border.all(color: RegV2Colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'ชื่อ-นามสกุล', value: name),
          _InfoRow(label: 'ความสัมพันธ์', value: c.relation),
          _InfoRow(label: 'เบอร์โทรติดต่อ', value: c.phone),
          _InfoRow(
            label: 'เลขบัตรประชาชน',
            value: c.idCardNumber,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.trailing,
    this.emptyText = '-',
    this.isLast = false,
  });

  final String label;
  final String? value;
  final Widget? trailing;
  final String emptyText;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final text = (value ?? '').trim().isEmpty ? emptyText : value!;
    final labelWidget = Text(
      label,
      style: AppTextStyles.regular.copyWith(
        fontSize: 14,
        color: RegV2Colors.textMuted,
      ),
    );
    final valueWidget = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Expanded(
          child: SelectableText(
            text,
            style: AppTextStyles.medium.copyWith(
              fontSize: 16,
              height: 1.4,
              color: RegV2Colors.text,
            ),
          ),
        ),
        ?trailing,
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth >= 520
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 190,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: labelWidget,
                        ),
                      ),
                      Expanded(child: valueWidget),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [labelWidget, valueWidget],
                  ),
          ),
        ),
        if (!isLast) const Divider(height: 1, color: RegV2Colors.divider),
      ],
    );
  }
}
