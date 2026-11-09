import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/presentation/ocr_test/blocs/ocr_bloc/ocr_bloc.dart';
import 'package:rodzendai_form/presentation/id_card/widgets/id_card_picker_box.dart';
import 'package:rodzendai_form/presentation/ocr_test/widgets/ocr_result_card.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_file_widget.dart';
import 'package:rodzendai_form/repositories/ocr_repository.dart';
import 'package:rodzendai_form/widgets/appbar_customer.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';

/// หน้า TEST OCR — อัปโหลดรูปบัตรประชาชนแล้วส่งไป OCR ที่ back-end
///
/// แยกออกมาเป็น feature เดี่ยวเพื่อทดสอบคุณภาพ OCR ก่อนนำไปผูกกับ
/// step "เอกสารยืนยันตัวตน" ในหน้าลงทะเบียนรับสิทธิ์
class OcrTestPage extends StatelessWidget {
  const OcrTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => OcrBloc(), child: const _OcrTestView());
  }
}

class _OcrTestView extends StatefulWidget {
  const _OcrTestView();

  @override
  State<_OcrTestView> createState() => _OcrTestViewState();
}

class _OcrTestViewState extends State<_OcrTestView> {
  UploadedFile? _file;

  void _onFileChanged(UploadedFile? file) {
    setState(() => _file = file);
    // เปลี่ยนไฟล์แล้วล้างผลเดิมทิ้ง
    context.read<OcrBloc>().add(const OcrResetRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustomer(title: 'TEST OCR บัตรประชาชน'),
      backgroundColor: AppColors.bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: BlocBuilder<OcrBloc, OcrState>(
              builder: (context, state) {
                final isLoading = state is OcrLoading;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    BaseCardContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          Text(
                            'อัปโหลดบัตรประชาชนเพื่อทดสอบ OCR',
                            style: AppTextStyles.bold.copyWith(fontSize: 18),
                          ),
                          SelectableText(
                            'POST ${OcrRepository.endpointUrl}?provider=google',
                            style: AppTextStyles.regular.copyWith(
                              fontSize: 12,
                              color: AppColors.textLighter,
                            ),
                          ),
                          if (!EnvHelper.isOcrConfigured)
                            Text(
                              'ยังไม่ได้ตั้งค่า OCR_URL / OCR_KEY ใน .env '
                              '(ต้อง restart แอปหลังแก้)',
                              style: AppTextStyles.regular.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          IdCardPickerBox(
                            value: _file,
                            enabled: !isLoading,
                            onChanged: _onFileChanged,
                          ),
                          Row(
                            spacing: 8,
                            children: [
                              Expanded(
                                child: ButtonCustom(
                                  text: 'เริ่ม OCR',
                                  isLoading: isLoading,
                                  icon: const Icon(
                                    Icons.document_scanner_outlined,
                                    color: AppColors.white,
                                    size: 18,
                                  ),
                                  onPressed: _file == null || isLoading
                                      ? null
                                      : () => context.read<OcrBloc>().add(
                                          OcrReadIdCardRequested(
                                            _file!,
                                            provider: OcrProvider.google,
                                          ),
                                        ),
                                ),
                              ),
                              if (state is! OcrInitial && !isLoading)
                                ButtonCustom(
                                  text: 'ล้างผล',
                                  backgroundColor: AppColors.secondary,
                                  onPressed: () => context.read<OcrBloc>().add(
                                    const OcrResetRequested(),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    switch (state) {
                      OcrLoading() => BaseCardContainer(
                        child: Row(
                          spacing: 12,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            Text(
                              'กำลังอ่านบัตร... (ปกติ 3-12 วินาที)',
                              style: AppTextStyles.regular,
                            ),
                          ],
                        ),
                      ),
                      OcrSuccess(:final result, :final elapsed) =>
                        OcrResultCard(result: result, elapsed: elapsed),
                      OcrFailure(:final error, :final elapsed) =>
                        BaseCardContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'OCR ไม่สำเร็จ',
                                      style: AppTextStyles.bold.copyWith(
                                        fontSize: 18,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${elapsed.inMilliseconds} ms',
                                    style: AppTextStyles.regular.copyWith(
                                      color: AppColors.textLighter,
                                    ),
                                  ),
                                ],
                              ),
                              SelectableText(
                                error.message,
                                style: AppTextStyles.regular,
                              ),
                              SelectableText(
                                'code: ${error.code}'
                                '${error.statusCode != null ? ' • http ${error.statusCode}' : ''}',
                                style: AppTextStyles.regular.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textLighter,
                                ),
                              ),
                              if (error.details != null)
                                SelectableText(
                                  error.details.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      OcrInitial() => const SizedBox.shrink(),
                    },
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
