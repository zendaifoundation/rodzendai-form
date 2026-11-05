import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/utils/input_formatters.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/presentation/register/interfaces/contact_relatio_type.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/radio_card_group.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/reg_v2_text_field.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';

/// Step 3 — ผู้แจ้ง/ผู้ติดต่อ และผู้ติดตามระหว่างเดินทาง
class StepContactView extends StatelessWidget {
  const StepContactView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterProvider>();
    // หมายเหตุ: ใน RegisterProvider ค่า hasCompanion == true หมายถึง "ไม่มีผู้ติดตาม"
    final hasCompanion = !provider.hasCompanion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        const RegV2SectionHeader(
          icon: Icons.contact_phone_outlined,
          title: 'ผู้แจ้ง / ผู้ติดต่อ',
          subtitle: 'ผู้ที่เจ้าหน้าที่ติดต่อกลับเพื่อยืนยันการจอง',
        ),
        RegV2CheckboxTile(
          label: 'ใช้ข้อมูลผู้ป่วยเป็นผู้แจ้ง',
          description: 'เติมชื่อ เบอร์โทร และความสัมพันธ์ "ตนเอง" ให้อัตโนมัติ',
          value: provider.patientInfoForContact,
          onChanged: provider.usePatientInfoForContact,
        ),
        RegV2TextField(
          label: 'ชื่อ-นามสกุล ผู้แจ้ง/ติดต่อ',
          controller: provider.contactNameController,
          validator: Validators.required('กรุณากรอกข้อมูล'),
        ),
        RegV2FieldRow(
          children: [
            _RelationDropdown(
              label: 'ความสัมพันธ์กับผู้ป่วย',
              value: provider.contactRelationSelected,
              onChanged: provider.setContactRelationSelected,
            ),
            RegV2TextField(
              label: 'เบอร์โทรติดต่อ',
              controller: provider.contactPhoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: InputFormatters.phone,
              hintText: '0812345678',
              validator: Validators.required('กรุณากรอกข้อมูล'),
            ),
          ],
        ),

        const Divider(height: 24),

        const RegV2SectionHeader(
          icon: Icons.people_outline_rounded,
          title: 'ผู้ติดตามระหว่างเดินทาง',
          subtitle: 'ผู้ที่เดินทางไปกับผู้ป่วยในวันนัดหมาย',
        ),
        RadioCardGroup<bool>(
          label: 'มีผู้ติดตามระหว่างเดินทางหรือไม่?',
          value: hasCompanion,
          onChanged: (value) => provider.setHasCompanion(!value),
          options: const [
            RadioCardOption(value: true, label: 'มีผู้ติดตาม'),
            RadioCardOption(value: false, label: 'ไม่มีผู้ติดตาม'),
          ],
        ),
        if (hasCompanion) _CompanionFields(provider),
      ],
    );
  }
}

class _CompanionFields extends StatelessWidget {
  const _CompanionFields(this.provider);

  final RegisterProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RegV2Colors.background,
        borderRadius: BorderRadius.circular(RegV2Radius.card),
        border: Border.all(color: RegV2Colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          if (provider.hasRegisteredCompanion)
            RegV2CheckboxTile(
              label: 'ใช้ข้อมูลผู้ติดตาม',
              description:
                  'เติมข้อมูลผู้ติดตามที่ลงทะเบียนไว้กับผู้ป่วยให้อัตโนมัติ',
              value: provider.registeredCompanionForCompanion,
              onChanged: provider.useRegisteredCompanionInfo,
            )
          else
            const InfoBox(
              text:
                  'ผู้ป่วยยังไม่มีข้อมูลผู้ติดตามที่ลงทะเบียนไว้ กรุณากรอกด้านล่าง',
            ),
          RegV2TextField(
            label: 'ชื่อ-นามสกุล ผู้ติดตาม',
            controller: provider.companionNameController,
            validator: Validators.required('กรุณากรอกข้อมูล'),
          ),
          RegV2FieldRow(
            children: [
              _RelationDropdown(
                label: 'ความสัมพันธ์กับผู้ป่วย',
                value: provider.companionRelationSelected,
                onChanged: provider.setCompanionRelationSelected,
              ),
              RegV2TextField(
                label: 'เบอร์โทรผู้ติดตาม',
                controller: provider.companionPhoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: InputFormatters.phone,
                hintText: '0812345678',
                validator: Validators.required('กรุณากรอกข้อมูล'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// dropdown ความสัมพันธ์ ค่าเริ่มต้นตาม provider (key เปลี่ยนเมื่อค่าเปลี่ยนจากภายนอก)
class _RelationDropdown extends StatelessWidget {
  const _RelationDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final ContactRelationType? value;
  final ValueChanged<ContactRelationType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        RegV2FieldLabel(text: label, fontSize: 16),
        DropdownButtonFormField<ContactRelationType>(
          key: ValueKey(value),
          initialValue: value,
          isExpanded: true,
          hint: Text('เลือกความสัมพันธ์', style: RegV2Text.caption),
          style: RegV2Text.body,
          borderRadius: BorderRadius.circular(RegV2Radius.tile),
          items: [
            for (final relation in ContactRelationType.values)
              DropdownMenuItem(value: relation, child: Text(relation.value)),
          ],
          onChanged: onChanged,
          validator: (value) => value == null ? 'กรุณาเลือกความสัมพันธ์' : null,
        ),
      ],
    );
  }
}
