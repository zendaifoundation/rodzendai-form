import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/core/utils/toast_helper.dart';
import 'package:rodzendai_form/presentation/blocs/province_bloc/province_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/blocs/data_patient_bloc/data_patient_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/blocs/register_to_claim_your_rights_bloc/register_to_claim_your_rights_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_address_info.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_companion_info.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_current_address_info.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_patient_info.dart';
import 'package:rodzendai_form/repositories/firebase_repository.dart';
import 'package:rodzendai_form/repositories/firebase_storeage_repository.dart';
import 'package:rodzendai_form/widgets/appbar_customer.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';
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
  late DataPatientBloc _dataPatientBloc;
  final GlobalKey _formPatientInfoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // _registerbloc = RegisterToClaimYourRightsBloc(
    //   firebaseRepository: locator<FirebaseRepository>(),
    //   firebaseStorageRepository: locator<FirebaseStorageRepository>(),
    // );
    _registerProvider = RegisterToClaimYourRightsProvider();
    _dataPatientBloc = DataPatientBloc();

    _registerProvider.morkData();
  }

  @override
  Widget build(BuildContext context) {
    _registerbloc = RegisterToClaimYourRightsBloc(
      firebaseRepository: locator<FirebaseRepository>(),
      firebaseStorageRepository: locator<FirebaseStorageRepository>(),
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider<DataPatientBloc>.value(
          value: _dataPatientBloc..add(LoadDataPatientsEvent()),
        ),
        BlocProvider<ProvinceBloc>(
          create: (context) => ProvinceBloc()
            ..add(
              ProvinceRequested(
                selectedProvinceId: _registerProvider.registeredProvinceId,
              ),
            ),
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
                    ToastHelper.showSuccess(
                      context: context,
                      title: 'ลงทะเบียนสำเร็จ',
                    );
                    break;
                  case RegisterToClaimYourRightsFailure():
                    LoadingDialog.hide(context);
                    ToastHelper.showError(
                      context: context,
                      title: 'ลงทะเบียนไม่สำเร็จ',
                      description: state.message,
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
            constraints: BoxConstraints(maxWidth: 600),
            child: Form(
              key: _registerProvider.formKey,
              child: Column(
                spacing: 16,
                children: [
                  FormPatientInfo(
                    key: _formPatientInfoKey,
                    registerProvider: _registerProvider,
                  ),
                  FormAddressInfo(),
                  FormCurrentAddressInfo(),
                  FormCompanionInfo(),
                  SizedBox.shrink(),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ButtonCustom(
                      text: 'ลงทะเบียน',
                      onPressed: () async {
                        if (!_registerProvider.isChecked) {
                          ToastHelper.showError(
                            context: context,
                            title: 'ยังไม่ได้ตรวจสอบสิทธิ์',
                            description: 'กรุณาตรวจสอบสิทธิ์ก่อนลงทะเบียน',
                          );

                          await scrollToFormPatientInfo();

                          return;
                        }
                        if (!_registerProvider.formKey.currentState!
                            .validate()) {
                          // แสดง Toast แจ้งเตือน
                          if (context.mounted) {
                            ToastHelper.showValidationError(context: context);
                          }
                          // หา field แรกที่มี error และ scroll ไปหา
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final context =
                                _registerProvider.formKey.currentContext;
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
                        // เพิ่มไฟล์
                        for (var file in _registerProvider.uploadedFiles) {
                          log('Uploading file: ${file.name}');
                          log('Uploading file: ${file.extension}');
                          // พยายามหา mime type จากนามสกุลไฟล์
                          final mime = MimeHelper.getMimeType(file.extension);
                          formData.files.add(
                            MapEntry(
                              'documents',
                              MultipartFile.fromBytes(
                                file.bytes,
                                filename: file.name,
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
                          RegisterToClaimYourRightsRequestEvent(data: formData),
                        );
                      },
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
}
