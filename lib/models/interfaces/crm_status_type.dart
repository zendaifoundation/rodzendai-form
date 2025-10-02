enum CrmStatusType {
  success('1', 'สำเร็จ'),
  failed('2', 'ไม่สำเร็จ'),
  cancelled('3', 'ยกเลิก'),
  pending('4', 'รอคัดกรอง'),
  processing('5', 'รอดำเนินการ');

  const CrmStatusType(this.code, this.displayName);

  final String code;
  final String displayName;

  /// แปลงจาก code เป็น CrmStatusType
  static CrmStatusType? fromCode(String? code) {
    if (code == null || code.isEmpty) return null;

    try {
      return CrmStatusType.values.firstWhere((status) => status.code == code);
    } catch (e) {
      return null;
    }
  }

  /// แปลงจาก status object/string เป็นข้อความ
  static String getCrmStatusText(dynamic crmStatusData) {
    if (crmStatusData == null) return 'ไม่ระบุสถานะ';

    String? statusCode;

    // ถ้าเป็น String
    if (crmStatusData is String) {
      statusCode = crmStatusData;
    }
    // ถ้าเป็น Map
    else if (crmStatusData is Map) {
      statusCode =
          crmStatusData['status']?.toString() ??
          crmStatusData['Status']?.toString() ??
          crmStatusData['code']?.toString();
    }

    // หา enum จาก code
    final status = fromCode(statusCode);
    return status?.displayName ?? 'ไม่ระบุสถานะ';
  }

  /// ดึง displayName จาก code โดยตรง
  static String getDisplayName(String? code) {
    final status = fromCode(code);
    return status?.displayName ?? 'ไม่ระบุสถานะ';
  }
}
