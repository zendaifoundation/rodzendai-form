import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';

class AppDialogs {
  AppDialogs._();

  static Future<void> success(
    BuildContext context, {
    String title = 'Success',
    required String message,
    String buttonText = 'OK',
    VoidCallback? onOk,
    bool dismissible = true,
  }) async {
    return _baseDialog(
      context,
      dismissible: dismissible,
      icon: const Icon(
        Icons.check_circle_rounded,
        color: Colors.green,
        size: 42,
      ),
      title: title,
      message: message,
      primaryText: buttonText,
      primaryColor: Colors.green,
      onPrimary: onOk,
      maxWidth: 360,
    );
  }

  static Future<void> warning(
    BuildContext context, {
    String title = 'Warning',
    required String message,
    String buttonText = 'OK',
    VoidCallback? onOk,
    bool dismissible = true,
  }) async {
    return _baseDialog(
      context,
      dismissible: dismissible,
      icon: Image.asset('assets/images/img_warning.png', width: 42, height: 42),
      iconBg: Colors.transparent,
      title: title,
      message: message,
      primaryText: buttonText,
      primaryColor: AppColors.primary,
      onPrimary: onOk,
      maxWidth: 360,
    );
  }

  static Future<void> error(
    BuildContext context, {
    String title = 'Error',
    required String message,
    String buttonText = 'OK',
    VoidCallback? onOk,
    bool dismissible = true,
  }) async {
    return _baseDialog(
      context,
      dismissible: dismissible,
      icon: const Icon(Icons.error_rounded, color: Colors.red, size: 42),
      iconBg: AppColors.red,
      title: title,
      message: message,
      primaryText: buttonText,
      primaryColor: AppColors.red,
      onPrimary: onOk,
      maxWidth: 360,
    );
  }

  static Future<bool?> confirm(
    BuildContext context, {
    String title = 'Confirm',
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color confirmColor = AppColors.primary,
    bool dismissible = false,
  }) async {
    bool? result;
    await _baseDialog(
      context,
      dismissible: dismissible,
      title: title,
      message: message,
      primaryText: confirmText,
      secondaryText: cancelText,
      primaryColor: confirmColor,
      onPrimary: () => result = true,
      onSecondary: () => result = false,
      maxWidth: 360,
    );
    return result;
  }

  static Future<void> _baseDialog(
    BuildContext context, {
    Widget? icon,
    Color? iconBg,
    required String title,
    required String message,
    required String primaryText,
    Color? primaryColor,
    VoidCallback? onPrimary,
    String? secondaryText,
    VoidCallback? onSecondary,
    bool dismissible = true,
    double? maxWidth,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          backgroundColor: AppColors.white,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 280,
              maxWidth: maxWidth ?? double.infinity,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8,
                children: [
                  Row(
                    spacing: 8,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (icon != null) icon,
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bold.copyWith(
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.medium,
                  ),
                  const SizedBox.shrink(),
                  Row(
                    spacing: 16,
                    children: [
                      if (secondaryText != null)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide(
                                color: AppColors.grey.withOpacity(0.4),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              onSecondary?.call();
                            },
                            child: Text(
                              secondaryText,
                              style: AppTextStyles.medium.copyWith(
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),

                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor ?? AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            onPrimary?.call();
                          },
                          child: Text(
                            primaryText,
                            style: AppTextStyles.medium.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
