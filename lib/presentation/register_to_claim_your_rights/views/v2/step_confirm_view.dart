import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_v2_provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_barthel_activity_adl.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/dialogs/pdpa_detail_dialog.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/radio_card_group.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';

/// Step 7 — ADL (เฉพาะผู้สูงอายุ) แล้วยืนยันข้อมูลและเงื่อนไข
class StepConfirmView extends StatelessWidget {
  const StepConfirmView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterToClaimYourRightsV2Provider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: [
        if (provider.requiresAdl) ...[
          _AdlSection(provider),
          const Divider(height: 1),
        ],
        _ConfirmationSection(provider),
      ],
    );
  }
}

class _AdlSection extends StatelessWidget {
  const _AdlSection(this.provider);

  final RegisterToClaimYourRightsV2Provider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: [
        Text(
          'แบบประเมินกิจวัตรประจำวัน (ADL)',
          style: RegV2Text.pageTitle.copyWith(fontSize: 20),
        ),
        const InfoBox(
          text:
              'เลือกข้อที่ตรงกับความสามารถจริงของผู้ป่วย ข้อละ 1 คำตอบ '
              'คะแนนเป็นข้อมูลให้เจ้าหน้าที่สอบทาน ไม่ใช่การอนุมัติสิทธิ',
        ),
        for (final question in barthelQuestions)
          RadioCardGroup<int>(
            key: ValueKey('adl_${question.id}'),
            label: question.title,
            value: provider.adlScoreOf(question.id),
            onChanged: (score) => provider.setAdlScore(question.id, score),
            options: [
              for (final option in question.options)
                RadioCardOption(value: option.score, label: option.label),
            ],
          ),
        if (provider.adlTotal != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RegV2Colors.primarySoft,
              borderRadius: BorderRadius.circular(RegV2Radius.tile),
              border: Border.all(color: RegV2Colors.primaryBorder),
            ),
            child: Text(
              'คะแนนรวม ${provider.adlTotal} / 20 (รอเจ้าหน้าที่สอบทาน)',
              style: RegV2Text.sectionTitle.copyWith(
                color: RegV2Colors.primaryHover,
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfirmationSection extends StatelessWidget {
  const _ConfirmationSection(this.provider);

  final RegisterToClaimYourRightsV2Provider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: [
        Text(
          'ยืนยันข้อมูลและเงื่อนไข',
          style: RegV2Text.pageTitle.copyWith(fontSize: 20),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => PdpaDetailDialog.show(context),
            icon: const Icon(Icons.privacy_tip_outlined),
            label: const Text(
              'อ่านประกาศความเป็นส่วนตัว',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        RegV2CheckboxTile(
          label: 'อ่านและรับทราบประกาศความเป็นส่วนตัว',
          value: provider.privacyAck,
          onChanged: provider.setPrivacyAck,
        ),
        RegV2CheckboxTile(
          label: 'รับรองข้อมูลและเอกสารตรงตามความจริง',
          description:
              'ข้าพเจ้ารับรองว่าข้อมูลและเอกสารที่ให้เป็นความจริง '
              'หากตรวจพบว่าจงใจให้ข้อมูลหรือเอกสารอันเป็นเท็จเพื่อขอใช้สิทธิ '
              'หน่วยงานอาจยกเลิกคำขอหรือระงับสิทธิการใช้บริการตามเงื่อนไขโครงการ',
          value: provider.truthAck,
          onChanged: provider.setTruthAck,
        ),
        if (!provider.isConfirmationCompleted)
          Text(
            'กรุณาติ๊กยืนยันให้ครบทั้ง 2 ข้อ เพื่อไปขั้นตอนถัดไป',
            style: RegV2Text.caption.copyWith(fontSize: 14),
          ),
      ],
    );
  }
}
