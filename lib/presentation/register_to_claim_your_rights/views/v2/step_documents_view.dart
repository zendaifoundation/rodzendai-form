import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_file_widget.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_multi_file_widget.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_v2_provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/radio_card_group.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/reg_v2_text_field.dart';

/// Step 6 — เอกสารประกอบคำขอ
///
/// หมวด: เอกสารยืนยันตัวตน / ยืนยันที่อยู่ / เพิ่มเติม
/// รายการบังคับยึดเงื่อนไขเดิมของแต่ละพื้นที่ ไม่บังคับเมื่อติ๊ก "อัปโหลดเอกสารภายหลัง"
class StepDocumentsView extends StatelessWidget {
  const StepDocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterToClaimYourRightsV2Provider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        RegV2CheckboxTile(
          label: 'อัปโหลดเอกสารภายหลัง',
          description: provider.uploadDocumentLater
              ? 'ส่งเป็นคำขอรอเอกสาร ไม่บังคับแนบไฟล์ในขั้นตอนนี้'
              : 'ติ๊กหากเอกสารยังไม่ครบ แล้วแนบเพิ่มภายหลัง',
          value: provider.uploadDocumentLater,
          onChanged: provider.setUploadDocumentLater,
        ),
        const InfoBox(
          text:
              'รองรับไฟล์ PDF / JPG / PNG ขนาดไม่เกิน 10 MB ต่อไฟล์ '
              'เลือกไฟล์ใหม่เพื่อแทนที่ไฟล์เดิมได้',
        ),

        const Divider(height: 24),
        const RegV2SectionHeader(
          icon: Icons.badge_outlined,
          title: 'เอกสารยืนยันตัวตน',
        ),
        _SingleDocument(
          title: 'บัตรประชาชนผู้ป่วย',
          isRequired: provider.idCardRequired,
          value: provider.idCardFile,
          onChanged: provider.setIdCardFile,
        ),
        if (provider.showDisabilityCard)
          _SingleDocument(
            title: provider.disabilityCardRequired
                ? 'บัตรคนพิการ'
                : 'บัตรคนพิการ (ถ้ามี)',
            isRequired: provider.disabilityCardRequired,
            value: provider.disabilityCardFile,
            onChanged: provider.setDisabilityCardFile,
          ),
        if (provider.showThaiStateWelfareCard)
          _SingleDocument(
            title: 'บัตรสวัสดิการแห่งรัฐ (ถ้ามี)',
            isRequired: false,
            value: provider.thaiStateWelfareCardFile,
            onChanged: provider.setThaiStateWelfareCardFile,
          ),

        if (provider.showHouseRegistration ||
            provider.showAddressConfirmation) ...[
          const Divider(height: 24),
          const RegV2SectionHeader(
            icon: Icons.home_work_outlined,
            title: 'เอกสารยืนยันที่อยู่อาศัย',
          ),
          if (provider.showHouseRegistration)
            _MultiDocument(
              title: 'ทะเบียนบ้าน',
              isRequired: provider.houseRegistrationRequired,
              maxFile: 2,
              value: provider.houseRegistrationFiles,
              onChanged: provider.setHouseRegistrationFiles,
            ),
          if (provider.showAddressConfirmation)
            _SingleDocument(
              title: 'ฟอร์มยืนยันที่อยู่ (ถ้ามี)',
              isRequired: false,
              value: provider.addressConfirmationFile,
              onChanged: provider.setAddressConfirmationFile,
            ),
        ],

        const Divider(height: 24),
        const RegV2SectionHeader(
          icon: Icons.folder_open_outlined,
          title: 'เอกสารประกอบเพิ่มเติม',
        ),
        _MultiDocument(
          title: 'เอกสารอื่น ๆ (ถ้ามี)',
          isRequired: false,
          maxFile: 5,
          value: provider.otherFiles,
          onChanged: provider.setOtherFiles,
        ),
      ],
    );
  }
}

class _SingleDocument extends StatelessWidget {
  const _SingleDocument({
    required this.title,
    required this.isRequired,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool isRequired;
  final UploadedFile? value;
  final ValueChanged<UploadedFile?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        RegV2FieldLabel(text: title, isRequired: isRequired, fontSize: 16),
        BoxUploadFileWidget(
          // เปลี่ยน key เมื่อสถานะบังคับเปลี่ยน ให้ validator ใหม่มีผล
          key: ValueKey('$title-$isRequired'),
          labelText: 'อัปโหลด$title',
          initialValue: value,
          isRequired: isRequired,
          onFilesSelected: onChanged,
          validator: (_) =>
              isRequired && value == null ? 'กรุณาอัปโหลด$title' : null,
        ),
      ],
    );
  }
}

class _MultiDocument extends StatelessWidget {
  const _MultiDocument({
    required this.title,
    required this.isRequired,
    required this.maxFile,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool isRequired;
  final int maxFile;
  final List<UploadedFile> value;
  final ValueChanged<List<UploadedFile>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        RegV2FieldLabel(text: title, isRequired: isRequired, fontSize: 16),
        BoxUploadMultiFileWidget(
          key: ValueKey('$title-$isRequired'),
          labelText: 'อัปโหลด$title',
          description: title,
          initialValue: value,
          isRequired: isRequired,
          maxFile: maxFile,
          onFilesSelected: onChanged,
          validator: (_) =>
              isRequired && value.isEmpty ? 'กรุณาอัปโหลด$title' : null,
        ),
      ],
    );
  }
}
