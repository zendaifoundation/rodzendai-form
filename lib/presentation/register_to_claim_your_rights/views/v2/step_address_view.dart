import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/core/utils/input_formatters.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_v2_provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/radio_card_group.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/reg_v2_dialogs.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/reg_v2_text_field.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';
import 'package:rodzendai_form/presentation/widgets/district_dropdown.dart';
import 'package:rodzendai_form/presentation/widgets/province_dropdown.dart';
import 'package:rodzendai_form/presentation/widgets/sub_district_dropdown.dart';

/// Step 4 — ที่อยู่ตามทะเบียนบ้าน และที่อยู่ปัจจุบัน
class StepAddressView extends StatefulWidget {
  const StepAddressView({super.key});

  @override
  State<StepAddressView> createState() => _StepAddressViewState();
}

class _StepAddressViewState extends State<StepAddressView> {
  /// หัวข้อ "ที่อยู่ตามทะเบียนบ้าน" ไว้เลื่อนกลับขึ้นไปเมื่อที่อยู่อยู่นอกพื้นที่
  final _registeredSectionKey = GlobalKey();

  /// กด "ตรงกับทะเบียนบ้าน" ทั้งที่ทะเบียนบ้านอยู่นอกพื้นที่ → แจ้ง ไม่รับตัวเลือก
  /// แล้วเลื่อนขึ้นไปที่ส่วนทะเบียนบ้านให้ผู้ใช้ตรวจ/แก้เอง
  Future<void> _onAddressSameChanged(
    RegisterToClaimYourRightsV2Provider provider,
    bool value,
  ) async {
    if (value && !provider.isRegisteredAddressInServiceArea) {
      await RegV2Dialogs.warning(
        context,
        title: 'ที่อยู่ไม่อยู่ในพื้นที่ให้บริการ',
        message: provider.allowsLatentPopulation
            ? 'ที่อยู่ตามทะเบียนบ้านไม่อยู่ในพื้นที่ให้บริการของโครงการ\n'
                  'กรุณาตรวจสอบที่อยู่ตามทะเบียนบ้าน หรือเลือก "เป็นคนละที่อยู่" '
                  'แล้วกรอกที่อยู่ปัจจุบันที่พักอาศัยจริงในพื้นที่โครงการ'
            : 'ที่อยู่ตามทะเบียนบ้านไม่อยู่ในพื้นที่ให้บริการของโครงการ\n'
                  'โครงการนี้รับเฉพาะผู้มีชื่ออยู่ในทะเบียนบ้านในพื้นที่ '
                  'กรุณาตรวจสอบที่อยู่ตามทะเบียนบ้าน',
      );
      if (!mounted) return;
      final target = _registeredSectionKey.currentContext;
      if (target != null && target.mounted) {
        await Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          alignment: 0.05,
        );
      }
      return;
    }
    provider.setAddressSame(value);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterToClaimYourRightsV2Provider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        RegV2SectionHeader(
          key: _registeredSectionKey,
          icon: Icons.home_outlined,
          title: 'ที่อยู่ตามทะเบียนบ้าน',
          subtitle: provider.allowsLatentPopulation
              ? 'อยู่จังหวัดใดก็ได้ (กรณีทะเบียนบ้านนอกพื้นที่ถือเป็นประชากรแฝง)'
              : 'ต้องอยู่ในพื้นที่ให้บริการของโครงการ',
        ),
        _AddressFields(
          // รับประชากรแฝง: ทะเบียนบ้านไม่จำกัดพื้นที่ — พื้นที่ให้บริการเช็คที่ "ที่อยู่ปัจจุบัน"
          restrictToServiceArea: !provider.allowsLatentPopulation,
          addressController: provider.registeredAddressController,
          postalCodeController: provider.registeredPostalCodeController,
          provinceCode: provider.registeredProvinceCode,
          districtCode: provider.registeredDistrictCode,
          subDistrictCode: provider.registeredSubDistrictCode,
          onProvinceChanged: provider.setRegisteredProvinceCode,
          onDistrictChanged: provider.setRegisteredDistrictCode,
          onSubDistrictChanged: provider.setRegisteredSubDistrictCode,
        ),

        const Divider(height: 24),

        const RegV2SectionHeader(
          icon: Icons.location_city_outlined,
          title: 'ที่อยู่ปัจจุบัน',
        ),
        RadioCardGroup<bool>(
          label: 'ที่อยู่ปัจจุบันตรงกับทะเบียนบ้านหรือไม่?',
          value: provider.addressSame,
          onChanged: (value) => _onAddressSameChanged(provider, value),
          options: const [
            RadioCardOption(
              value: true,
              label: 'ตรงกับทะเบียนบ้าน',
              description: 'ใช้ที่อยู่ทะเบียนบ้านเป็นที่อยู่ปัจจุบัน',
            ),
            RadioCardOption(
              value: false,
              label: 'เป็นคนละที่อยู่',
              description: 'กรอกที่อยู่ที่พักอาศัยอยู่จริง',
            ),
          ],
        ),
        if (provider.addressSame != null && !provider.isAddressInServiceArea)
          _OutsideAreaNotice(
            message: provider.allowsLatentPopulation
                ? "ที่อยู่ไม่อยู่ในพื้นที่ให้บริการ"
                      "ที่อยู่ตามทะเบียนบ้าน ไม่อยู่ในพื้นที่ให้บริการ"
                      "กรุณากรอกที่อยู่ปัจจุบันที่อยู่ในพื้นที่โครงการตกลง"
                : 'ที่อยู่ไม่อยู่ในพื้นที่ให้บริการ\n'
                      'โครงการนี้รับเฉพาะผู้มีชื่ออยู่ในทะเบียนบ้านในพื้นที่ '
                      'กรุณาตรวจสอบที่อยู่ตามทะเบียนบ้านและที่อยู่ปัจจุบัน',
          ),
        if (provider.addressSame == false)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: RegV2Colors.background,
              borderRadius: BorderRadius.circular(RegV2Radius.card),
              border: Border.all(color: RegV2Colors.border),
            ),
            child: _AddressFields(
              restrictToServiceArea: true,
              addressController: provider.currentAddressController,
              postalCodeController: provider.currentPostalCodeController,
              provinceCode: provider.currentProvinceCode,
              districtCode: provider.currentDistrictCode,
              subDistrictCode: provider.currentSubDistrictCode,
              onProvinceChanged: provider.setCurrentProvinceCode,
              onDistrictChanged: provider.setCurrentDistrictCode,
              onSubDistrictChanged: provider.setCurrentSubDistrictCode,
            ),
          ),
      ],
    );
  }
}

