import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/extensions/text_editing_controller_extension.dart';
import 'package:rodzendai_form/core/utils/input_formatters.dart';
import 'package:rodzendai_form/core/utils/toast_helper.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/presentation/register/interfaces/patient_type.dart';
import 'package:rodzendai_form/presentation/register/interfaces/transport_ability.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/blocs/check_eligibility_bloc/check_eligibility_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/blocs/data_patient_bloc/data_patient_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_provider.dart';
import 'package:rodzendai_form/responsive.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';
import 'package:rodzendai_form/widgets/dialog/app_dialogs.dart';
import 'package:rodzendai_form/widgets/dialog/loading_dialog.dart';
import 'package:rodzendai_form/widgets/radio_group_field.dart';
import 'package:rodzendai_form/widgets/text_form_field_custom.dart';

class FormPatientInfo extends StatefulWidget {
  const FormPatientInfo({super.key, required this.registerProvider});

  final RegisterToClaimYourRightsProvider registerProvider;

  @override
  State<FormPatientInfo> createState() => _FormPatientInfoState();
}

class _FormPatientInfoState extends State<FormPatientInfo> {
  late CheckEligibilityBloc _checkEligibilityBloc;

  @override
  void initState() {
    super.initState();
    _checkEligibilityBloc = CheckEligibilityBloc();
  }

  @override
  void dispose() {
    _checkEligibilityBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _checkEligibilityBloc,
      child: BlocListener<CheckEligibilityBloc, CheckEligibilityState>(
        bloc: _checkEligibilityBloc,
        listener: (context, state) async {
          switch (state) {
            case CheckEligibilityInitial():
              break;
            case CheckEligibilityLoading():
              LoadingDialog.show(context);
              break;
            case CheckEligibilitySuccess():
              LoadingDialog.hide(context);
              await AppDialogs.success(
                context,
                title: 'สามารถลงทะเบียนได้',
                message:
                    'รหัสประจำตัวประชาชน ${widget.registerProvider.patientIdCardController.text.trim()}\n สามารถลงทะเบียนได้',
              );
              widget.registerProvider.setIsChecked(true);
              break;
            case CheckEligibilityFailure():
              LoadingDialog.hide(context);
              // log('CheckEligibilityFailure -> ${state.message}');
              ToastHelper.showError(
                context: context,
                title: 'ลงทะเบียนไม่สำเร็จ',
                description: state.message,
              );
              break;
          }
        },
        child: BaseCardContainer(
          child: Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormHeaderWidget(title: 'รายละเอียดผู้ป่วย'),
              _buildCheckIdCardNumber(),
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: TextFormFielddCustom(
                      label: 'ชื่อ',
                      hintText: 'ชื่อ',
                      isRequired: true,
                      controller:
                          widget.registerProvider.patientFirstNameController,
                      validator: Validators.required('กรุณากรอกข้อมูล'),
                    ),
                  ),
                  Expanded(
                    child: TextFormFielddCustom(
                      label: 'นามสกุล',
                      hintText: 'นามสกุล',
                      isRequired: true,
                      controller:
                          widget.registerProvider.patientLastNameController,
                      validator: Validators.required('กรุณากรอกข้อมูล'),
                    ),
                  ),
                ],
              ),
              TextFormFielddCustom(
                label: 'เบอร์โทรติดต่อ',
                hintText: 'เบอร์โทรติดต่อ',
                isRequired: true,
                controller: widget.registerProvider.patientPhoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: InputFormatters.phone,
                validator: Validators.required('กรุณากรอกข้อมูล'),
              ),

              TextFormFielddCustom(
                label: 'Line ID (ถ้ามี)',
                isRequired: false,
                controller: widget.registerProvider.patientLineIdController,
              ),

