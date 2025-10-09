import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
        color: AppColors.primary,
      ),
    );
  }
}