/// แจ้งว่าที่อยู่ปัจจุบัน (หรือทะเบียนบ้านที่เลือกว่า "ตรงกัน") อยู่นอกพื้นที่ให้บริการ
class _OutsideAreaNotice extends StatelessWidget {
  const _OutsideAreaNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RegV2Colors.warningSoft,
        borderRadius: BorderRadius.circular(RegV2Radius.tile),
        border: Border.all(color: RegV2Colors.warningBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: RegV2Colors.warningText,
            size: 20,
          ),
          Expanded(
            child: Text(
              message,
              style: RegV2Text.body.copyWith(color: RegV2Colors.warningText),
            ),
          ),
        ],
      ),
    );
  }
}

/// ชุดกรอกที่อยู่: บ้านเลขที่/ถนน, จังหวัด, อำเภอ, ตำบล, รหัสไปรษณีย์
class _AddressFields extends StatelessWidget {
  const _AddressFields({
    required this.restrictToServiceArea,
    required this.addressController,
    required this.postalCodeController,
    required this.provinceCode,
    required this.districtCode,
    required this.subDistrictCode,
    required this.onProvinceChanged,
    required this.onDistrictChanged,
    required this.onSubDistrictChanged,
  });

  /// true = ให้เลือกได้เฉพาะจังหวัด/อำเภอ/ตำบลในพื้นที่ให้บริการ (ALLOWED_* ใน env)
  final bool restrictToServiceArea;
  final TextEditingController addressController;
  final TextEditingController postalCodeController;
  final int? provinceCode;
  final int? districtCode;
  final int? subDistrictCode;
  final ValueChanged<int?> onProvinceChanged;
  final ValueChanged<int?> onDistrictChanged;
  final ValueChanged<int?> onSubDistrictChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        RegV2TextField(
          label: 'บ้านเลขที่ / หมู่ / อาคาร / ถนน',
          controller: addressController,
          hintText: 'บ้านเลขที่ หมู่ที่ หมู่บ้าน อาคาร ซอย ถนน',
          minLines: 2,
          maxLines: 4,
          validator: (value) =>
              (value ?? '').trim().isEmpty ? 'กรุณากรอกที่อยู่' : null,
        ),
        RegV2FieldRow(
          children: [
            ProvinceDropdown(
              label: 'จังหวัด',
              selectedProvinceCode: provinceCode,
              onProvinceChanged: onProvinceChanged,
              allowedProvinceCodes:
                  restrictToServiceArea && EnvHelper.allowedProvinceCode != null
                  ? [EnvHelper.allowedProvinceCode!]
                  : [],
              validator: Validators.required('กรุณาเลือกจังหวัด'),
            ),
            DistrictDropdown(
              label: 'อำเภอ/เขต',
              provinceCode: provinceCode,
              selectedDistrictCode: districtCode,
              onDistrictChanged: onDistrictChanged,
              allowedDistrictCodes:
                  restrictToServiceArea && EnvHelper.allowedDistrictCode != null
                  ? [EnvHelper.allowedDistrictCode!]
                  : [],
              validator: Validators.required('กรุณาเลือกอำเภอ/เขต'),
            ),
          ],
        ),
        RegV2FieldRow(
          children: [
            SubDistrictDropdown(
              label: 'ตำบล/แขวง',
              districtCode: districtCode,
              selectedSubDistrictCode: subDistrictCode,
              onSubDistrictChanged: onSubDistrictChanged,
              allowedSubDistrictCodes: restrictToServiceArea
                  ? EnvHelper.allowedSubDistrictCodes
                  : const [],
              validator: Validators.required('กรุณาเลือกตำบล/แขวง'),
            ),
            RegV2TextField(
              label: 'รหัสไปรษณีย์',
              controller: postalCodeController,
              keyboardType: TextInputType.number,
              inputFormatters: InputFormatters.postalCode,
              hintText: 'เติมให้อัตโนมัติเมื่อเลือกตำบล',
              validator: (value) =>
                  RegExp(r'^\d{5}$').hasMatch((value ?? '').trim())
                  ? null
                  : 'รหัสไปรษณีย์ต้องเป็นตัวเลข 5 หลัก',
            ),
          ],
        ),
      ],
    );
  }
}
