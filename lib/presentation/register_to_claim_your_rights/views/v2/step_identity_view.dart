import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/date_helper.dart';
import 'package:rodzendai_form/models/id_card_ocr_result_model.dart';
import 'package:rodzendai_form/presentation/id_card/widgets/id_card_picker_box.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_v2_provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/radio_card_group.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/reg_v2_text_field.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';

/// Step 1 — ยืนยันตัวตนด้วยบัตรประชาชน
///
/// ถ่าย/เลือกรูปบัตรแล้วระบบอ่านข้อมูล (OCR) เติมให้ในขั้นตอนถัดไป
/// บังคับมีรูปบัตรเสมอ (ไม่มีตัวเลือกอัปโหลดภายหลังในขั้นตอนนี้)
/// OCR อ่านไม่ได้ก็กด "ถัดไป" แล้วกรอกเองได้ (flag เป็น manual) รูปยังแนบเป็นเอกสาร
/// ปุ่ม "เสียบบัตรประชาชน" จะแสดงอัตโนมัติเมื่อตรวจพบ agent อ่านบัตรบนเครื่อง (ยังไม่เปิดใช้)
class StepIdentityView extends StatelessWidget {
  const StepIdentityView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterToClaimYourRightsV2Provider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        const RegV2SectionHeader(
          icon: Icons.badge_outlined,
          title: 'บัตรประชาชนผู้ป่วย',
          subtitle:
              'ระบบจะอ่านเลขบัตร ชื่อ วันเกิด และที่อยู่จากบัตร '
              'มาเติมในขั้นตอนถัดไปให้ โดยยังแก้ไขได้ทุกช่อง',
        ),
        const RegV2FieldLabel(
          text: 'รูปบัตรประชาชนผู้ป่วย',
          isRequired: true,
          fontSize: 16,
        ),
        IdCardPickerBox(
          value: provider.idCardFile,
          enabled: !provider.isOcrLoading,
          onChanged: provider.readIdCard,
        ),
        switch (provider.ocrStatus) {
          OcrStatus.idle => const InfoBox(
            text:
                'ถ่ายให้เห็นบัตรทั้งใบ ไม่สะท้อนแสง '
                'หากระบบอ่านไม่ได้ ยังกรอกข้อมูลเองในขั้นตอนถัดไปได้',
          ),
          OcrStatus.loading => const _OcrLoading(),
          OcrStatus.success => _OcrSummary(provider.ocrResult!),
          OcrStatus.failure => _OcrFailure(
            message: provider.ocrError ?? 'อ่านบัตรไม่สำเร็จ',
          ),
        },
      ],
    );
  }
}

class _OcrLoading extends StatelessWidget {
  const _OcrLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RegV2Colors.primarySoft,
        borderRadius: BorderRadius.circular(RegV2Radius.tile),
        border: Border.all(color: RegV2Colors.primaryBorder),
      ),
      child: Row(
        spacing: 14,
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: RegV2Colors.primary,
            ),
          ),
          Expanded(
            child: Text(
              'กำลังอ่านข้อมูลจากบัตร...',
              style: AppTextStyles.medium.copyWith(
                fontSize: 15,
                color: RegV2Colors.primaryHover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OcrFailure extends StatelessWidget {
  const _OcrFailure({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RegV2Colors.warningSoft,
        borderRadius: BorderRadius.circular(RegV2Radius.tile),
        border: Border.all(color: RegV2Colors.warningText.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Row(
            spacing: 10,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: RegV2Colors.warningText,
              ),
              Expanded(
                child: Text(
                  'อ่านข้อมูลจากบัตรไม่สำเร็จ',
                  style: AppTextStyles.bold.copyWith(
                    fontSize: 15,
                    color: RegV2Colors.warningText,
                  ),
                ),
              ),
            ],
          ),
          Text(message, style: RegV2Text.muted.copyWith(fontSize: 14)),
          Text(
            'ลองเปลี่ยนรูปให้ชัดขึ้น หรือกด "ถัดไป" เพื่อกรอกข้อมูลเอง '
            'รูปบัตรนี้จะยังถูกแนบเป็นเอกสารประกอบ',
            style: RegV2Text.caption,
          ),
        ],
      ),
    );
  }
}

/// สรุปค่าที่อ่านได้ ให้ผู้ใช้เห็นก่อนไปขั้นตอนถัดไป
class _OcrSummary extends StatelessWidget {
  const _OcrSummary(this.result);

  final IdCardOcrResultModel result;

  String _formatId(String? id) {
    final digits = id?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (digits.length != 13) return id ?? '—';
    return '${digits[0]} ${digits.substring(1, 5)} ${digits.substring(5, 10)} '
        '${digits.substring(10, 12)} ${digits[12]}';
  }

  @override
  Widget build(BuildContext context) {
    final dob = DateTime.tryParse(result.dateOfBirth ?? '');
    final rows = <(String, String?)>[
      ('เลขบัตร', _formatId(result.idNumber)),
      ('ชื่อ-นามสกุล', result.fullNameTH),
      ('วันเกิด', dob == null ? null : DateHelper.formatDateThai(dob)),
      ('ที่อยู่', result.address),
    ];
    final readCount = rows.where((r) => (r.$2 ?? '').isNotEmpty).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RegV2Colors.positiveSoft,
        borderRadius: BorderRadius.circular(RegV2Radius.tile),
        border: Border.all(color: RegV2Colors.positive.withAlpha(90)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            spacing: 10,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: RegV2Colors.positive,
              ),
              Expanded(
                child: Text(
                  'อ่านข้อมูลจากบัตรแล้ว $readCount/${rows.length} รายการ',
                  style: AppTextStyles.bold.copyWith(
                    fontSize: 15,
                    color: RegV2Colors.positive,
                  ),
                ),
              ),
            ],
          ),
          for (final (label, value) in rows)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    label,
                    style: RegV2Text.caption.copyWith(fontSize: 14),
                  ),
                ),
                Expanded(
                  child: Text(
                    (value ?? '').isEmpty ? 'อ่านไม่ได้ กรอกเองในขั้นตอนถัดไป' : value!,
                    style: (value ?? '').isEmpty
                        ? RegV2Text.caption.copyWith(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          )
                        : AppTextStyles.medium.copyWith(
                            fontSize: 15,
                            height: 1.4,
                            color: RegV2Colors.text,
                          ),
                  ),
                ),
              ],
            ),
          if (result.warnings.isNotEmpty)
            Text(
              result.warnings.join(' • '),
              style: RegV2Text.caption.copyWith(
                color: RegV2Colors.warningText,
              ),
            ),
          Text(
            'ตรวจสอบและแก้ไขได้ในขั้นตอน "ผู้ป่วยและผู้ติดตาม" และ "ที่อยู่อาศัย"',
            style: RegV2Text.caption,
          ),
        ],
      ),
    );
  }
}
