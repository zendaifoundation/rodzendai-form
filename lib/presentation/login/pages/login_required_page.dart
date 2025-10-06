import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';
import 'package:rodzendai_form/core/services/auth_service.dart';

class LoginRequiredPage extends StatelessWidget {
  const LoginRequiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          padding: EdgeInsets.all(32),
          margin: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadow.primaryShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 24,
            children: [
              // Icon & Error Code
              Column(
                spacing: 12,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_person_outlined,
                      size: 60,
                      color: AppColors.error,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '401 Unauthorized',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),

              // Title
              Text(
                'การเข้าถึงถูกปฏิเสธ',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),

              // Description
              Text(
                'คุณต้องเข้าสู่ระบบก่อนเพื่อเข้าถึงหน้านี้\nกรุณาเข้าสู่ระบบผ่านบัญชี LINE ของคุณ',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.text.withOpacity(0.7),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              Divider(color: AppColors.border, thickness: 1),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: authService.isLoading
                      ? null
                      : () async {
                          await authService.login();
                        },
                  icon: authService.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Icon(Icons.login, color: AppColors.white, size: 22),
                  label: Text(
                    authService.isLoading
                        ? 'กำลังเข้าสู่ระบบ...'
                        : 'เข้าสู่ระบบด้วย LINE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00B900), // LINE Green
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    shadowColor: Color(0xFF00B900).withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
