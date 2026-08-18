import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/models/interfaces/service_type.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/radio_group_field.dart';

class FormRequestService extends StatelessWidget {
  const FormRequestService({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          FormHeaderWidget(title: 'รายละเอียดการเดินทาง'),
          Selector<RegisterProvider, ServiceType?>(
            selector: (context, registerProvider) =>
                registerProvider.serviceTypeSelected,
            builder: (context, serviceTypeSelected, child) =>
                RadioGroupField<ServiceType>(
                  label: 'ความต้องการใช้บริการ',
                  isRequired: true,
                  value: serviceTypeSelected,
                  options: ServiceType.values
                      .map(
                        (service) =>
                            RadioOption(value: service, label: service.value),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    context.read<RegisterProvider>().setServiceTypeSelected(
                      value,
                    );
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'กรุณาเลือกความต้องการใช้บริการ';
                    }
                    return null;
                  },
                ),
          ),
        ],
      ),
    );
  }
}
