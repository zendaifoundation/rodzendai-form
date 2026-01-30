import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/input_formatters.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/presentation/register/interfaces/contact_relatio_type.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_provider.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/radio_group_field.dart';
import 'package:rodzendai_form/widgets/text_form_field_custom.dart';

//ข้อมูลรายละเอียดผู้ติดตาม
class FormCompanionInfo extends StatelessWidget {
  const FormCompanionInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterToClaimYourRightsProvider>(
      builder: (context, registerProvider, child) {
        return BaseCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              FormHeaderWidget(title: 'รายละเอียดผู้ติดตาม'),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Checkbox(
                    value: registerProvider.patientInfoForCompanion,
                    onChanged: (value) {
                      registerProvider.usePatientInfoForCompanion(
                        value ?? false,
                      );
                    },
                    activeColor: AppColors.primary,
                    checkColor: AppColors.white,
                    side: BorderSide(color: AppColors.textLighter, width: 2),
                  ),
                  //Text('ใช้ข้อมูลผู้แจ้ง/ผู้ติดต่อ'),
                  Text('ใข้ข้อมูลผู้ป่วย', style: AppTextStyles.regular),
                ],
              ),
              TextFormFielddCustom(
                label: 'หมายเลขบัตรประชาชน',
                hintText: 'เลขบัตรประชาชน 13 หลัก',
                controller: registerProvider.companionIdCardController,
                isRequired: true,
                inputFormatters: InputFormatters.citizenId,
                keyboardType: TextInputType.number,
                validator: (value) {
                  return Validators.validateIdCardNumber(value);
                },
              ),
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: TextFormFielddCustom(
                      label: 'ชื่อ',
                      hintText: 'ชื่อ',
                      controller: registerProvider.companionFirstNameController,
                      isRequired: true,
                      validator: Validators.required('กรุณากรอกข้อมูล'),
                    ),
                  ),
                  Expanded(
                    child: TextFormFielddCustom(
                      label: 'นามสกุล',
                      hintText: 'นามสกุล',
                      controller: registerProvider.companionLastNameController,
                      isRequired: true,
                      validator: Validators.required('กรุณากรอกข้อมูล'),
                    ),
                  ),
                ],
              ),
              RadioGroupField<ContactRelationType>(
                key: ValueKey(registerProvider.companionRelationSelected),
                label: 'ความสัมพันธ์',
                isRequired: true,
                value: registerProvider.companionRelationSelected,
                options: ContactRelationType.values
                    .map(
                      (relation) =>
                          RadioOption(value: relation, label: relation.value),
                    )
                    .toList(),
                onChanged: (value) {
                  registerProvider.setCompanionRelationSelected(value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'กรุณาเลือกความสัมพันธ์';
                  }
                  return null;
                },
              ),
              TextFormFielddCustom(
                label: 'เบอร์โทรติดต่อ',
                hintText: 'เบอร์โทรติดต่อ',
                controller: registerProvider.companionPhoneController,
                isRequired: true,
                inputFormatters: InputFormatters.phone,
                keyboardType: TextInputType.number,
                validator: Validators.required('กรุณากรอกข้อมูล'),
              ),
            ],
          ),
        );
      },
    );
  }
}
