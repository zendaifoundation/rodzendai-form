import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';

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
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showBackButton)
            InkWell(
              onTap: onBackPressed ?? () => context.go('/'),
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
          Text(
            title,
            style: AppTextStyles.bold.copyWith(
              fontSize: 20,
              color: AppColors.white,
            ),
          ),
          Spacer(),
        ],
      ),
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
