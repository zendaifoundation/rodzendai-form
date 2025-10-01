import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/widgets/required_label.dart';

class TextFormFiledCustom extends StatelessWidget {
  const TextFormFiledCustom({
    super.key,
    this.label,
    this.hintText,
    this.isReadOnly = false,
    this.onTap,
    this.suffixIcon,
    this.controller,
    this.inputFormatters,
    this.keyboardType,
  });
  final String? label;
  final String? hintText;
  final bool isReadOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        if (label != null) RequiredLabel(text: label ?? '-'),
        TextFormField(
          onTap: onTap,
          readOnly: isReadOnly,
          controller: controller,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            helperStyle: AppTextStyles.regular.copyWith(
              color: AppColors.textLighter,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.textLighter, width: 1),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
