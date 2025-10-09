import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';

class FormHeaderWidget extends StatelessWidget {
  const FormHeaderWidget({super.key, this.title});
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? '-',
          style: AppTextStyles.bold.copyWith(
            color: AppColors.primary,
            fontSize: 24,
          ),
        ),
        Divider(color: AppColors.secondary.withOpacity(0.16), thickness: 1),
      ],
    );
  }
}
