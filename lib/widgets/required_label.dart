import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';

class RequiredLabel extends StatelessWidget {
  const RequiredLabel({
    super.key,
    required this.text,
    this.isRequired = true,
    this.textStyle,
    this.requiredColor,
  });

  final String text;
  final bool isRequired;
  final TextStyle? textStyle;
  final Color? requiredColor;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style:
            textStyle ?? AppTextStyles.bold.copyWith(color: AppColors.text),
        children: [
          TextSpan(text: text),
          if (isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(
                color:
                    requiredColor ??
                    const Color(0xFFFF6161), // rgb(255, 97, 97)
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
