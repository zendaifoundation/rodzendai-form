import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/presentation/register/providers/register_provider.dart';
import 'package:rodzendai_form/presentation/register/views/form_address_info.dart';
import 'package:rodzendai_form/presentation/register/views/form_companion_info.dart';
import 'package:rodzendai_form/presentation/register/views/form_contact_info.dart';
import 'package:rodzendai_form/presentation/register/views/form_patient_info.dart';
import 'package:rodzendai_form/presentation/register/views/form_pickup_location.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';
import 'package:rodzendai_form/widgets/appbar_customer.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late RegisterProvider _registerProvider;

  @override
  void initState() {
    super.initState();
    _registerProvider = RegisterProvider(
      getLocationDetailBloc: context.read<GetLocationDetailBloc>(),
    );
  }

  @override
  void dispose() {
    _registerProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _registerProvider,
      child: Scaffold(
        appBar: AppBarCustomer(title: 'ลงทะเบียนใช้บริการ'),
        backgroundColor: AppColors.white,
        body: Consumer<RegisterProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: 600),
                    alignment: Alignment.center,
                    child: Column(
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
                                    style: TextStyle(
                                      color: Colors.red.shade900,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      provider.getCurrentLocation(),
                                  child: Text('ลองอีกครั้ง'),
                                ),
                              ],
                            ),
                          ),

                        // FormContactInfo(
                        //   registerProvider: _registerProvider,
                        // ), // ข้อมูลผู้แจ้ง/ติดต่อ
                        // FormCompanionInfo(
                        //   registerProvider: _registerProvider,
                        // ), // ข้อมูลผู้ติดตาม
                        // FormPatientInfo(
                        //   registerProvider: _registerProvider,
                        // ), // ข้อมูลผู้ป่วย
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
                              // Handle form submission
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
