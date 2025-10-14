import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_provider.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/dropdown_field_customer.dart';
import 'package:rodzendai_form/widgets/text_form_field_customer.dart';

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
              DropdownFieldCustomer(
                label: 'จังหวัด',
                items: [],
                hintText: 'เลือกจังหวัด',
              ),
              DropdownFieldCustomer(
                label: 'อำเภอ/เขต',
                items: [],
                hintText: 'เลือกอำเภอ/เขต',
              ),
              DropdownFieldCustomer(
                label: 'ตำบล/แขวง',
                items: [],
                hintText: 'เลือกตำบล/แขวง',
              ),
            ],
          ),
        );
      },
    );
  }
}
