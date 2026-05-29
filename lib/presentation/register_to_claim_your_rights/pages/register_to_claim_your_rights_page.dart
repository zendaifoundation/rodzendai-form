import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/core/utils/toast_helper.dart';
import 'package:rodzendai_form/presentation/blocs/province_bloc/province_bloc.dart';
import 'package:rodzendai_form/presentation/register/blocs/id_card_reader/id_card_reader_bloc.dart';
import 'package:rodzendai_form/presentation/register/dialogs/id_card_request.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_barthel_activity_adl.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/blocs/data_patient_bloc/data_patient_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/blocs/register_to_claim_your_rights_bloc/register_to_claim_your_rights_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_address_info.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_companion_info.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_current_address_info.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_doument.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_patient_info.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_pickup_location.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_referrer_info.dart';
import 'package:rodzendai_form/presentation/register/views/form_request_service.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/dialogs/pdpa_detail_dialog.dart';
import 'package:rodzendai_form/repositories/firebase_repository.dart';
import 'package:rodzendai_form/repositories/firebase_storeage_repository.dart';
import 'package:rodzendai_form/widgets/appbar_customer.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';
import 'package:rodzendai_form/widgets/dialog/app_dialogs.dart';
import 'package:rodzendai_form/widgets/dialog/loading_dialog.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:rodzendai_form/core/utils/mime_helper.dart';

class RegisterToClaimYourRightsPage extends StatefulWidget {
  const RegisterToClaimYourRightsPage({super.key});

  @override
  State<RegisterToClaimYourRightsPage> createState() =>
      _RegisterToClaimYourRightsPageState();
}

