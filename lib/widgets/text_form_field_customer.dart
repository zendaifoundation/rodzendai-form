import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/widgets/required_label.dart';

class TextFormFielddCustom extends StatelessWidget {
  const TextFormFielddCustom({
    super.key,
    this.label,
    this.hintText,
    this.isReadOnly = false,
    this.onTap,
    this.suffixIcon,
    this.controller,
    this.inputFormatters,
    this.keyboardType,
    this.validator,
    this.isRequired,
    this.maxLines,
    this.minLines,
  });
  final String? label;
  final String? hintText;
  final bool isReadOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool? isRequired;
  final int? maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        if (label != null)
          RequiredLabel(text: label ?? '-', isRequired: isRequired ?? true),
        TextFormField(
          onTap: onTap,
          readOnly: isReadOnly,
          controller: controller,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          maxLines: maxLines,
          minLines: minLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.regular.copyWith(
              color: AppColors.textLighter,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border, width: 1),
            ),
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
