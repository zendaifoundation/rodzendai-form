import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_provider.dart';
import 'package:rodzendai_form/presentation/widgets/district_dropdown.dart';
import 'package:rodzendai_form/presentation/widgets/province_dropdown.dart';
import 'package:rodzendai_form/presentation/widgets/sub_district_dropdown.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/text_form_field_custom.dart';

//ที่อยู่ตามทะเบียนบ้าน
class FormAddressInfo extends StatelessWidget {
  const FormAddressInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterToClaimYourRightsProvider>(
      builder: (context, registerProvider, child) {
        return BaseCardContainer(
          child: Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormHeaderWidget(title: 'ที่อยู่ตามทะเบียนบ้าน'),
              TextFormFielddCustom(
                label: 'ที่อยู่ตามทะเบียนบ้าน',
                isRequired: true,
                hintText: 'บ้านเลขที่ หมู่ที่ หมู่บ้าน อาคาร ซอย ถนน',
                maxLines: null,
                minLines: 3,
                controller: registerProvider.registeredAddressController,
                validator: Validators.required('กรุณากรอกข้อมูล'),
              ),
              ProvinceDropdown(
                label: 'จังหวัด',
                selectedProvinceId: registerProvider.registeredProvinceId,
                onProvinceChanged: (value) {
                  registerProvider.setRegisteredProvinceId(value);
                },
                validator: Validators.required('กรุณาเลือกจังหวัด'),
              ),
              DistrictDropdown(
                label: 'อำเภอ/เขต',
                provinceId: registerProvider.registeredProvinceId,
                selectedDistrictId: registerProvider.registeredDistrictId,
                onDistrictChanged: (value) {
                  registerProvider.setRegisteredDistrictId(value);
                },
                validator: Validators.required('กรุณาเลือกอำเภอ/เขต'),
              ),
              SubDistrictDropdown(
                label: 'ตำบล/แขวง',
                districtId: registerProvider.registeredDistrictId,
                selectedSubDistrictId:
                    registerProvider.registeredSubDistrictId,
                onSubDistrictChanged: (value) {
                  registerProvider.setRegisteredSubDistrictId(value);
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
