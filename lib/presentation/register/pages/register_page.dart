import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/core/utils/toast_helper.dart';
import 'package:rodzendai_form/presentation/register/blocs/get_patient_bloc/get_patient_bloc.dart';
import 'package:rodzendai_form/presentation/register/blocs/id_card_reader/id_card_reader_bloc.dart';
import 'package:rodzendai_form/presentation/register/blocs/register_bloc/register_bloc.dart';
import 'package:rodzendai_form/presentation/register/dialogs/already_register_dialog.dart';
import 'package:rodzendai_form/presentation/register/dialogs/id_card_request.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register/views/form_appointment_info.dart';
import 'package:rodzendai_form/presentation/register/views/form_companion_info.dart';
import 'package:rodzendai_form/presentation/register/views/form_contact_info.dart';
import 'package:rodzendai_form/presentation/register/views/form_patient_info.dart';
import 'package:rodzendai_form/presentation/register/views/form_pickup_location.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';
import 'package:rodzendai_form/repositories/firebase_repository.dart';
import 'package:rodzendai_form/repositories/firebase_storeage_repository.dart';
import 'package:rodzendai_form/widgets/appbar_customer.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';
import 'package:rodzendai_form/widgets/dialog/app_dialogs.dart';
import 'package:rodzendai_form/widgets/dialog/loading_dialog.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late RegisterProvider _registerProvider;
  late RegisterBloc _registerBloc;
  late GetPatientBloc _getPatientBloc;
  late final IdCardReaderBloc _idCardReaderBloc;

  @override
  void initState() {
    super.initState();
    _registerProvider = RegisterProvider(
      getLocationDetailBloc: context.read<GetLocationDetailBloc>(),
    );
    _idCardReaderBloc = context.read<IdCardReaderBloc>();
    _registerBloc = RegisterBloc(
      firebaseRepository: locator<FirebaseRepository>(),
      firebaseStorageRepository: locator<FirebaseStorageRepository>(),
    );
    _getPatientBloc = GetPatientBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(seconds: 1));
      _idCardReaderBloc.add(IDCardConnectRequested());
    });
    //  _registerProvider.mockUpData(); // For testing purpose
  }

  @override
  void dispose() {
    _registerProvider.dispose();
    _registerBloc.close();
    _idCardReaderBloc.add(IDCardResetRequested());
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _registerBloc),
        BlocProvider.value(value: _getPatientBloc),
      ],
      child: ChangeNotifierProvider.value(
        value: _registerProvider,
        child: MultiBlocListener(
          listeners: [
            BlocListener<RegisterBloc, RegisterState>(
              bloc: _registerBloc,
              listener: (context, state) async {
                switch (state) {
                  case RegisterInitial():
                    break;
                  case RegisterLoading():
                    LoadingDialog.show(context);
                    _registerProvider.setEnableTapGoogleMap(false);
                    break;
                  case RegisterSuccess():
                    LoadingDialog.hide(context);
                    context.go(
                      '/register-success',
                      extra: {
                        'patientIdCard':
                            _registerProvider.requestData['patientIdCard'],
                        'appointmentDate':
                            _registerProvider.requestData['appointmentDate'],
                      },
                    );
                    _registerProvider.setEnableTapGoogleMap(true);
                    break;
                  case RegisterFailure():
                    LoadingDialog.hide(context);
                    await AlreadyRegisteredDialog.show(
                      context,
                      data: {
                        'patientIdCard':
                            _registerProvider.requestData['patientIdCard'],
                        'appointmentDate':
                            _registerProvider.requestData['appointmentDate'],
                      },
                    );
                    await Future.delayed(Duration(seconds: 1));
                    _registerProvider.setEnableTapGoogleMap(true);
                    break;
                }
              },
            ),

            BlocListener<IdCardReaderBloc, IdCardReaderState>(
              listener: (context, state) async {
                log('IdCardReaderBloc listener -> //');
                if (state is IDCardReaderReady) {
                  IDCardPayload? idCardPayload = await IdCardRequestDialog.show(
                    context,
                  );
                  if (idCardPayload != null) {
                    _registerProvider.setPatientInfoFromIDCard(idCardPayload);
                  }
                }
              },
            ),

            BlocListener<GetPatientBloc, GetPatientState>(
              bloc: _getPatientBloc,
              listener: (context, state) async {
                switch (state) {
                  case GetPatientInitial():
                    break;
                  case GetPatientLoading():
                    LoadingDialog.show(context);
                    _registerProvider.setPatientData(null);
                    break;
                  case GetPatientSuccess():
                    LoadingDialog.hide(context);
                    await AppDialogs.success(
                      context,
                      title: 'สามารถใช้บริการจองรถได้',
                      message:
                          'จำนวนสิทธิ์คงเหลือ: ${state.patientData?.remainingRights ?? 0} ครั้ง',
                    );
                    _registerProvider.setPatientData(state.patientData);

                    break;
                  case GetPatientFailure():
                    LoadingDialog.hide(context);
                    await AppDialogs.error(
                      context,
                      title: 'ไม่สามารถใช้บริการจองรถได้',
                      message: state.message,
                    );
                    break;
                }
              },
            ),
          ],
          child: _view(),
        ),
      ),
    );
  }

  Scaffold _view() {
    return Scaffold(
      appBar: AppBarCustomer(title: 'ลงทะเบียนใช้บริการ'),
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Consumer<RegisterProvider>(
              builder: (context, provider, child) {
                return Form(
                  key: provider.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 16,
                    children: [
                      // แสดงสถานะการโหลดตำแหน่ง
                      if (provider.isLoadingLocation)
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'กำลังดึงตำแหน่งปัจจุบัน...',
                                style: AppTextStyles.regular,
                              ),
                            ],
                          ),
                        ),

                      // แสดงข้อผิดพลาด
                      if (provider.locationError != null)
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  provider.locationError!,
                                  style: AppTextStyles.regular.copyWith(
                                    color: AppColors.red,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => provider.getCurrentLocation(),
                                child: Text(
                                  'ลองอีกครั้ง',
                                  style: AppTextStyles.regular,
                                ),
                              ),
                            ],
                          ),
                        ),
                      FormPatientInfo(
                        registerProvider: _registerProvider,
                        getPatientBloc: _getPatientBloc,
                      ), // ข้อมูลผู้ป่วย
                      if (_registerProvider.patientData != null) ...[
                        FormAppointmentInfo(
                          registerProvider: _registerProvider,
                        ), // ข้อมูลการนัดหมาย
                        FormContactInfo(
                          registerProvider: _registerProvider,
                        ), // ข้อมูลผู้แจ้ง/ติดต่อ
                        FormCompanionInfo(), // ข้อมูลผู้ติดตาม
                        // FormAddressInfo(
                        //   registerProvider: _registerProvider,
                        // ), // ข้อมูลที่อยู่
                        FormPickupLocation(
                          registerProvider: _registerProvider,
                        ), // สถานที่รับผู้ป่วย
                        SizedBox.shrink(),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ButtonCustom(
                            text: 'ลงทะเบียนการจองรถ',
                            onPressed: () async {
                              if (!provider.formKey.currentState!.validate()) {
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
                                  final context =
                                      provider.formKey.currentContext;
                                  if (context != null) {
                                    // หา Widget ที่มี error message
                                    context.visitChildElements((element) {
                                      _findAndScrollToError(element);
                                    });
                                  }
                                });

                                return;
                              }

                              // log(
                              //   '_registerProvider.requestData -> ${json.encode(_registerProvider.requestData)}',
                              // );

                              _registerBloc.add(
                                RegisterRequestEvent(
                                  data: _registerProvider.requestData,
                                  documentAppointmentFile:
                                      _registerProvider.uploadedFile,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
