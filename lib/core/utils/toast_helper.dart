import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:toastification/toastification.dart';

/// Helper class สำหรับแสดง Toast Notification
class ToastHelper {
  ToastHelper._();

  /// แสดง Toast แบบ Success
  static void showSuccess({
    required BuildContext context,
    required String title,
    String? description,
    Duration? duration,
    Alignment? alignment,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      description: description != null
          ? Text(description, style: TextStyle(fontSize: 13))
          : null,
      alignment: alignment ?? Alignment.topRight,
      autoCloseDuration: duration ?? Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      boxShadow: highModeShadow,
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }

  /// แสดง Toast แบบ Error
  static void showError({
    required BuildContext context,
    required String title,
    String? description,
    Duration? duration,
    Alignment? alignment,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      description: description != null
          ? Text(description, style: TextStyle(fontSize: 13))
          : null,
      alignment: alignment ?? Alignment.topRight,
      autoCloseDuration: duration ?? Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      boxShadow: highModeShadow,
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }

  /// แสดง Toast แบบ Warning
  static void showWarning({
    required BuildContext context,
    required String title,
    String? description,
    Duration? duration,
    Alignment? alignment,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.flat,
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      description: description != null
          ? Text(description, style: TextStyle(fontSize: 13))
          : null,
      alignment: alignment ?? Alignment.topRight,
      autoCloseDuration: duration ?? Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      boxShadow: highModeShadow,
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }

  /// แสดง Toast แบบ Info
  static void showInfo({
    required BuildContext context,
    required String title,
    String? description,
    Duration? duration,
    Alignment? alignment,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      description: description != null
          ? Text(description, style: TextStyle(fontSize: 13))
          : null,
      alignment: alignment ?? Alignment.topRight,
      autoCloseDuration: duration ?? Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      boxShadow: highModeShadow,
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }

  /// แสดง Toast แบบกำหนดเอง
  static void show({
    required BuildContext context,
    required ToastificationType type,
    required String title,
    String? description,
    ToastificationStyle? style,
    Duration? duration,
    Alignment? alignment,
    bool? showProgressBar,
    bool? pauseOnHover,
    bool? dragToClose,
    bool? applyBlurEffect,
    CloseButtonShowType? closeButtonShowType,
  }) {
    toastification.show(
      context: context,
      type: type,
      style: style ?? ToastificationStyle.flat,
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      description: description != null
          ? Text(description, style: TextStyle(fontSize: 13))
          : null,
      alignment: alignment ?? Alignment.topRight,
      autoCloseDuration: duration ?? Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      boxShadow: highModeShadow,
      showProgressBar: showProgressBar ?? true,
      closeButtonShowType: closeButtonShowType ?? CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: pauseOnHover ?? true,
      dragToClose: dragToClose ?? true,
      applyBlurEffect: applyBlurEffect ?? true,
    );
  }

  /// แสดง Toast แบบ Validation Error (สำหรับ form validation)
  static void showValidationError({
    required BuildContext context,
    String? title,
    String? description,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: Text(
        title ?? 'กรุณากรอกข้อมูลให้ครบถ้วน',
        style: AppTextStyles.bold,
      ),
      description: Text(
        description ?? 'โปรดตรวจสอบข้อมูลให้ครบถ้วน',
        style: AppTextStyles.regular,
      ),
      alignment: Alignment.topRight,
      autoCloseDuration: Duration(seconds: 3),
      borderRadius: BorderRadius.circular(12),
      boxShadow: highModeShadow,
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
    );
  }
}
