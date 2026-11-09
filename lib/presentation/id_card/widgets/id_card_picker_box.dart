import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/presentation/id_card/pages/id_card_camera_page.dart';
import 'package:rodzendai_form/presentation/id_card/widgets/id_card_source_sheet.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_file_widget.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';
import 'package:rodzendai_form/widgets/dialog/app_dialogs.dart';

/// กล่องเลือกรูปบัตรประชาชน: กดแล้วให้เลือก "ถ่ายรูป (มีกรอบ)" หรือ "แกลเลอรี"
class IdCardPickerBox extends StatefulWidget {
  const IdCardPickerBox({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final UploadedFile? value;
  final ValueChanged<UploadedFile?> onChanged;
  final bool enabled;

  @override
  State<IdCardPickerBox> createState() => _IdCardPickerBoxState();
}

class _IdCardPickerBoxState extends State<IdCardPickerBox> {
  static const _allowed = {'jpg', 'jpeg', 'png', 'webp'};
  static const _maxBytes = 10 * 1024 * 1024;
  bool _busy = false;

  Future<void> _pick() async {
    if (_busy || !widget.enabled) return;
    final source = await showIdCardSourceSheet(context);
    if (source == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final file = switch (source) {
        IdCardSource.camera => await IdCardCameraPage.open(context),
        IdCardSource.gallery => await _pickFromGallery(),
      };
      if (file != null) widget.onChanged(file);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<UploadedFile?> _pickFromGallery() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowed.toList(),
        allowMultiple: false,
        withData: true,
        dialogTitle: 'เลือกรูปบัตรประชาชน',
      );
      if (result == null || result.files.isEmpty) return null;
      final f = result.files.first;
      final ext = f.extension?.toLowerCase() ?? '';
      if (!_allowed.contains(ext) || f.bytes == null) {
        if (mounted) {
          await AppDialogs.error(
            context,
            title: 'ไฟล์ไม่ถูกต้อง',
            message: 'กรุณาเลือกรูป JPG, PNG หรือ WEBP เท่านั้น',
          );
        }
        return null;
      }
      if (f.size > _maxBytes) {
        if (mounted) {
          await AppDialogs.error(
            context,
            title: 'ไฟล์ใหญ่เกินไป',
            message: 'กรุณาเลือกไฟล์ที่มีขนาดไม่เกิน 10MB',
          );
        }
        return null;
      }
      return UploadedFile(
        name: f.name,
        bytes: f.bytes!,
        size: f.size,
        extension: ext,
      );
    } catch (e) {
      log('[IdCardPickerBox] gallery error: $e');
      if (mounted) {
        await AppDialogs.error(
          context,
          title: 'เกิดข้อผิดพลาด',
          message: 'ไม่สามารถเลือกไฟล์ได้\n$e',
        );
      }
      return null;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.value;
    return InkWell(
      onTap: file == null ? _pick : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgHeaderCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          spacing: 12,
          children: [
            if (file == null) ...[
              const Icon(
                Icons.badge_outlined,
                size: 56,
                color: AppColors.primary,
              ),
              Text(
                'รูปบัตรประชาชน',
                style: AppTextStyles.bold.copyWith(fontSize: 16),
              ),
              Text(
                'ถ่ายรูปด้วยกล้อง (มีกรอบช่วยจัดตำแหน่ง) หรือเลือกจากแกลเลอรี',
                style: AppTextStyles.regular.copyWith(
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              ButtonCustom(
                text: 'เพิ่มรูปบัตร',
                isLoading: _busy,
                icon: const Icon(
                  Icons.add_a_photo_outlined,
                  color: AppColors.white,
                  size: 18,
                ),
                onPressed: widget.enabled ? _pick : null,
              ),
            ] else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: Image.memory(file.bytes, fit: BoxFit.contain),
                ),
              ),
              Text(
                '${file.name} • ${_formatSize(file.size)}',
                style: AppTextStyles.regular.copyWith(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  ButtonCustom(
                    text: 'เปลี่ยนรูป',
                    isLoading: _busy,
                    onPressed: widget.enabled ? _pick : null,
                  ),
                  ButtonCustom(
                    text: 'ลบรูป',
                    backgroundColor: AppColors.red,
                    onPressed: widget.enabled
                        ? () => widget.onChanged(null)
                        : null,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
