import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/utils/input_formatters.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/presentation/register/interfaces/contact_relatio_type.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/radio_group_field.dart';
import 'package:rodzendai_form/widgets/text_form_field_customer.dart';

//ข้อมูลผู้แจ้ง/ติดต่อ
class FormCompanionInfo extends StatelessWidget {
  const FormCompanionInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterProvider>(
      builder: (context, registerProvider, child) {
        log(
          ' registerProvider.companionRelationSelected, -> ${registerProvider.companionRelationSelected}',
        );
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
                    value: registerProvider.contactInfoForCompanion,
                    onChanged: (value) {
                      registerProvider.useContactInfoForCompanion(
                        value ?? false,
                      );
                    },
                    activeColor: AppColors.primary,
                    checkColor: AppColors.white,
                    side: BorderSide(color: AppColors.textLighter, width: 2),
                  ),
                  Text('ใช้ข้อมูลผู้แจ้ง/ผู้ติดต่อ'),
                ],
              ),
              TextFormFielddCustom(
                label: 'ชื่อ-นามสกุล ผู้ติดตาม',
                controller: registerProvider.companionNameController,
                isRequired: true,
                validator: Validators.required('กรุณากรอกข้อมูล'),
              ),
              RadioGroupField<ContactRelationType>(
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
