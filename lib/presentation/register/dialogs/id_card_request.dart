import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/toast_helper.dart';
import 'package:rodzendai_form/presentation/register/blocs/id_card_reader/id_card_reader_bloc.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';
import 'package:rodzendai_form/widgets/dialog/app_dialogs.dart';

class IdCardRequestDialog {
  static Future<IDCardPayload?> show(
    BuildContext context, {
    Map<String, dynamic>? data,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _IdCardRequestDialogView(data: data);
      },
    );
  }
}

class _IdCardRequestDialogView extends StatelessWidget {
  const _IdCardRequestDialogView({this.data});
  final Map<String, dynamic>? data;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      constraints: BoxConstraints(maxWidth: 500),
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.close, color: AppColors.textLighter),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Lottie.asset(
                  'assets/files/id_card_reader.json',
                  height: 120,
                  width: 120,
                ),
                Text(
                  'เสียบเครื่องอ่านบัตรแล้ว',
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(
                  color: AppColors.secondary.withOpacity(0.16),
                  thickness: 1,
                ),
                Text(
                  'กดปุ่ม "อ่านข้อมูลจากบัตร" เพื่อเริ่มอ่านข้อมูลจากบัตรประชาชน',
                  style: AppTextStyles.regular.copyWith(fontSize: 16),
                ),
                SizedBox.shrink(),
                BlocConsumer<IdCardReaderBloc, IdCardReaderState>(
                  listener: (context, state) async {
                    if (state is IDCardReadSuccess) {
                      // await AppDialogs.success(
                      //   context,
                      //   title: 'อ่านข้อมูลจากบัตรสำเร็จ',
                      //   message: 'ระบบอ่านข้อมูลจากบัตรประชาชนสำเร็จ',
                      //   buttonText: 'ตกลง',
                      // );
                      ToastHelper.showSuccess(
                        context: context,
                        title: 'อ่านข้อมูลจากบัตรสำเร็จ',
                        description: 'ระบบอ่านข้อมูลจากบัตรประชาชนสำเร็จ',
                      );
                      await Future.delayed(Duration(milliseconds: 500));

                      Navigator.of(context).pop(state.payload);
                    }
                  },
                  builder: (context, state) {
                    bool loading = state is IDCardReading;
                    return ButtonCustom(
                      text: loading
                          ? 'กำลังอ่านข้อมูลจากบัตร...'
                          : 'อ่านข้อมูลจากบัตร',
                      backgroundColor: loading
                          ? AppColors.grey
                          : AppColors.primary,
                      onPressed: loading
                          ? null
                          : () async {
                              context.read<IdCardReaderBloc>().add(
                                IDCardReadRequested(),
                              );
                            },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
