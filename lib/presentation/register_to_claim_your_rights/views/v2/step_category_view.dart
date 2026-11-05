import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/presentation/register/interfaces/patient_type.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_multi_file_widget.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/interfaces/register_v2_options.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_v2_provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/choice_card_group.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/radio_card_group.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';

/// Step 1 — เลือกประเภทผู้ป่วย (การ์ด 3 ใบ) และคำถามย่อยตามกลุ่ม
class StepCategoryView extends StatelessWidget {
  const StepCategoryView({super.key});

  static const _icons = {
    PatientType.elderly: Icons.elderly_rounded,
    PatientType.disabled: Icons.accessible_rounded,
    PatientType.hardship: Icons.volunteer_activism_rounded,
  };

  static const _summaries = {
    PatientType.elderly:
        'อายุ 60 ปีขึ้นไป และขาดผู้ดูแลหรือญาติที่ช่วยเหลือได้',
    PatientType.disabled:
        'มีความจำเป็นพิเศษที่ต้องได้รับความช่วยเหลือในชีวิตประจำวัน',
    PatientType.hardship:
        'มีข้อจำกัดด้านสุขภาพ การเดินทาง ฐานะ หรือต้องการการดูแลพิเศษ',
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterToClaimYourRightsV2Provider>();
    final patientType = provider.patientType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 28,
      children: [
        ChoiceCardGroup<PatientType>(
          label: 'เลือกประเภทผู้ป่วย',
          description: 'เลือกกลุ่มที่ตรงกับผู้ป่วยมากที่สุด 1 กลุ่ม',
          requiredMessage: 'กรุณาเลือกประเภทผู้ป่วย',
          value: patientType,
          onChanged: provider.setPatientType,
          options: [
            for (final type in PatientType.values)
              ChoiceCardOption(
                value: type,
                title: type.titleV2,
                summary: _summaries[type]!,
                icon: _icons[type]!,
              ),
          ],
        ),
        if (patientType != null)
          _SubSection(
            key: ValueKey(patientType),
            child: switch (patientType) {
              PatientType.disabled => _DisabledSection(provider),
              PatientType.elderly => _ElderlySection(provider),
              PatientType.hardship => _DifficultySection(provider),
            },
          ),
      ],
    );
  }
}

/// กรอบของคำถามย่อยหลังเลือกกลุ่ม
class _SubSection extends StatelessWidget {
  const _SubSection({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RegV2Colors.background,
        borderRadius: BorderRadius.circular(RegV2Radius.card),
        border: Border.all(color: RegV2Colors.border),
      ),
      child: child,
    );
  }
}

// -----------------------------------------------------------------------------
// คำถามย่อยตามกลุ่ม
// -----------------------------------------------------------------------------

class _DisabledSection extends StatelessWidget {
  const _DisabledSection(this.provider);

  final RegisterToClaimYourRightsV2Provider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        InfoBox(text: PatientType.disabled.definition!),
        RadioCardGroup<DisabilityType>(
          label: 'เลือกประเภทความพิการ',
          value: provider.disabilityType,
          onChanged: provider.setDisabilityType,
          options: [
            for (final type in DisabilityType.values)
              RadioCardOption(value: type, label: type.label),
          ],
        ),
      ],
    );
  }
}

class _ElderlySection extends StatelessWidget {
  const _ElderlySection(this.provider);

  final RegisterToClaimYourRightsV2Provider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        InfoBox(text: PatientType.elderly.definition!),
        RadioCardGroup<ElderlyCondition>(
          label: 'เลือกภาวะหลัก 1 ข้อ',
          description:
              'ผู้สูงอายุต้องทำแบบประเมินกิจวัตรประจำวัน (ADL) ในขั้นตอนที่ 7',
          value: provider.elderlyCondition,
          onChanged: provider.setElderlyCondition,
          options: [
            for (final condition in ElderlyCondition.values)
              RadioCardOption(value: condition, label: condition.label),
          ],
        ),
      ],
    );
  }
}

class _DifficultySection extends StatelessWidget {
  const _DifficultySection(this.provider);

  final RegisterToClaimYourRightsV2Provider provider;

  @override
  Widget build(BuildContext context) {
    final reason = provider.difficultyReason;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 28,
      children: [
        RadioCardGroup<DifficultyReason>(
          label: 'เลือกสาเหตุหลักของความยากลำบาก',
          value: reason,
          onChanged: provider.setDifficultyReason,
          options: [
            for (final r in DifficultyReason.values)
              RadioCardOption(value: r, label: r.label),
          ],
        ),
        if (reason != null)
          switch (reason) {
            DifficultyReason.health => _DetailsField(
              key: const ValueKey('health_details'),
              controller: provider.healthDetailsController,
              title: 'รายละเอียดข้อจำกัดด้านสุขภาพ',
              hint: 'อธิบายข้อจำกัดหรือปัญหาสุขภาพ และผลต่อการเดินทาง',
              example:
                  'เช่น เดินได้ระยะสั้น ต้องมีคนช่วยพยุง หรือมีปัญหาสุขภาพ'
                  'ที่ทำให้เดินทางไปสถานพยาบาลด้วยตนเองลำบาก',
            ),
            DifficultyReason.transport => _DetailsField(
              key: const ValueKey('transport_details'),
              controller: provider.transportDetailsController,
              title: 'รายละเอียดอุปสรรคในการเดินทาง',
              hint: 'ระบุพื้นที่พักอาศัยและอุปสรรคในการเข้าถึงระบบขนส่งสาธารณะ',
            ),
            DifficultyReason.resources => _ResourcesSection(provider),
            DifficultyReason.special => _SpecialSection(provider),
          },
      ],
    );
  }
}