class _RegisterToClaimYourRightsPageState
    extends State<RegisterToClaimYourRightsPage> {
  late RegisterToClaimYourRightsBloc _registerbloc;
  late RegisterToClaimYourRightsProvider _registerProvider;
  //late DataPatientBloc _dataPatientBloc;
  final GlobalKey _formPatientInfoKey = GlobalKey();
  late final IdCardReaderBloc _idCardReaderBloc;
  final GlobalKey _formActivityKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // _registerbloc = RegisterToClaimYourRightsBloc(
    //   firebaseRepository: locator<FirebaseRepository>(),
    //   firebaseStorageRepository: locator<FirebaseStorageRepository>(),
    // );
    _registerbloc = RegisterToClaimYourRightsBloc(
      firebaseRepository: locator<FirebaseRepository>(),
      firebaseStorageRepository: locator<FirebaseStorageRepository>(),
    );
    _registerProvider = RegisterToClaimYourRightsProvider(
      getLocationDetailBloc: context.read<GetLocationDetailBloc>(),
    );
    _idCardReaderBloc = context.read<IdCardReaderBloc>();
    //_dataPatientBloc = DataPatientBloc();

    if (kDebugMode) {
      _registerProvider.morkData();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(seconds: 1));
      _idCardReaderBloc.add(IDCardConnectRequested());
    });
  }

  @override
  void dispose() {
    _registerProvider.dispose();
    _registerbloc.close();
    _idCardReaderBloc.add(IDCardResetRequested());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BlocProvider<DataPatientBloc>.value(
        //   value: _dataPatientBloc..add(LoadDataPatientsEvent()),
        // ),
        BlocProvider<ProvinceBloc>(
          create: (context) => ProvinceBloc()
            ..add(
              ProvinceRequested(
                //selectedProvinceCode: _registerProvider.registeredProvinceCode,
              ),
            ),
        ),

        BlocListener<IdCardReaderBloc, IdCardReaderState>(
          listener: (context, state) async {
            log('IdCardReaderBloc listener -> //');
            if (state is IDCardReaderReady) {
              IDCardPayload? idCardPayload = await IdCardRequestDialog.show(
                context,
              );
              if (idCardPayload != null) {
                await _registerProvider.setPatientInfoFromIDCard(
                  context,
                  idCardPayload,
                );
              }
            }
            // // แสดง error เฉพาะเมื่อเชื่อมต่อเครื่องอ่านบัตรได้แล้ว (ไม่ใช่ connection error)
            // if (state is IDCardFailure) {
            //   final isConnectionError =
            //       state.message.contains('Connection closed') ||
            //       state.message.contains('WebSocket') ||
            //       state.message.contains('ไม่พบเครื่องอ่านบัตร');

            //   // ไม่แสดง error ถ้าเป็น connection error (ไม่ได้เสียบเครื่อง)
            //   if (!isConnectionError) {
            //     await AppDialogs.error(
            //       context,
            //       title: 'ไม่สามารถอ่านบัตรประชาชนได้',
            //       message: state.message,
            //     );
            //   }
            // }
          },
        ),
      ],
      child: ChangeNotifierProvider.value(
        value: _registerProvider,
        child:
            BlocListener<
              RegisterToClaimYourRightsBloc,
              RegisterToClaimYourRightsState
            >(
              bloc: _registerbloc,
              listener: (context, state) async {
                switch (state) {
                  case RegisterToClaimYourRightsInitial():
                    break;
                  case RegisterToClaimYourRightsLoading():
                    LoadingDialog.show(context);
                    break;
                  case RegisterToClaimYourRightsSuccess():
                    LoadingDialog.hide(context);
                    // ToastHelper.showSuccess(
                    //   context: context,
                    //   title: 'ลงทะเบียนสำเร็จ',
                    // );
                    await AppDialogs.success(
                      context,
                      title: 'ลงทะเบียนสำเร็จ',
                      message:
                          'ท่านได้ลงทะเบียนรับสิทธิ์เรียบร้อยแล้ว\n'
                          'กรุณารอเจ้าหน้าที่ตรวจสอบและอนุมัติ',
                    );
                    // await Future.delayed(Duration(milliseconds: 500));
                    if (context.mounted) {
                      context.go('/home');
                    }
                    break;
                  case RegisterToClaimYourRightsFailure():
                    LoadingDialog.hide(context);
                    // ToastHelper.showError(
                    //   context: context,
                    //   title: 'ลงทะเบียนไม่สำเร็จ',
                    //   description: state.message,
                    // );
                    await AppDialogs.error(
                      context,
                      title: 'ลงทะเบียนไม่สำเร็จ',
                      message: state.message,
                    );
                    break;
                }
              },
              child: _view(),
            ),
      ),
    );
  }

  Scaffold _view() {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBarCustomer(title: 'ลงทะเบียนรับสิทธิ์'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            //constraints: BoxConstraints(maxWidth: 600),
            constraints: const BoxConstraints(maxWidth: 1024),
            child: Form(
              key: _registerProvider.formKey,
              child: Column(
                spacing: 16,
                children: [
                  FormPatientInfo(
                    key: _formPatientInfoKey,
                    registerProvider: _registerProvider,
                  ),
                  Selector<RegisterToClaimYourRightsProvider, bool>(
                    selector: (BuildContext p1, p2) =>
                        _registerProvider.isBarthelActivityAdlVisible,
                    builder:
                        (BuildContext context, bool visible, Widget? child) {
                          if (visible) {
                            return FormBarthelActivityAdl(
                              key: _formActivityKey,
                            );
                          }
                          return SizedBox.shrink();
                        },
                  ),
                  FormDoument(),
                  FormAddressInfo(),
                  FormCurrentAddressInfo(),
                  FormCompanionInfo(),
                  FormPickupLocation(registerProvider: _registerProvider),
                  FormReferrerInfo(),

                  SizedBox.shrink(),

                  Selector<RegisterToClaimYourRightsProvider, bool>(
                    selector: (BuildContext context, provider) =>
                        provider.pdpaAccepted,
                    builder: (context, pdpaAccepted, child) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: pdpaAccepted,
                            activeColor: AppColors.primary,
                            checkColor: AppColors.white,
                            side: BorderSide(
                              color: AppColors.textLighter,
                              width: 2,
                            ),
                            onChanged: (value) {
                              _registerProvider.setPdpaAccepted(value ?? false);
                            },
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ข้าพเจ้ายินยอมให้เก็บและใช้ข้อมูลส่วนบุคคลและข้อมูลสุขภาพ '
                                  'เพื่อการลงทะเบียนผู้ป่วยและการให้บริการทางการแพทย์ '
                                  'ตามนโยบายคุ้มครองข้อมูลส่วนบุคคล (PDPA)',
                                ),
                                TextButton(
                                  onPressed: () async =>
                                      await PdpaDetailDialog.show(context),
                                  child: const Text('อ่านรายละเอียดนโยบาย'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  Selector<RegisterToClaimYourRightsProvider, bool>(
                    selector: (BuildContext context, provider) =>
                        provider.pdpaAccepted,
                    builder: (context, pdpaAccepted, child) => SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ButtonCustom(
                        text: 'ลงทะเบียน',

                        onPressed: !pdpaAccepted
                            ? null
                            : () async {
                                // _registerbloc.add(
                                //   RegisterToClaimYourRightsMockUpSuccessEvent(),
                                // );
                                // return;
                                // _registerbloc.add(
                                //   RegisterToClaimYourRightsMockUpFailureEvent(),
                                // );
                                // return;

                                // ตรวจสอบว่าได้ตรวจสอบสิทธิ์แล้วหรือยัง
                                if (!_registerProvider.isChecked) {
                                  // ToastHelper.showError(
                                  //   context: context,
                                  //   title: 'ยังไม่ได้ตรวจสอบสิทธิ์',
                                  //   description: 'กรุณาตรวจสอบสิทธิ์ก่อนลงทะเบียน',
                                  // );
                                  await AppDialogs.warning(
                                    context,
                                    title: 'ยังไม่ได้ตรวจสอบสิทธิ์',
                                    message: 'กรุณาตรวจสอบสิทธิ์ก่อนลงทะเบียน',
                                  );
                                  await scrollToFormPatientInfo();
                                  return;
                                }

                                // ตรวจสอบแบบประเมิน Barthel ADL (ถ้าจำเป็นต้องทำ)
                                if (_registerProvider
                                    .isBarthelActivityAdlVisible) {
                                  if (!_registerProvider
                                      .isBarthelAdlCompleted) {
                                    // ยังตอบแบบประเมินไม่ครบ
                                    // ToastHelper.showError(
                                    //   context: context,
                                    //   title: 'กรุณาตอบแบบประเมิน',
                                    //   description:
                                    //       'กรุณาตอบแบบประเมินกิจวัตรประจำวันให้ครบทุกข้อ',
                                    // );

                                    await AppDialogs.warning(
                                      context,
                                      title: 'กรุณาตอบแบบประเมิน',
                                      message:
                                          'กรุณาตอบแบบประเมินกิจวัตรประจำวันให้ครบทุกข้อ',
                                    );
                                    await scrollToFormActivity();
                                    return;
                                  }

                                  if (EnvHelper.customerCode != 'samed' &&
                                      !_registerProvider.isBarthelAdlEligible) {
                                    // ตอบครบแล้ว แต่ไม่ผ่านเกณฑ์
                                    // ToastHelper.showError(
                                    //   context: context,
                                    //   title: 'ไม่ผ่านเกณฑ์การประเมิน',
                                    //   description:
                                    //       'ผลการประเมินกิจวัตรประจำวันไม่เข้าเกณฑ์การใช้บริการ',
                                    // );

                                    // await AppDialogs.warning(
                                    //   context,
                                    //   title: 'ไม่ผ่านเกณฑ์การประเมิน',
                                    //   message:
                                    //       'ผลการประเมินกิจวัตรประจำวันไม่เข้าเกณฑ์การใช้บริการ',
                                    // );

                                    bool? isConfirm = await AppDialogs.confirm(
                                      context,
                                      title: 'ไม่ผ่านเกณฑ์การประเมิน',
                                      titleColor: AppColors.error,
                                      isShowIcon: true,
                                      message:
                                          'ผลการประเมินกิจวัตรประจำวันไม่เข้าเกณฑ์การใช้บริการ\n'
                                          'ต้องการทำแบบประเมินใหม่หรือไม่?',
                                      cancelText: 'ยกเลิก',
                                      confirmText: 'ทำแบบประเมินใหม่',
                                    );
                                    if (isConfirm == true) {
                                      // ทำแบบประเมินใหม่
                                      _registerProvider.resetBarthelScores();
                                      await scrollToFormActivity();
                                    }
                                    return;
                                  }
                                }

                                // ตรวจสอบว่ายินยอม PDPA แล้วหรือยัง
                                if (!pdpaAccepted) {
                                  await AppDialogs.warning(
                                    context,
                                    title: 'กรุณายินยอมนโยบาย PDPA',
                                    message:
                                        'กรุณายินยอมให้เก็บและใช้ข้อมูลส่วนบุคคลตามนโยบายคุ้มครองข้อมูลส่วนบุคคล (PDPA)',
                                  );
                                  return;
                                }

                                if (!_registerProvider.formKey.currentState!
                                    .validate()) {
                                  // แสดง Toast แจ้งเตือน
                                  if (context.mounted) {
                                    ToastHelper.showValidationError(
                                      context: context,
                                    );
                                  }
                                  // หา field แรกที่มี error และ scroll ไปหา
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    final context = _registerProvider
                                        .formKey
                                        .currentContext;
                                    if (context != null) {
                                      // หา Widget ที่มี error message
                                      context.visitChildElements((element) {
                                        _findAndScrollToError(element);
                                      });
                                    }
                                  });

                                  return;
                                }

                                // สร้าง FormData ให้ถูกต้อง
                                FormData formData = FormData();
                                // เพิ่มข้อมูลฟิลด์ทั่วไป (requestData ต้องเป็น String)
                                formData.fields.add(
                                  MapEntry(
                                    'data',
                                    jsonEncode(_registerProvider.requestData),
                                  ),
                                );

                                // ===== idCard (ไฟล์เดี่ยว) =====
                                if (_registerProvider.idCardFiles != null) {
                                  final f = _registerProvider.idCardFiles!;
                                  final mime = MimeHelper.getMimeType(
                                    f.extension,
                                  ); // เช่น "image/jpeg"
                                  formData.files.add(
                                    MapEntry(
                                      'idCard', // ✅ ชื่อฟิลด์ต้องเป็น camelCase
                                      MultipartFile.fromBytes(
                                        f.bytes,
                                        filename: f.name,
                                        contentType: mime != null
                                            ? MediaType(
                                                mime.split('/').first,
                                                mime.split('/').last,
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                }

                                // ===== disabilityCard (ไฟล์เดี่ยว) =====
                                if (_registerProvider.disabilityCardFiles !=
                                    null) {
                                  final f =
                                      _registerProvider.disabilityCardFiles!;
                                  final mime = MimeHelper.getMimeType(
                                    f.extension,
                                  );
                                  formData.files.add(
                                    MapEntry(
                                      'disabilityCard',
                                      MultipartFile.fromBytes(
                                        f.bytes,
                                        filename: f.name,
                                        contentType: mime != null
                                            ? MediaType(
                                                mime.split('/').first,
                                                mime.split('/').last,
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                }

                                // ===== thaiStateWelfareCard (ไฟล์เดี่ยว) =====
                                if (_registerProvider
                                        .thaiStateWelfareCardFiles !=
                                    null) {
                                  final f = _registerProvider
                                      .thaiStateWelfareCardFiles!;
                                  final mime = MimeHelper.getMimeType(
                                    f.extension,
                                  );
                                  formData.files.add(
                                    MapEntry(
                                      'thaiStateWelfareCard', // ✅ ชื่อฟิลด์ต้องเป็น camelCase
                                      MultipartFile.fromBytes(
                                        f.bytes,
                                        filename: f.name,
                                        contentType: mime != null
                                            ? MediaType(
                                                mime.split('/').first,
                                                mime.split('/').last,
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                }

                                // ===== houseRegistration (tessaban_angsila) =====
                                for (final f
                                    in _registerProvider
                                        .houseRegistrationFiles) {
                                  final mime = MimeHelper.getMimeType(
                                    f.extension,
                                  );
                                  formData.files.add(
                                    MapEntry(
                                      'houseRegistrations',
                                      MultipartFile.fromBytes(
                                        f.bytes,
                                        filename: f.name,
                                        contentType: mime != null
                                            ? MediaType(
                                                mime.split('/').first,
                                                mime.split('/').last,
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                }

                                // ===== addressConfirmation (tessaban_angsila) =====
                                if (_registerProvider.addressConfirmationFile !=
                                    null) {
                                  final f = _registerProvider
                                      .addressConfirmationFile!;
                                  final mime = MimeHelper.getMimeType(
                                    f.extension,
                                  );
                                  formData.files.add(
                                    MapEntry(
                                      'addressConfirmation',
                                      MultipartFile.fromBytes(
                                        f.bytes,
                                        filename: f.name,
                                        contentType: mime != null
                                            ? MediaType(
                                                mime.split('/').first,
                                                mime.split('/').last,
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                }

                                // ===== otherDocuments (หลายไฟล์) =====
                                for (final f in _registerProvider.otherFiles) {
                                  final mime = MimeHelper.getMimeType(
                                    f.extension,
                                  );
                                  formData.files.add(
                                    MapEntry(
                                      'otherDocuments', // ✅ ชื่อเดียวกันทุกรายการ
                                      MultipartFile.fromBytes(
                                        f.bytes,
                                        filename: f.name,
                                        contentType: mime != null
                                            ? MediaType(
                                                mime.split('/').first,
                                                mime.split('/').last,
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                }
                                _registerbloc.add(
                                  RegisterToClaimYourRightsRequestEvent(
                                    data: formData,
                                  ),
                                );
                              },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _findAndScrollToError(Element element) {
    bool foundError = false;

    // ตรวจสอบว่า element ตัวเองเป็น FormField หรือไม่
    if (element.widget is FormField) {
      final formFieldState = element as StatefulElement;
      final state = formFieldState.state;

      if (state is FormFieldState && state.hasError) {
        // พบ field ที่มี error แล้ว - scroll ไปหา
        Scrollable.ensureVisible(
          element,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.2, // แสดงที่ 20% จากด้านบนของหน้าจอ
        );
        return true;
      }
    }

    // ค้นหาใน children ต่อ
    element.visitChildren((child) {
      if (!foundError) {
        foundError = _findAndScrollToError(child);
      }
    });

    return foundError;
  }

  Future<void> scrollToFormPatientInfo() async {
    final context = _formPatientInfoKey.currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1, // แสดงที่ 10% จากด้านบนของหน้าจอ
      );
    }
  }

  Future<void> scrollToFormActivity() async {
    final context = _formActivityKey.currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: -0.01, // แสดงที่ 10% จากด้านบนของหน้าจอ
      );
    }
  }
}
