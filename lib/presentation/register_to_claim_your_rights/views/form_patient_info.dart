import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/extensions/text_editing_controller_extension.dart';
import 'package:rodzendai_form/core/utils/input_formatters.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/models/patient_record_model.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/blocs/data_patient_bloc/data_patient_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_provider.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';
import 'package:rodzendai_form/widgets/dialog/app_dialogs.dart';
import 'package:rodzendai_form/widgets/text_form_field_customer.dart';

class FormPatientInfo extends StatelessWidget {
  const FormPatientInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterToClaimYourRightsProvider>(
      builder: (context, registerProvider, child) {
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 16,
              children: [
                Expanded(
                  child: TextFormFielddCustom(
                    label: 'หมายเลขบัตรประชาชน',
                    controller: registerProvider.patientIdCardController,
                    isRequired: true,
                    inputFormatters: InputFormatters.citizenId,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      return Validators.validateIdCardNumber(value);
                    },
                  ),
                ),
                BlocBuilder<DataPatientBloc, DataPatientState>(
                  builder: (context, state) {
                    if (state is DataPatientLoaded) {
                      log(
                        'FormPatientInfo BlocBuilder rebuild: state=${state.dataPatients.length}',
                      );
                    }
                    return SizedBox(
                      height: 48,
                      child: ButtonCustom(
                        // key: ValueKey(
                        //   registerProvider.patientIdCardController.text.trim(),
                        // ),
                        text: 'ตรวจสอบข้อมูล',
                        isLoading: state is DataPatientLoading,
                        onPressed:
                            registerProvider
                                        .patientIdCardController
                                        .textOrNull ==
                                    null ||
                                registerProvider
                                        .patientIdCardController
                                        .text
                                        .length !=
                                    13
                            ? null
                            : () async {
                                String idCardNumber = registerProvider
                                    .patientIdCardController
                                    .text
                                    .trim();
                                log('Checking ID Card: $idCardNumber');
                                List<PatientRecordModel> dataPatients = [];
                                if (state is DataPatientLoaded) {
                                  dataPatients = state.dataPatients;
                                }

                                if (dataPatients.isEmpty) {
                                  await AppDialogs.error(
                                    context,
                                    message:
                                        'ไม่สามารถเชื่อมต่อข้อมูลผู้ป่วยได้',
                                  );
                                }

                                bool isFound = dataPatients
                                    .where(
                                      (element) =>
                                          element.idCardNumber == idCardNumber,
                                    )
                                    .isNotEmpty;

                                if (!isFound) {
                                  return await AppDialogs.error(
                                    context,
                                    title: 'ไม่สามารถลงทะเบียนได้',
                                    message:
                                        'ขออภัยในความไม่สะดวก\n หมายเลขประจำตัวประชาชน $idCardNumber\nไม่อยู่ในกลุ่มเป้าหมายที่ให้บริการในขณะนี้',
                                  );
                                }

                                await AppDialogs.success(
                                  context,
                                  title: 'สามารถลงทะเบียนได้',
                                  message:
                                      'รหัสประจำตัวประชาชน $idCardNumber\n สามารถลงทะเบียนได้\nกรุณากรอกข้อมูลให้ครบถ้วนและถูกต้อง',
                                );

                                //เนื่องจากรหัสประจำตัวประชาชน 1101800389482 ได้ใช้บริการครบ 3 ครั้งตามกำหนดแล้ว
                              },
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
