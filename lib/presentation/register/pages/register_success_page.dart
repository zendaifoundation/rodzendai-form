import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/date_helper.dart';
import 'package:rodzendai_form/models/create_appointment_response_model.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';

class RegisterSuccessPage extends StatelessWidget {
  const RegisterSuccessPage({
    super.key,
    this.patientIdCard,
    this.appointmentDate,
    this.appointmentDates,
  });
  final String? patientIdCard;
  final String? appointmentDate;
  final List<AppointmentDateModel>? appointmentDates;

  @override
  Widget build(BuildContext context) {
    log('appointmentDates -> ${appointmentDates?.length}');
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: AppShadow.primaryShadow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 24,
                children: [
                  Lottie.asset(
                    'assets/files/success.json',
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'ท่านลงทะเบียนเรียบร้อยแล้ว',
                    style: TextStyle(
                      fontSize: 24,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(
                    color: AppColors.secondary.withOpacity(0.16),
                    thickness: 1,
                  ),
                  Text(
                    'กรุณารอเจ้าหน้าที่ติดต่อกลับเพื่อจองคิวรถ',
                    style: AppTextStyles.regular.copyWith(fontSize: 16),
                  ),
                  Text(
                    'เลขบัตรประชาชนที่ลงทะเบียน : ${patientIdCard ?? '-'}', //nationalId
                    style: AppTextStyles.regular.copyWith(fontSize: 16),
                  ),
                  if (appointmentDates != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: List<Widget>.generate(appointmentDates!.length, (
                        index,
                      ) {
                        final appointment = appointmentDates![index];
                        return Text(
                          'วันที่นัดหมาย ${(appointmentDates?.length ?? 0) > 1 ? index + 1 : ''} : ${DateHelper.dateTimeThaiFullDefault(appointment.date?.millisecondsSinceEpoch)} เวลา ${appointment.time ?? '-'} น.',
                          style: AppTextStyles.regular.copyWith(fontSize: 16),
                        );
                      }),
                    )
                  else
                    Text(
                      'วันที่นัดหมาย : ${DateHelper.dateTimeThaiFullDefault(DateTime.tryParse(appointmentDate ?? '')?.millisecondsSinceEpoch)}', //nationalId
                      style: AppTextStyles.regular.copyWith(fontSize: 16),
                    ),
                  ButtonCustom(
                    text: 'กลับหน้าหลัก',
                    icon: Icon(Icons.home, color: AppColors.white),

                    onPressed: () {
                      context.go('/home');
                    },
                  ),

                  ButtonCustom(
                    text: 'ตรวจสอบสถานะ',
                    backgroundColor: AppColors.warning,
                    icon: Icon(Icons.search, color: AppColors.white),
                    onPressed: () async {
                      context.go(
                        '/register-status',
                        extra: {
                          'nationalId': patientIdCard, //nationalId
                          'date': appointmentDate,
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
