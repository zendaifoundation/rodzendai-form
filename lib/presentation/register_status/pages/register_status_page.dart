import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';

class RegisterStatusPage extends StatelessWidget {
  const RegisterStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'บริการรถรับ-ส่งผู้ป่วย',
          style: TextStyle(
            fontSize: 20,
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.white,
      body: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 600),
        child: const Center(
          child: Text(
            'หน้าตรวจสอบสถานะการจอง (Register Status Page)',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
