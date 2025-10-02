import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/models/interfaces/service_type.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/required_label.dart';
import 'package:rodzendai_form/widgets/text_form_field_customer.dart';

//ที่อยู่ตามทะเบียนบ้าน/ปัจจุบัน
class FormAddressInfo extends StatelessWidget {
  const FormAddressInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          FormHeaderWidget(title: 'ที่อยู่ตามทะเบียนบ้าน/ปัจจุบัน'),
          TextFormFielddCustom(
            label: 'ที่อยู่ตามทะเบียนบ้าน',
            isRequired: true,
            maxLines: null,
            minLines: 3,
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RequiredLabel(text: 'ความต้องการใช้บริการ', isRequired: true),
              Wrap(
                spacing: 8,
                children: [
                  for (var service in ServiceType.values)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<ServiceType>(
                          value: service,
                          groupValue:
                              ServiceType.outbound, // Example selected value
                          onChanged: (ServiceType? value) {
                            // Handle radio button change
                          },
                          activeColor: AppColors.primary,
                        ),
                        Text(service.value),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
