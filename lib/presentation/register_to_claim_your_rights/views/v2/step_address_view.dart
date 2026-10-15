import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/core/utils/input_formatters.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_v2_provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/radio_card_group.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/reg_v2_text_field.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';
import 'package:rodzendai_form/presentation/widgets/district_dropdown.dart';
import 'package:rodzendai_form/presentation/widgets/province_dropdown.dart';
import 'package:rodzendai_form/presentation/widgets/sub_district_dropdown.dart';

/// Step 4 — ที่อยู่ตามทะเบียนบ้าน และที่อยู่ปัจจุบัน
class StepAddressView extends StatelessWidget {
  const StepAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterToClaimYourRightsV2Provider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        const RegV2SectionHeader(
          icon: Icons.home_outlined,
          title: 'ที่อยู่ตามทะเบียนบ้าน',
        ),
        _AddressFields(
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
          onChanged: provider.setAddressSame,
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
        if (provider.addressSame == false)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: RegV2Colors.background,
              borderRadius: BorderRadius.circular(RegV2Radius.card),
              border: Border.all(color: RegV2Colors.border),
            ),
            child: _AddressFields(
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

/// ชุดกรอกที่อยู่: บ้านเลขที่/ถนน, จังหวัด, อำเภอ, ตำบล, รหัสไปรษณีย์
class _AddressFields extends StatelessWidget {
  const _AddressFields({
    required this.addressController,
    required this.postalCodeController,
    required this.provinceCode,
    required this.districtCode,
    required this.subDistrictCode,
    required this.onProvinceChanged,
    required this.onDistrictChanged,
    required this.onSubDistrictChanged,
  });

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
              allowedProvinceCodes: EnvHelper.allowedProvinceCode != null
                  ? [EnvHelper.allowedProvinceCode!]
                  : [],
              validator: Validators.required('กรุณาเลือกจังหวัด'),
            ),
            DistrictDropdown(
              label: 'อำเภอ/เขต',
              provinceCode: provinceCode,
              selectedDistrictCode: districtCode,
              onDistrictChanged: onDistrictChanged,
              allowedDistrictCodes: EnvHelper.allowedDistrictCode != null
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
              allowedSubDistrictCodes: EnvHelper.allowedSubDistrictCodes,
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
