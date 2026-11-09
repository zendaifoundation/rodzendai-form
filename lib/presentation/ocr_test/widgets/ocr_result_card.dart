import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/toast_helper.dart';
import 'package:rodzendai_form/models/id_card_ocr_result_model.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';

/// แสดงผล OCR: field ที่ parse ได้ + raw JSON (copy ได้)
class OcrResultCard extends StatelessWidget {
  const OcrResultCard({super.key, required this.result, required this.elapsed});

  final IdCardOcrResultModel result;
  final Duration elapsed;

  String get _prettyJson =>
      const JsonEncoder.withIndent('  ').convert(result.raw);

  @override
  Widget build(BuildContext context) {
    final fields = result.displayFields.entries.toList();
    final meta = [
      if (result.provider != null) 'engine: ${result.provider}',
      if (result.confidence != null)
        'confidence: ${result.confidence!.toStringAsFixed(2)}',
      if (result.rotation != null && result.rotation != 0)
        'หมุนรูป: ${result.rotation}°',
      'อ่านได้ ${result.foundCount}/${fields.length} field',
    ].join(' • ');

    return BaseCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ผล OCR',
                  style: AppTextStyles.bold.copyWith(fontSize: 18),
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
          Text(
            meta,
            style: AppTextStyles.regular.copyWith(
              fontSize: 12,
              color: AppColors.textLight,
            ),
          ),
          if (result.warnings.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  for (final w in result.warnings)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 6,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        Expanded(child: Text(w, style: AppTextStyles.regular)),
                      ],
                    ),
                ],
              ),
            ),
          Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: [
              for (final e in fields)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 16, 4),
                      child: Text(
                        e.key,
                        style: AppTextStyles.medium.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: SelectableText(
                        e.value ?? '— อ่านไม่ได้',
                        style: e.value == null
                            ? AppTextStyles.regular.copyWith(
                                color: AppColors.textLighter,
                                fontStyle: FontStyle.italic,
                              )
                            : AppTextStyles.regular,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              Expanded(child: Text('Raw JSON', style: AppTextStyles.bold)),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _prettyJson));
                  if (!context.mounted) return;
                  ToastHelper.showSuccess(
                    context: context,
                    title: 'คัดลอก JSON แล้ว',
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('คัดลอก'),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: SelectableText(
              _prettyJson,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
