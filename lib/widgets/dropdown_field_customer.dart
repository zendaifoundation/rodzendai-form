import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/widgets/required_label.dart';

class DropdownFieldCustomer<T> extends StatelessWidget {
  final String? label;
  final String? hintText;
  final bool isRequired;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final Widget? suffixIcon;

  const DropdownFieldCustomer({
    super.key,
    required this.label,
    this.hintText,
    this.isRequired = false,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        if (label != null)
          RequiredLabel(text: label ?? '-', isRequired: isRequired),

        // Dropdown Field with Hover Effect
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: DropdownButtonFormField<T>(
            initialValue: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.regular.copyWith(
                color: AppColors.textLighter,
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red, width: 1),
              ),
            ),
            style: AppTextStyles.regular,
            dropdownColor: AppColors.white,
            icon: const Icon(Icons.arrow_drop_down),
            menuMaxHeight: 500,
            errorBuilder: (context, errorText) {
              return Text(
                errorText,
                style: AppTextStyles.regular.copyWith(
                  color: Colors.red,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
