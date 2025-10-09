import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';

class AlreadyRegisteredDialog {
  static Future<void> show(
    BuildContext context, {
    Map<String, dynamic>? data,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _AlreadyRegisteredDialogView(data: data);
      },
    );
  }
}

class _AlreadyRegisteredDialogView extends StatelessWidget {
  const _AlreadyRegisteredDialogView({this.data});
  final Map<String, dynamic>? data;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      constraints: BoxConstraints(maxWidth: 500),
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.close, color: AppColors.textLighter),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                Text(
                  'ท่านลงทะเบียนวันนัดนี้แล้ว',
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.red,
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
                        'nationalId': data?['patientIdCard'], //nationalId
                        'date': data?['appointmentDate'], //appointmentDate
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
