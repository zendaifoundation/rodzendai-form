import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/presentation/register/blocs/register_bloc/register_bloc.dart';
import 'package:rodzendai_form/presentation/register/dialogs/already_register_dialog.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register/views/form_address_info.dart';
import 'package:rodzendai_form/presentation/register/views/form_companion_info.dart';
import 'package:rodzendai_form/presentation/register/views/form_contact_info.dart';
import 'package:rodzendai_form/presentation/register/views/form_patient_info.dart';
import 'package:rodzendai_form/presentation/register/views/form_pickup_location.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';
import 'package:rodzendai_form/widgets/appbar_customer.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';
import 'package:rodzendai_form/widgets/dialog/loading_dialog.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late RegisterProvider _registerProvider;
  late RegisterBloc _registerBloc;

  @override
  void initState() {
    super.initState();
    _registerProvider = RegisterProvider(
      getLocationDetailBloc: context.read<GetLocationDetailBloc>(),
    );
    _registerBloc = RegisterBloc();

    _registerProvider.morkUpData(); // For testing purpose
  }

  @override
  void dispose() {
    _registerProvider.dispose();
    _registerBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _registerBloc,
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
                    context.go('/register-success');
                    _registerProvider.setEnableTapGoogleMap(true);
                    break;
                  case RegisterFailure():
                    LoadingDialog.hide(context);
                    await AlreadyRegisteredDialog.show(context);
                    await Future.delayed(Duration(seconds: 1));
                    _registerProvider.setEnableTapGoogleMap(true);
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
                              Text('กำลังดึงตำแหน่งปัจจุบัน...'),
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
                                  style: TextStyle(color: Colors.red.shade900),
                                ),
                              ),
                              TextButton(
                                onPressed: () => provider.getCurrentLocation(),
                                child: Text('ลองอีกครั้ง'),
                              ),
                            ],
                          ),
                        ),

                      FormContactInfo(
                        registerProvider: _registerProvider,
                      ), // ข้อมูลผู้แจ้ง/ติดต่อ
                      FormCompanionInfo(), // ข้อมูลผู้ติดตาม
                      FormPatientInfo(
                        registerProvider: _registerProvider,
                      ), // ข้อมูลผู้ป่วย
                      FormAddressInfo(
                        registerProvider: _registerProvider,
                      ), // ข้อมูลที่อยู่
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
                              return;
                            }
                            _registerBloc.add(
                              RegisterRequestEvent(
                                data: _registerProvider.requestData,
                                documentAppointmentFile: null,
                              ),
                            );
                          },
                        ),
                      ),
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
