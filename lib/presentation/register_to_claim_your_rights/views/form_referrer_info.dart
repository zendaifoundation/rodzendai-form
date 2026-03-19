import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_provider.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/text_form_field_custom.dart';

/// ข้อมูลผู้แนะนำ
class FormReferrerInfo extends StatelessWidget {
  const FormReferrerInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterToClaimYourRightsProvider>(
      builder: (context, registerProvider, child) {
        return BaseCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              FormHeaderWidget(title: 'ข้อมูลผู้แนะนำ'),
              TextFormFielddCustom(
                isRequired: false,
                label: 'ชื่อผู้แนะนำ (ถ้ามี)',
                hintText: 'ชื่อผู้แนะนำ',
                controller: registerProvider.referrerNameController,
              ),
            ],
          ),
        );
      },
    );
  }
}
