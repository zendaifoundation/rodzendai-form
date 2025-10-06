import 'dart:developer';
import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';
import 'package:rodzendai_form/widgets/required_label.dart';

class BoxUploadFileWidget extends StatelessWidget {
  final Function(UploadedFile? file)? onFilesSelected;
  final String? Function(UploadedFile?)? validator;
  final UploadedFile? initialValue;

  const BoxUploadFileWidget({
    super.key,
    this.onFilesSelected,
    this.validator,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<UploadedFile>(
      initialValue: initialValue,
      validator: validator,
      builder: (FormFieldState<UploadedFile> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            _BoxUploadFileContent(
              uploadedFile: field.value,
              onFilesSelected: (file) {
                field.didChange(file);
                onFilesSelected?.call(file);
              },
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  field.errorText!,
                  style: AppTextStyles.regular.copyWith(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BoxUploadFileContent extends StatefulWidget {
  final UploadedFile? uploadedFile;
  final Function(UploadedFile? file)? onFilesSelected;

  const _BoxUploadFileContent({this.uploadedFile, this.onFilesSelected});

  @override
  State<_BoxUploadFileContent> createState() => _BoxUploadFileContentState();
}

class _BoxUploadFileContentState extends State<_BoxUploadFileContent> {
  bool isHover = false;
  bool isDragging = false;

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        final files = result.files.map((file) {
          return UploadedFile(
            name: file.name,
            bytes: file.bytes!,
            size: file.size,
            extension: file.extension ?? '',
          );
        }).toList();

        widget.onFilesSelected?.call(files.first);
      }
    } catch (e) {
      log('Error picking files: $e');
    }
  }

  void _removeFile() {
    widget.onFilesSelected?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropTarget(
          onDragEntered: (details) {
            setState(() {
              isDragging = true;
            });
          },
          onDragExited: (details) {
            setState(() {
              isDragging = false;
            });
          },
          onDragDone: (details) async {
            setState(() {
              isDragging = false;
            });

            for (var file in details.files) {
              final bytes = await file.readAsBytes();
              final fileName = file.name;
              final extension = fileName.split('.').last.toLowerCase();

              if (['jpg', 'jpeg', 'png', 'pdf'].contains(extension)) {
                final newFile = UploadedFile(
                  name: fileName,
                  bytes: bytes,
                  size: bytes.length,
                  extension: extension,
                );
                widget.onFilesSelected?.call(newFile);
              }
            }
          },
          child: InkWell(
            onTap: _pickFiles,
            onHover: (value) {
              setState(() {
                isHover = value;
              });
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: DottedDecoration(
                shape: Shape.box,
                borderRadius: BorderRadius.circular(8),
                color: isDragging
                    ? AppColors.primary
                    : isHover
                    ? AppColors.primaryDark
                    : AppColors.border,
                strokeWidth: isDragging ? 2 : 1,
                dash: [4, 4],
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 16,
                children: [
                  RequiredLabel(
                    text: 'อัปโหลดใบนัดหมายแพทย์',
                    isRequired: true,
                  ),
                  Text(
                    'กรุณาอัปโหลดรูปภาพใบนัดหมายแพทย์ (JPG, PNG, PDF)',
                    style: AppTextStyles.regular,
                  ),
                  ButtonCustom(text: 'อัพโหลดไฟล์', onPressed: _pickFiles),
                  Text(
                    isDragging ? 'วางไฟล์ที่นี่' : 'หรือลากและวางไฟล์ที่นี่',
                    style: AppTextStyles.regular.copyWith(
                      color: isDragging ? Colors.blue : null,
                      fontWeight: isDragging ? FontWeight.bold : null,
                    ),
                  ),
                  if (widget.uploadedFile != null)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 16),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [
                          Text(
                            'ไฟล์ที่อัปโหลด',
                            style: AppTextStyles.regular.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _getFileView(widget.uploadedFile),
                          Text(
                            widget.uploadedFile?.name ?? 'ไม่มีชื่อไฟล์',
                            style: AppTextStyles.regular,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _formatFileSize(widget.uploadedFile?.size),
                            style: AppTextStyles.regular.copyWith(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          ButtonCustom(
                            text: 'ลบไฟล์',
                            backgroundColor: AppColors.red,
                            onPressed: () => _removeFile(),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _getFileView(UploadedFile? uploadedFile) {
    if (uploadedFile == null) return SizedBox.shrink();

    final extension = uploadedFile.extension.toLowerCase();
    if (['jpg', 'jpeg', 'png'].contains(extension)) {
      return Image.memory(
        uploadedFile.bytes,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      );
    } else {
      return Icon(
        _getFileIcon(extension),
        size: 50,
        color: _getFileColor(extension),
      );
    }
  }
}

class UploadedFile {
  final String name;
  final Uint8List bytes;
  final int size;
  final String extension;

  UploadedFile({
    required this.name,
    required this.bytes,
    required this.size,
    required this.extension,
  });
}
