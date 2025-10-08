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
  bool _isPickingFile = false;

  Future<void> _pickFiles() async {
    // ป้องกันการเปิด file picker ซ้ำ
    if (_isPickingFile) {
      log('Already picking file, skipping...');
      return;
    }

    try {
      setState(() {
        _isPickingFile = true;
      });

      log('Starting file picker...');

      // ใช้ FileType.any แทน FileType.custom เพื่อให้ Android เลือก PDF ได้
      // แล้วกรองไฟล์ที่ไม่ต้องการออกเอง
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false, // เปลี่ยนเป็น false เพื่อป้องกันปัญหา
        withData: true,
        allowCompression: false,
      );

      log('File picker result: ${result != null ? "Got result" : "Cancelled"}');

      if (result != null && result.files.isNotEmpty) {
        // กรองเฉพาะไฟล์ที่เรารองรับ
        final file = result.files.first;
        final extension = file.extension?.toLowerCase() ?? '';

        log('Selected file: ${file.name}, extension: $extension');

        if (!['jpg', 'jpeg', 'png', 'pdf'].contains(extension)) {
          // แสดงข้อความแจ้งเตือนว่าไฟล์ไม่ถูกต้อง
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'กรุณาเลือกไฟล์ประเภท JPG, PNG หรือ PDF เท่านั้น',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (file.bytes == null) {
          log('File bytes is null');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ไม่สามารถอ่านข้อมูลไฟล์ได้'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final uploadedFile = UploadedFile(
          name: file.name,
          bytes: file.bytes!,
          size: file.size,
          extension: extension,
        );

        log(
          'File created successfully: ${uploadedFile.name}, size: ${uploadedFile.size}',
        );

        // ใช้ Future.microtask เพื่อให้แน่ใจว่า callback ทำงานหลังจาก UI update
        if (mounted) {
          Future.microtask(() {
            if (mounted) {
              widget.onFilesSelected?.call(uploadedFile);
              log('File callback completed');
            }
          });
        }
      } else {
        log('No file selected or result is null');
      }
    } catch (e) {
      log('Error picking files: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เกิดข้อผิดพลาดในการเลือกไฟล์'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFile = false;
        });
      }
      log('File picker finished');
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
