import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/models/interfaces/service_type.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/radio_group_field.dart';
import 'package:rodzendai_form/widgets/text_form_field_customer.dart';

//ที่อยู่ตามทะเบียนบ้าน/ปัจจุบัน
class FormAddressInfo extends StatelessWidget {
  const FormAddressInfo({super.key, required this.registerProvider});
  final RegisterProvider registerProvider;

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
            hintText:
                'บ้านเลขที่ หมู่ ซอย ถนน ตำบล/แขวง อำเภอ/เขต จังหวัด รหัสไปรษณีย์',
            maxLines: null,
            minLines: 3,
            controller: registerProvider.registeredAddressController,
            validator: Validators.required('กรุณากรอกข้อมูล'),
          ),
          RadioGroupField<ServiceType>(
            label: 'ความต้องการใช้บริการ',
            isRequired: true,
            value: registerProvider.serviceTypeSelected,
            options: ServiceType.values
                .map(
                  (service) =>
                      RadioOption(value: service, label: service.value),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              registerProvider.setServiceTypeSelected(value);
            },
            validator: (value) {
              if (value == null) {
                return 'กรุณาเลือกความต้องการใช้บริการ';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
