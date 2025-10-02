import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';

class BaseCardContainer extends StatelessWidget {
  const BaseCardContainer({super.key, this.child});
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: AppShadow.primaryShadow,
      ),
      child: child,
    );
  }
}
