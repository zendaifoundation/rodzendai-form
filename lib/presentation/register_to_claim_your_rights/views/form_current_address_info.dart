import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_provider.dart';
import 'package:rodzendai_form/presentation/widgets/district_dropdown.dart';
import 'package:rodzendai_form/presentation/widgets/province_dropdown.dart';
import 'package:rodzendai_form/presentation/widgets/sub_district_dropdown.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/text_form_field_custom.dart';

class FormCurrentAddressInfo extends StatelessWidget {
  const FormCurrentAddressInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterToClaimYourRightsProvider>(
      builder: (context, registerProvider, child) {
        return BaseCardContainer(
          child: Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormHeaderWidget(title: 'ที่อยู่ปัจจุบัน'),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Checkbox(
                    value: registerProvider.patientAddressForCurrentAddress,
                    onChanged: (value) {
                      registerProvider.usePatientAddressForCurrentAddress(
                        value ?? false,
                      );
                    },
                    activeColor: AppColors.primary,
                    checkColor: AppColors.white,
                    side: BorderSide(color: AppColors.textLighter, width: 2),
                  ),
                  Text(
                    'ใช้ที่อยู่เดียวกับที่อยู่ตามทะเบียนบ้าน',
                    style: AppTextStyles.regular,
                  ),
                ],
              ),
              TextFormFielddCustom(
                label: 'ที่อยู่ปัจจุบัน',
                isRequired: true,
                hintText: 'บ้านเลขที่ หมู่ที่ หมู่บ้าน อาคาร ซอย ถนน',
                maxLines: null,
                minLines: 3,
                controller: registerProvider.currentAddressController,
                isReadOnly: registerProvider.patientAddressForCurrentAddress,
                validator: registerProvider.patientAddressForCurrentAddress
                    ? null
                    : Validators.required('กรุณากรอกข้อมูล'),
              ),
              ProvinceDropdown(
                label: 'จังหวัด',
                selectedProvinceId: registerProvider.currentProvinceId,
                onProvinceChanged: (value) {
                  registerProvider.setCurrentProvinceId(value);
                },
                validator: Validators.required('กรุณาเลือกจังหวัด'),
              ),
              DistrictDropdown(
                label: 'อำเภอ/เขต',
                provinceId: registerProvider.currentProvinceId,
                selectedDistrictId: registerProvider.currentDistrictId,
                onDistrictChanged: (value) {
                  registerProvider.setCurrentDistrictId(value);
                },
                validator: Validators.required('กรุณาเลือกอำเภอ/เขต'),
              ),
              SubDistrictDropdown(
                label: 'ตำบล/แขวง',
                districtId: registerProvider.currentDistrictId,
                selectedSubDistrictId: registerProvider.currentSubDistrictId,
                onSubDistrictChanged: (value) {
                  registerProvider.setCurrentSubDistrictId(value);
                },
                validator: Validators.required('กรุณาเลือกตำบล/แขวง'),
              ),
            ],
          ),
        );
      },
    );
  }
}
