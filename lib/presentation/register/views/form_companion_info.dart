import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/presentation/register/interfaces/contact_relatio_type.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/required_label.dart';
import 'package:rodzendai_form/widgets/text_form_field_customer.dart';

//ข้อมูลผู้แจ้ง/ติดต่อ
class FormCompanionInfo extends StatelessWidget {
  const FormCompanionInfo({super.key});

  @override
  Widget build(BuildContext context) {
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
                value: true,
                onChanged: (value) {
                  //todo
                },
              ),
              Text('ใช้ข้อมูลผู้แจ้ง/ผู้ติดต่อ'),
            ],
          ),

          TextFormFielddCustom(
            label: 'ชื่อ-นามสกุล ผู้ติดตาม',
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
