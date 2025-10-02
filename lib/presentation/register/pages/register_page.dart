import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/presentation/register/views/form_address_info.dart';
import 'package:rodzendai_form/presentation/register/views/form_companion_info.dart';
import 'package:rodzendai_form/presentation/register/views/form_contact_info.dart';
import 'package:rodzendai_form/presentation/register/views/form_patient_info.dart';
import 'package:rodzendai_form/presentation/register/views/form_pickup_location.dart';
import 'package:rodzendai_form/widgets/appbar_customer.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustomer(title: 'ลงทะเบียนใช้บริการ'),
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
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
                  FormContactInfo(), // ข้อมูลผู้แจ้ง/ติดต่อ
                  FormCompanionInfo(), // ข้อมูลผู้ติดตาม
                  FormPatientInfo(), // ข้อมูลผู้ป่วย
                  FormAddressInfo(), // ข้อมูลที่อยู่
                  FormPickupLocation(), // สถานที่รับผู้ป่วย
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
      ),
    );
  }
}
