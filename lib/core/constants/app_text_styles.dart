import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Roboto';
  static const double _fontSize = 14.0;
  static const FontWeight _fontWeight = FontWeight.normal;

  static const TextStyle regular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _fontSize,
    fontWeight: _fontWeight,
    color: AppColors.text,
  );

  static const TextStyle medium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _fontSize,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  static const TextStyle bold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _fontSize,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
}
