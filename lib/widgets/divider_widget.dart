import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';

class DividerCustom extends StatelessWidget {
  const DividerCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(color: AppColors.secondary.withOpacity(0.16), thickness: 1);
  }
}