class _ResourcesSection extends StatelessWidget {
  const _ResourcesSection(this.provider);

  final RegisterToClaimYourRightsV2Provider provider;

  String? _amountValidator(String? value) {
    if ((value ?? '').trim().isEmpty) return 'กรุณากรอกจำนวนเงิน (0 ได้)';
    if (RegisterToClaimYourRightsV2Provider.parseAmount(value) == null) {
      return 'กรุณากรอกตัวเลขตั้งแต่ 0 ขึ้นไป';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final income = _AmountField(
      controller: provider.monthlyIncomeController,
      label: 'รายได้รวมครอบครัวต่อเดือน',
      helper: 'รวมรายได้ทุกคนในครอบครัว',
      icon: Icons.trending_up_rounded,
      accent: RegV2Colors.positive,
      accentSoft: RegV2Colors.positiveSoft,
      validator: _amountValidator,
    );
    final expenses = _AmountField(
      controller: provider.monthlyExpensesController,
      label: 'รายจ่ายรวมครอบครัวต่อเดือน',
      helper: 'ใช้ช่วงเดือนเดียวกับรายได้',
      icon: Icons.trending_down_rounded,
      accent: RegV2Colors.negative,
      accentSoft: RegV2Colors.negativeSoft,
      validator: _amountValidator,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        Text('รายได้–รายจ่ายครอบครัว', style: RegV2Text.sectionTitle),
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 560
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Expanded(child: income),
                    Expanded(child: expenses),
                  ],
                )
              : Column(spacing: 16, children: [income, expenses]),
        ),
        BoxUploadMultiFileWidget(
          labelText: 'ภาพสภาพบ้าน / ที่พักอาศัย',
          description: 'ภาพสภาพบ้าน',
          initialValue: provider.housePhotos,
          maxFile: 5,
          allowedExtensions: const ['jpg', 'jpeg', 'png'],
          onFilesSelected: provider.setHousePhotos,
          validator: (_) => provider.housePhotos.isEmpty
              ? 'กรุณาถ่ายหรือแนบภาพบ้านอย่างน้อย 1 ภาพ'
              : null,
        ),
      ],
    );
  }
}

class _SpecialSection extends StatelessWidget {
  const _SpecialSection(this.provider);

  final RegisterToClaimYourRightsV2Provider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 28,
      children: [
        RadioCardGroup<SpecialSubtype>(
          label: 'เลือกกลุ่มที่ต้องการการดูแลพิเศษ',
          value: provider.specialSubtype,
          onChanged: provider.setSpecialSubtype,
          options: [
            for (final subtype in SpecialSubtype.values)
              RadioCardOption(value: subtype, label: subtype.label),
          ],
        ),
        if (provider.specialSubtype == SpecialSubtype.other)
          _DetailsField(
            key: const ValueKey('special_other_details'),
            controller: provider.specialOtherDetailsController,
            title: 'ระบุกลุ่มหรือความจำเป็นในการดูแลพิเศษ',
            hint: 'อธิบายว่าผู้ป่วยต้องการการดูแลพิเศษระหว่างเดินทางอย่างไร',
          ),
      ],
    );
  }
}

/// ช่องข้อความหลายบรรทัดแบบบังคับ (ต้องไม่ใช่ช่องว่างล้วน)
class _DetailsField extends StatelessWidget {
  const _DetailsField({
    super.key,
    required this.controller,
    required this.title,
    required this.hint,
    this.example,
  });

  final TextEditingController controller;
  final String title;
  final String hint;
  final String? example;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        RegV2FieldLabel(text: title),
        Text(hint, style: RegV2Text.muted),
        const SizedBox(height: 2),
        TextFormField(
          controller: controller,
          minLines: 3,
          maxLines: 6,
          style: RegV2Text.body,
          decoration: InputDecoration(hintText: example, hintMaxLines: 3),
          validator: (value) =>
              (value ?? '').trim().isEmpty ? 'กรุณากรอกรายละเอียด' : null,
        ),
      ],
    );
  }
}

/// ช่องกรอกจำนวนเงิน — สีเขียวสำหรับรายได้ สีแดงชมพูสำหรับรายจ่าย
class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.controller,
    required this.label,
    required this.helper,
    required this.icon,
    required this.accent,
    required this.accentSoft,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String helper;
  final IconData icon;
  final Color accent;
  final Color accentSoft;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RegV2Colors.card,
        borderRadius: BorderRadius.circular(RegV2Radius.tile),
        border: Border.all(color: RegV2Colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            spacing: 10,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              Expanded(child: RegV2FieldLabel(text: label, fontSize: 16)),
            ],
          ),
          TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: AppTextStyles.bold.copyWith(
              fontSize: 20,
              color: RegV2Colors.text,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              helperText: helper,
              suffixText: 'บาท / เดือน',
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
