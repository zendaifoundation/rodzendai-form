import 'dart:developer';
import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_file_widget.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';
import 'package:rodzendai_form/widgets/dialog/app_dialogs.dart';
import 'package:rodzendai_form/widgets/required_label.dart';

class BoxUploadMultiFileWidget extends StatelessWidget {
  final Function(List<UploadedFile> files)? onFilesSelected;
  final String? Function(List<UploadedFile>?)? validator;
  final List<UploadedFile>? initialValue;
  final int? maxFile;

  const BoxUploadMultiFileWidget({
    super.key,
    this.onFilesSelected,
    this.validator,
    this.initialValue,
    this.maxFile,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<List<UploadedFile>>(
      initialValue: initialValue ?? [],
      validator: validator,
      builder: (FormFieldState<List<UploadedFile>> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            _BoxUploadMultiFileContent(
              uploadedFiles: field.value ?? [],
              onFilesSelected: (files) {
                field.didChange(files);
                onFilesSelected?.call(files);
              },
              maxFile: maxFile,
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

class _BoxUploadMultiFileContent extends StatefulWidget {
  final List<UploadedFile> uploadedFiles;
  final Function(List<UploadedFile> files)? onFilesSelected;
  final int? maxFile;

  const _BoxUploadMultiFileContent({
    required this.uploadedFiles,
    this.onFilesSelected,
    this.maxFile = 3,
  });

  @override
  State<_BoxUploadMultiFileContent> createState() =>
      _BoxUploadMultiFileContentState();
}

class _BoxUploadMultiFileContentState
    extends State<_BoxUploadMultiFileContent> {
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

      log('Starting file picker... Platform: ${kIsWeb ? "Web" : "Native"}');

      FilePickerResult? result;

      // แยกการจัดการตาม platform เพื่อแก้ปัญหาบาง devices
      if (kIsWeb) {
        // สำหรับ Web ใช้ FileType.custom เพื่อควบคุมประเภทไฟล์
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
          allowMultiple: true, // ← เปลี่ยนเป็น true เพื่อรองรับหลายไฟล์
          withData: true,
          dialogTitle: 'เลือกไฟล์',
          lockParentWindow: true,
        );
      } else {
        // สำหรับ iOS และ Android
        try {
          result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
            allowMultiple: true, // ← เปลี่ยนเป็น true เพื่อรองรับหลายไฟล์
            withData: true,
            dialogTitle: 'เลือกไฟล์',
          );
        } catch (e) {
          log('FileType.custom failed, trying FileType.any: $e');
          result = await FilePicker.platform.pickFiles(
            type: FileType.any,
            allowMultiple: true, // ← เปลี่ยนเป็น true เพื่อรองรับหลายไฟล์
            withData: true,
            dialogTitle: 'เลือกไฟล์',
          );
        }
      }

      if (!mounted) {
        log('Widget unmounted after file picker');
        return;
      }

      log(
        'File picker result: ${result != null ? "Got ${result.files.length} files" : "Cancelled"}',
      );

      if (result != null && result.files.isNotEmpty) {
        if (result.files.length > (widget.maxFile ?? 0) ||
            result.files.length >
                ((widget.maxFile ?? 0) - widget.uploadedFiles.length)) {
          await AppDialogs.error(context, message: 'จำนวนไฟล์มากกว่าที่กำหนด');
          return;
        }
        List<UploadedFile> newFiles = [];

        for (var file in result.files) {
          final extension = file.extension?.toLowerCase() ?? '';

          log(
            'Processing file: ${file.name}, extension: $extension, size: ${file.size}',
          );

          // กรองเฉพาะไฟล์ที่เรารองรับ
          if (!['jpg', 'jpeg', 'png', 'pdf'].contains(extension)) {
            if (mounted) {
              await AppDialogs.error(
                context,
                title: 'ไฟล์ไม่ถูกต้อง',
                message:
                    'ไฟล์ "${file.name}" ไม่ถูกต้อง\nกรุณาเลือกไฟล์ประเภท JPG, PNG หรือ PDF เท่านั้น',
              );
            }
            continue;
          }

          if (file.bytes == null) {
            log('File bytes is null for ${file.name}');
            if (mounted) {
              await AppDialogs.error(
                context,
                title: 'ไม่สามารถอ่านไฟล์',
                message:
                    'ไม่สามารถอ่านข้อมูลไฟล์ "${file.name}" ได้ กรุณาลองใหม่อีกครั้ง',
              );
            }
            continue;
          }

          // เช็คขนาดไฟล์ไม่เกิน 10MB
          if (file.size > 10 * 1024 * 1024) {
            if (mounted) {
              await AppDialogs.error(
                context,
                title: 'ไฟล์ใหญ่เกินไป',
                message:
                    'ไฟล์ "${file.name}" มีขนาด ${_formatFileSize(file.size)}\nกรุณาเลือกไฟล์ที่มีขนาดไม่เกิน 10MB',
              );
            }
            continue;
          }

          final uploadedFile = UploadedFile(
            name: file.name,
            bytes: file.bytes!,
            size: file.size,
            extension: extension,
          );

          newFiles.add(uploadedFile);
          log('File added successfully: ${uploadedFile.name}');
        }

        if (newFiles.isNotEmpty) {
          // รวมไฟล์ใหม่กับไฟล์เก่า
          final updatedFiles = [...widget.uploadedFiles, ...newFiles];

          if (mounted) {
            Future.microtask(() {
              if (mounted) {
                widget.onFilesSelected?.call(updatedFiles);
                log('Files callback completed: ${updatedFiles.length} files');
              }
            });
          }
        }
      } else {
        log('No file selected or result is null');
      }
    } catch (e, stackTrace) {
      log('Error picking files: $e');
      log('Stack trace: $stackTrace');
      if (mounted) {
        await AppDialogs.error(
          context,
          title: 'เกิดข้อผิดพลาด',
          message:
              'ไม่สามารถเลือกไฟล์ได้\n\nรายละเอียด:\n${e.toString()}\n\nแพลตฟอร์ม: ${kIsWeb ? "Web" : "Native"}',
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

  void _removeFile(int index) {
    final updatedFiles = List<UploadedFile>.from(widget.uploadedFiles);
    updatedFiles.removeAt(index);
    widget.onFilesSelected?.call(updatedFiles);
  }

  @override
  Widget build(BuildContext context) {
    bool isDisable = widget.uploadedFiles.length >= (widget.maxFile ?? 0);
    return Column(
      children: [
        DropTarget(
          onDragEntered: isDisable
              ? null
              : (details) {
                  setState(() {
                    isDragging = true;
                  });
                },
          onDragExited: isDisable
              ? null
              : (details) {
                  setState(() {
                    isDragging = false;
                  });
                },
          onDragDone: isDisable
              ? null
              : (details) async {
                  if (details.files.length > (widget.maxFile ?? 0) ||
                      details.files.length >
                          ((widget.maxFile ?? 0) -
                              widget.uploadedFiles.length)) {
                    await AppDialogs.error(
                      context,
                      message: 'จำนวนไฟล์มากกว่าที่กำหนด',
                    );
                    return;
                  }
                  setState(() {
                    isDragging = false;
                  });

                  List<UploadedFile> newFiles = [];

                  for (var file in details.files) {
                    final bytes = await file.readAsBytes();
                    final fileName = file.name;
                    final extension = fileName.split('.').last.toLowerCase();

                    if (['jpg', 'jpeg', 'png', 'pdf'].contains(extension)) {
                      // เช็คขนาดไฟล์
                      if (bytes.length > 10 * 1024 * 1024) {
                        if (mounted) {
                          await AppDialogs.error(
                            context,
                            title: 'ไฟล์ใหญ่เกินไป',
                            message:
                                'ไฟล์ "$fileName" มีขนาด ${_formatFileSize(bytes.length)}\nกรุณาเลือกไฟล์ที่มีขนาดไม่เกิน 10MB',
                          );
                        }
                        continue;
                      }

                      final newFile = UploadedFile(
                        name: fileName,
                        bytes: bytes,
                        size: bytes.length,
                        extension: extension,
                      );
                      newFiles.add(newFile);
                    }
                  }

                  if (newFiles.isNotEmpty) {
                    final updatedFiles = [...widget.uploadedFiles, ...newFiles];
                    widget.onFilesSelected?.call(updatedFiles);
                  }
                },
          child: InkWell(
            onTap: isDisable ? null : _pickFiles,
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
                  Text(
                    'สามารถอัปโหลดมากที่สุด ${widget.maxFile} ไฟล์',
                    style: AppTextStyles.regular.copyWith(
                      color: AppColors.red,
                      fontSize: 12,
                    ),
                  ),
                  ButtonCustom(
                    text: 'อัพโหลดไฟล์',
                    onPressed: isDisable ? null : _pickFiles,
                  ),
                  Text(
                    isDragging ? 'วางไฟล์ที่นี่' : 'หรือลากและวางไฟล์ที่นี่',
                    style: AppTextStyles.regular.copyWith(
                      color: isDragging ? Colors.blue : null,
                      fontWeight: isDragging ? FontWeight.bold : null,
                    ),
                  ),
                  if (widget.uploadedFiles.isNotEmpty) ...[
                    Divider(),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Text(
                            'ไฟล์ที่อัปโหลด (${widget.uploadedFiles.length} ไฟล์)',
                            style: AppTextStyles.regular.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ...widget.uploadedFiles.asMap().entries.map((entry) {
                            final index = entry.key;
                            final file = entry.value;
                            return _FileItem(
                              file: file,
                              index: index,
                              onRemove: () => _removeFile(index),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _FileItem extends StatelessWidget {
  final UploadedFile file;
  final int index;
  final VoidCallback onRemove;

  const _FileItem({
    required this.file,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Preview
          _getFilePreview(),
          SizedBox(width: 12),
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ${file.name}',
                  style: AppTextStyles.regular.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  _formatFileSize(file.size),
                  style: AppTextStyles.regular.copyWith(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Remove button
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.red),
            onPressed: onRemove,
            tooltip: 'ลบไฟล์',
          ),
        ],
      ),
    );
  }

  Widget _getFilePreview() {
    final extension = file.extension.toLowerCase();
    if (['jpg', 'jpeg', 'png'].contains(extension)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.memory(
          file.bytes,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: _getFileColor(extension).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          _getFileIcon(extension),
          color: _getFileColor(extension),
          size: 30,
        ),
      );
    }
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
}
