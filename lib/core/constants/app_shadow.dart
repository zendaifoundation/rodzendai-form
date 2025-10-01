import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';

class AppShadow {
  AppShadow._();

  static List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: AppColors.black.withOpacity(0.1),
      spreadRadius: 1,
      blurRadius: 1,
      offset: const Offset(0, 1),
    ),
  ];
}