              Selector<RegisterToClaimYourRightsProvider, PatientType?>(
                selector: (_, provider) => provider.patientTypeSelected,
                builder: (context, patientTypeSelected, child) =>
                    RadioGroupField<PatientType>(
                      key: ValueKey(patientTypeSelected),
                      label: 'ประเภทผู้ป่วย',
                      isRequired: true,
                      value: patientTypeSelected,
                      options: PatientType.values
                          .map(
                            (type) =>
                                RadioOption(value: type, label: type.value),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        widget.registerProvider.setPatientTypeSelected(value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'กรุณาเลือกประเภทผู้ป่วย';
                        }
                        return null;
                      },
                    ),
              ),

              Selector<RegisterToClaimYourRightsProvider, TransportAbility?>(
                selector: (_, provider) => provider.transportAbilitySelected,
                builder: (context, transportAbilitySelected, child) =>
                    RadioGroupField<TransportAbility>(
                      key: ValueKey(transportAbilitySelected),
                      label: 'ความสามารถในการเดินทาง',
                      isRequired: true,
                      value: transportAbilitySelected,
                      options: TransportAbility.values
                          .map(
                            (ability) => RadioOption(
                              value: ability,
                              label: ability.value,
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        widget.registerProvider.setTransportAbilitySelected(
                          value,
                        );
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'กรุณาเลือกความสามารถในการเดินทาง';
                        }
                        return null;
                      },
                    ),
              ),

