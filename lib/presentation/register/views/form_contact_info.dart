import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/input_formatters.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/presentation/register/interfaces/contact_relatio_type.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/radio_group_field.dart';
import 'package:rodzendai_form/widgets/text_form_field_customer.dart';

//รายละเอียดผู้ติดตาม
class FormContactInfo extends StatelessWidget {
  const FormContactInfo({super.key, required this.registerProvider});
  final RegisterProvider registerProvider;
  @override
  Widget build(BuildContext context) {
    return BaseCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          FormHeaderWidget(title: 'ข้อมูลผู้แจ้ง/ติดต่อ'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Checkbox(
                value: registerProvider.patientInfoForContact,
                onChanged: (value) {
                  registerProvider.usePatientInfoForContact(value ?? false);
                },
                activeColor: AppColors.primary,
                checkColor: AppColors.white,
                side: BorderSide(color: AppColors.textLighter, width: 2),
              ),
              //Text('ใช้ข้อมูลผู้แจ้ง/ผู้ติดต่อ'),
              Text('ใข้ข้อมูลผู้ป่วย', style: AppTextStyles.regular),
            ],
          ),
          // Add form fields here
          TextFormFielddCustom(
            label: 'ชื่อ-นามสกุล ผู้แจ้ง/ติดต่อ',
            controller: registerProvider.contactNameController,
            isRequired: true,
            validator: Validators.required('กรุณากรอกข้อมูล'),
          ),
          RadioGroupField<ContactRelationType>(
            key: ValueKey(registerProvider.contactRelationSelected),
            label: 'ความสัมพันธ์',
            isRequired: true,
            value: registerProvider.contactRelationSelected,
            options: ContactRelationType.values
                .map(
                  (relation) =>
                      RadioOption(value: relation, label: relation.value),
                )
                .toList(),
            onChanged: (value) {
              registerProvider.setContactRelationSelected(value);
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
            controller: registerProvider.contactPhoneController,
            isRequired: true,
            inputFormatters: InputFormatters.phone,
            keyboardType: TextInputType.number,
            validator: Validators.required('กรุณากรอกข้อมูล'),
          ),
        ],
      ),
    );
  }
}
