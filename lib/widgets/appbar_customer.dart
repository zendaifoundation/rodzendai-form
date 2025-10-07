import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/services/auth_service.dart';
import 'package:rodzendai_form/widgets/loading_widget.dart';

class AppBarCustomer extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCustomer({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
  });

  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    // ดึง AuthService จาก context
    final authService = context.watch<AuthService>();
    return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary, // สีของ status bar
        statusBarIconBrightness: Brightness.light, // ไอคอนสีขาว (Android)
        statusBarBrightness: Brightness.dark, // ไอคอนสีขาว (iOS)
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showBackButton)
            InkWell(
              onTap: onBackPressed ?? () => context.go('/home'),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  spacing: 4,
                  children: [
                    Icon(Icons.arrow_back, color: AppColors.white, size: 18),
                    Text(
                      'กลับ',
                      style: AppTextStyles.regular.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox.shrink(),
          Spacer(),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bold.copyWith(
                fontSize: 18,
                color: AppColors.white,
              ),
            ),
          ),
          Spacer(),
        ],
      ),
      actions: [
        if (authService.isAuthenticated)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              authService.displayName ?? '-',
              style: const TextStyle(color: AppColors.white, fontSize: 14),
            ),
          ),
      ],
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
