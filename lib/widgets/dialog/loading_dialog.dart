import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';

class LoadingDialog {
  LoadingDialog._();
  static void show(BuildContext context, {bool dismissible = false}) {
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: EdgeInsets.zero,
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
                // boxShadow: Shadows.defaultShadow,
              ),
              child: const LoaderWidget(),
            ),
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Duration is millisecond
  static void hideDelayed(
    BuildContext context, {
    int duration = 100,
    VoidCallback? callback,
  }) {
    Future.delayed(Duration(milliseconds: duration), () {
      LoadingDialog.hide(context);
      callback?.call();
    });
  }
}

class LoaderWidget extends StatelessWidget {
  const LoaderWidget({super.key, this.size});
  final double? size;
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 1.5,
      ),
    );
  }
}