              // BoxUploadMultiFileWidget(
              //   initialValue: widget.registerProvider.uploadedFiles,
              //   onFilesSelected: (files) {
              //     widget.registerProvider.setUploadedFiles(files);
              //   },
              //   validator: (List<UploadedFile>? files) {
              //     if (files == null || files.isEmpty) {
              //       return 'กรุณาอัปโหลดไฟล์ใบนัดหมายแพทย์';
              //     }
              //     return null;
              //   },
              //   maxFile: 5,
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckIdCardNumber() {
    if (Responsive.isMobile(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [_buildIdCardNumber(), _buildButtonCheck()],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 16,
      children: [
        Expanded(child: _buildIdCardNumber()),
        _buildButtonCheck(),
      ],
    );
  }

  Consumer<RegisterToClaimYourRightsProvider> _buildButtonCheck() {
    return Consumer<RegisterToClaimYourRightsProvider>(
      builder: (context, provider, child) =>
          BlocBuilder<CheckEligibilityBloc, CheckEligibilityState>(
            bloc: _checkEligibilityBloc,
            builder: (context, state) {
              return SizedBox(
                height: 48,
                child: ButtonCustom(
                  // key: ValueKey(
                  //   registerProvider.patientIdCardController.text.trim(),
                  // ),
                  text: 'ตรวจสอบข้อมูล',
                  isLoading: state is DataPatientLoading,
                  onPressed:
                      provider.patientIdCardController.textOrNull == null ||
                          provider.patientIdCardController.text.length != 13
                      ? null
                      : () async {
                          String idCardNumber = provider
                              .patientIdCardController
                              .text
                              .trim();
                          log('Checking ID Card: $idCardNumber');

                          _checkEligibilityBloc.add(
                            CheckRegisterRequestEvent(
                              idCardNumber: idCardNumber,
                            ),
                          );
                          // List<PatientRecordModel> dataPatients =
                          //     [];
                          // if (state is DataPatientLoaded) {
                          //   dataPatients = state.dataPatients;
                          // }

                          // if (dataPatients.isEmpty) {
                          //   await AppDialogs.error(
                          //     context,
                          //     message:
                          //         'ไม่สามารถเชื่อมต่อข้อมูลผู้ป่วยได้',
                          //   );
                          // }

                          // bool isFound = dataPatients
                          //     .where(
                          //       (element) =>
                          //           element.idCardNumber ==
                          //           idCardNumber,
                          //     )
                          //     .isNotEmpty;

                          // if (!isFound) {
                          //   return await AppDialogs.error(
                          //     context,
                          //     title: 'ไม่สามารถลงทะเบียนได้',
                          //     message:
                          //         'ขออภัยในความไม่สะดวก\n หมายเลขประจำตัวประชาชน $idCardNumber\nไม่อยู่ในกลุ่มเป้าหมายที่ให้บริการในขณะนี้',
                          //   );
                          // }

                          // await AppDialogs.success(
                          //   context,
                          //   title: 'สามารถลงทะเบียนได้',
                          //   message:
                          //       'รหัสประจำตัวประชาชน $idCardNumber\n สามารถลงทะเบียนได้\nกรุณากรอกข้อมูลให้ครบถ้วนและถูกต้อง',
                          // );
                          // widget.registerProvider.setIsChecked(
                          //   true,
                          // );

                          //เนื่องจากรหัสประจำตัวประชาชน 1101800389482 ได้ใช้บริการครบ 3 ครั้งตามกำหนดแล้ว
                        },
                ),
              );
            },
          ),

      // BlocBuilder<DataPatientBloc, DataPatientState>(
      //   builder: (context, state) {
      //     return SizedBox(
      //       height: 48,
      //       child: ButtonCustom(
      //         // key: ValueKey(
      //         //   registerProvider.patientIdCardController.text.trim(),
      //         // ),
      //         text: 'ตรวจสอบข้อมูล',
      //         isLoading: state is DataPatientLoading,
      //         onPressed:
      //             provider.patientIdCardController.textOrNull ==
      //                     null ||
      //                 provider
      //                         .patientIdCardController
      //                         .text
      //                         .length !=
      //                     13
      //             ? null
      //             : () async {
      //                 String idCardNumber = provider
      //                     .patientIdCardController
      //                     .text
      //                     .trim();
      //                 log('Checking ID Card: $idCardNumber');
      //                 List<PatientRecordModel> dataPatients =
      //                     [];
      //                 if (state is DataPatientLoaded) {
      //                   dataPatients = state.dataPatients;
      //                 }

      //                 if (dataPatients.isEmpty) {
      //                   await AppDialogs.error(
      //                     context,
      //                     message:
      //                         'ไม่สามารถเชื่อมต่อข้อมูลผู้ป่วยได้',
      //                   );
      //                 }

      //                 bool isFound = dataPatients
      //                     .where(
      //                       (element) =>
      //                           element.idCardNumber ==
      //                           idCardNumber,
      //                     )
      //                     .isNotEmpty;

      //                 if (!isFound) {
      //                   return await AppDialogs.error(
      //                     context,
      //                     title: 'ไม่สามารถลงทะเบียนได้',
      //                     message:
      //                         'ขออภัยในความไม่สะดวก\n หมายเลขประจำตัวประชาชน $idCardNumber\nไม่อยู่ในกลุ่มเป้าหมายที่ให้บริการในขณะนี้',
      //                   );
      //                 }

      //                 await AppDialogs.success(
      //                   context,
      //                   title: 'สามารถลงทะเบียนได้',
      //                   message:
      //                       'รหัสประจำตัวประชาชน $idCardNumber\n สามารถลงทะเบียนได้\nกรุณากรอกข้อมูลให้ครบถ้วนและถูกต้อง',
      //                 );
      //                 widget.registerProvider.setIsChecked(
      //                   true,
      //                 );

      //                 //เนื่องจากรหัสประจำตัวประชาชน 1101800389482 ได้ใช้บริการครบ 3 ครั้งตามกำหนดแล้ว
      //               },
      //       ),
      //     );
      //   },
      // ),
    );
  }

  TextFormFielddCustom _buildIdCardNumber() {
    return TextFormFielddCustom(
      label: 'หมายเลขบัตรประชาชน',
      hintText: 'เลขบัตรประชาชน 13 หลัก',
      controller: widget.registerProvider.patientIdCardController,
      isRequired: true,
      inputFormatters: InputFormatters.citizenId,
      keyboardType: TextInputType.number,
      validator: (value) {
        return Validators.validateIdCardNumber(value);
      },
    );
  }
}
