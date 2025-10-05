import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/widgets/loading_widget.dart';

class ButtonCustom extends StatelessWidget {
  const ButtonCustom({
    super.key,
    this.text,
    this.onPressed,
    this.isGradient = false,
    this.backgroundColor = AppColors.primary,
    this.isLoading = false,
    this.icon,
  });
  final String? text;
  final VoidCallback? onPressed;
  final bool isGradient;
  final Color backgroundColor;
  final bool isLoading;
  final Widget? icon;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isGradient
            ? const LinearGradient(
                colors: [Color(0xFF194BFD), Color(0xFFAD13FB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isGradient ? Colors.transparent : backgroundColor,
          shadowColor: isGradient ? Colors.transparent : backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          //  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? SizedBox(height: 32, width: 32, child: LoadingWidget())
            : Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  if (icon != null) icon ?? SizedBox.shrink(),
                  Flexible(
                    child: Text(
                      text ?? 'Button Custom',
                      style: AppTextStyles.medium
                          .copyWith(fontSize: 16)
                          .copyWith(color: AppColors.white),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
