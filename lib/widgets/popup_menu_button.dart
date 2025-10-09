import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/services/auth_service.dart';

class CustomPopupMenuButton extends StatelessWidget {
  const CustomPopupMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    // ดึง AuthService จาก context
    final authService = context.watch<AuthService>();
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColors.white),
      offset: Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: AppColors.white,
      padding: EdgeInsets.symmetric(vertical: 8),
      onSelected: (value) async {
        if (value == 'logout') {
          // แสดง dialog ยืนยัน
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.white,
              title: Text('ออกจากระบบ'),
              content: Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'ยกเลิก',
                    style: AppTextStyles.regular.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'ออกจากระบบ',
                    style: AppTextStyles.regular.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          );

          if (confirmed == true && context.mounted) {
            await authService.logout();
            if (context.mounted) {
              context.go('/');
            }
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: AppColors.error),
              SizedBox(width: 12),
              Text(
                'ออกจากระบบ',
                style: AppTextStyles.regular.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
