class MimeHelper {
  /// คืนค่า mime type จากนามสกุลไฟล์ (fallback เป็น null หากไม่พบ)
  static String? getMimeType(String? extension) {
    if (extension == null) return null;
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return null;
    }
  }
}
