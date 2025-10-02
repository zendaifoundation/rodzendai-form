import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/presentation/register/interfaces/contact_relatio_type.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/required_label.dart';
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
          // Add form fields here
          TextFormFielddCustom(
            label: 'ชื่อ-นามสกุล ผู้แจ้ง/ติดต่อ',
            isRequired: true,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RequiredLabel(text: 'ความสัมพันธ์', isRequired: true),
              Wrap(
                spacing: 8,
                children: [
                  for (var relation in ContactRelationType.values)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<ContactRelationType>(
                          value: relation,
                          groupValue: ContactRelationType
                              .self, // Example selected value
                          onChanged: (ContactRelationType? value) {
                            // Handle radio button change
                          },
                          activeColor: AppColors.primary,
                        ),
                        Text(relation.value),
                      ],
                    ),
                ],
              ),
            ],
          ),
          TextFormFielddCustom(label: 'เบอร์โทรติดต่อ', isRequired: true),
        ],
      ),
    );
  }
}
