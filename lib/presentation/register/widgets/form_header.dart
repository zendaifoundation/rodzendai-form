import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';

class FormHeaderWidget extends StatelessWidget {
  const FormHeaderWidget({
    super.key,
    this.title,
    this.subTitle,
    this.value,
    this.onChanged,
  });
  final String? title;
  final String? subTitle;
  final bool? value;
  final void Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onChanged == null) ...[
          Text(
            title ?? '-',
            style: AppTextStyles.bold.copyWith(
              color: AppColors.primary,
              fontSize: 24,
            ),
          ),
          Divider(color: AppColors.secondary.withOpacity(0.16), thickness: 1),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title ?? '-',
                  style: AppTextStyles.bold.copyWith(
                    color: AppColors.primary,
                    fontSize: 24,
                  ),
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Checkbox(
                      value: value,
                      onChanged: onChanged,
                      activeColor: AppColors.primary,
                      checkColor: AppColors.white,
                      side: BorderSide(color: AppColors.textLighter, width: 2),
                    ),
                    //Text('ใช้ข้อมูลผู้แจ้ง/ผู้ติดต่อ'),
                    Text(subTitle ?? '-', style: AppTextStyles.regular),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: AppColors.secondary.withOpacity(0.16), thickness: 1),
        ],
      ],
    );
  }
}
