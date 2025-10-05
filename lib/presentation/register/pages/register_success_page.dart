import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';

class RegisterSuccessPage extends StatelessWidget {
  const RegisterSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    'เลขบัตรประชาชนที่ลงทะเบียน : 123123123123123', //nationalId
                    style: AppTextStyles.regular.copyWith(fontSize: 16),
                  ),
                  ButtonCustom(
                    text: '🏠 กลับหน้าหลัก',
                    onPressed: () {
                      context.go('/home');
                    },
                  ),

                  ButtonCustom(
                    text: '🔍 ตรวจสอบสถานะ',
                    backgroundColor: AppColors.warning,
                    onPressed: () async {
                      context.go(
                        '/register-status',
                        extra: {
                          'nationalId': '123123123123123', //nationalId
                          'date': '',
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
