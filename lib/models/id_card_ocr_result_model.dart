/// ผลลัพธ์จาก zendai-ocr `POST /api/ocr/thai-id`
///
/// ```json
/// {
///   "ok": true, "provider": "easyocr", "confidence": 0.82, "rotation": 0,
///   "fields": { "idNumber", "titleTH", "firstNameTH", "lastNameTH",
///               "firstNameEN", "lastNameEN", "dateOfBirth", "address",
///               "issueDate", "expiryDate" },
///   "warnings": ["..."],
///   "rawText": "..."   // เฉพาะตอน server เปิด DEBUG_OCR
/// }
/// ```
/// `raw` เก็บ JSON ต้นฉบับทั้งก้อนไว้แสดงบนหน้า TEST OCR
class IdCardOcrResultModel {
  const IdCardOcrResultModel({
    required this.raw,
    required this.ok,
    this.provider,
    this.confidence,
    this.rotation,
    this.warnings = const [],
    this.rawText,
    this.idNumber,
    this.titleTH,
    this.firstNameTH,
    this.lastNameTH,
    this.firstNameEN,
    this.lastNameEN,
    this.dateOfBirth,
    this.address,
    this.issueDate,
    this.expiryDate,
  });

  final Map<String, dynamic> raw;
  final bool ok;
  final String? provider;
  final double? confidence;
  final int? rotation;
  final List<String> warnings;
  final String? rawText;

  final String? idNumber;
  final String? titleTH;
  final String? firstNameTH;
  final String? lastNameTH;
  final String? firstNameEN;
  final String? lastNameEN;
  final String? dateOfBirth;
  final String? address;
  final String? issueDate;
  final String? expiryDate;

  factory IdCardOcrResultModel.fromJson(Map<String, dynamic> json) {
    final fields = json['fields'] is Map
        ? Map<String, dynamic>.from(json['fields'] as Map)
        : <String, dynamic>{};

    String? str(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return IdCardOcrResultModel(
      raw: json,
      ok: json['ok'] == true,
      provider: str(json['provider']),
      confidence: (json['confidence'] as num?)?.toDouble(),
      rotation: (json['rotation'] as num?)?.toInt(),
      warnings:
          (json['warnings'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      rawText: str(json['rawText']),
      idNumber: str(fields['idNumber']),
      titleTH: str(fields['titleTH']),
      firstNameTH: str(fields['firstNameTH']),
      lastNameTH: str(fields['lastNameTH']),
      firstNameEN: str(fields['firstNameEN']),
      lastNameEN: str(fields['lastNameEN']),
      dateOfBirth: str(fields['dateOfBirth']),
      address: str(fields['address']),
      issueDate: str(fields['issueDate']),
      expiryDate: str(fields['expiryDate']),
    );
  }

  String? get fullNameTH {
    final s = [
      titleTH,
      firstNameTH,
      lastNameTH,
    ].whereType<String>().join(' ').trim();
    return s.isEmpty ? null : s;
  }

  String? get fullNameEN {
    final s = [firstNameEN, lastNameEN].whereType<String>().join(' ').trim();
    return s.isEmpty ? null : s;
  }

  /// field สำหรับแสดงผลเป็นตาราง (เรียงตามลำดับบนบัตร) ค่า null = OCR อ่านไม่ได้
  Map<String, String?> get displayFields => {
    'เลขบัตรประชาชน': idNumber,
    'คำนำหน้า': titleTH,
    'ชื่อ (ไทย)': firstNameTH,
    'นามสกุล (ไทย)': lastNameTH,
    'ชื่อ (อังกฤษ)': firstNameEN,
    'นามสกุล (อังกฤษ)': lastNameEN,
    'วันเกิด': dateOfBirth,
    'ที่อยู่': address,
    'วันออกบัตร': issueDate,
    'วันหมดอายุ': expiryDate,
  };

  int get foundCount => displayFields.values.whereType<String>().length;
}
