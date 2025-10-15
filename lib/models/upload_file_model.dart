import 'dart:typed_data';

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
