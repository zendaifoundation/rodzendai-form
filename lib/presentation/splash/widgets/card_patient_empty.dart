import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';

class CardPatientEmpty extends StatelessWidget {
  const CardPatientEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(48),
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 600),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: AppShadow.primaryShadow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        spacing: 8,
        children: [
          Text(
            '🔍',
            style: AppTextStyles.bold.copyWith(
              color: AppColors.black,
              fontSize: 48,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ไม่พบข้อมูลการจอง',
            style: AppTextStyles.bold.copyWith(
              color: AppColors.black,
              fontSize: 20,
            ),
          ),
          Text(
            'ไม่พบการจองที่ตรงกับเลขบัตรประชาชนและวันที่เดินทางที่ระบุ',
            style: AppTextStyles.medium.copyWith(
              color: AppColors.text,
              fontSize: 16,
            ),
          ),
          Text(
            'กรุณาตรวจสอบข้อมูลอีกครั้ง หรือติดต่อเจ้าหน้าที่',
            style: AppTextStyles.medium.copyWith(
              color: AppColors.text,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
