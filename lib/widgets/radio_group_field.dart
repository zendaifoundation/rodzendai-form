import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/widgets/required_label.dart';

/// Widget สำหรับ Radio Button Group พร้อม validation
class RadioGroupField<T> extends FormField<T> {
  RadioGroupField({
    super.key,
    required List<RadioOption<T>> options,
    required T? value,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
    bool isRequired = false,
    String label = '',
  }) : super(
         initialValue: value,
         validator: validator,
         builder: (FormFieldState<T> state) {
           // ใช้ค่าจาก parameter แทน state.value เพื่อให้ sync กับ provider
           final currentValue = value ?? state.value;

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             spacing: 8,
             children: [
               // Label
               if (label.isNotEmpty)
                 RequiredLabel(text: label, isRequired: isRequired),
               // Radio buttons
               Wrap(
                 spacing: 8,
                 runSpacing: 8,
                 children: options.map((option) {
                   return InkWell(
                     onTap: () {
                       onChanged(option.value);
                       state.didChange(option.value);
                     },
                     borderRadius: BorderRadius.circular(8),
                     child: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Radio<T>(
                           value: option.value,
                           groupValue: currentValue,
                           onChanged: (T? newValue) {
                             onChanged(newValue);
                             state.didChange(newValue);
                           },
                           activeColor: AppColors.primary,
                         ),
                         Text(option.label, style: AppTextStyles.regular),
                         if (option.icon != null) ...[
                           const SizedBox(width: 4),
                           Icon(option.icon, size: 16),
                         ],
                       ],
                     ),
                   );
                 }).toList(),
               ),

               // Error message
               if (state.hasError)
                 Padding(
                   padding: const EdgeInsets.only(left: 12),
                   child: Text(
                     state.errorText!,
                     style: AppTextStyles.regular.copyWith(
                       color: Colors.red,
                       fontSize: 12,
                     ),
                   ),
                 ),
             ],
           );
         },
       );
}

/// Model สำหรับ Radio Option
class RadioOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const RadioOption({required this.value, required this.label, this.icon});
}
