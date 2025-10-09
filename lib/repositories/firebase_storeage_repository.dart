import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadFile({
    required String path,
    required Uint8List fileBytes,
    String? contentType,
  }) async {
    try {
      final ref = _storage.ref().child(path);

      // ตั้งค่า metadata ให้เปิดไฟล์ใน browser แทนการ download
      final metadata = SettableMetadata(
        contentType: contentType,
        contentDisposition: 'inline', // บอกให้ browser เปิดไฟล์แทนการ download
      );

      final uploadTask = ref.putData(fileBytes, metadata);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('File upload failed: ${e.toString()}');
    }
  }
}
