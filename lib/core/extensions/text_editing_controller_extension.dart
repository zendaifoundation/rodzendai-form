import 'package:flutter/material.dart';

extension TextEditingControllerExtension on TextEditingController {
  /// ดึงค่า text ที่ trim แล้ว ถ้าว่างจะคืนค่า null
  String? get textOrNull {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// ดึงค่า text ที่ trim แล้ว
  String get trimmedText => text.trim();

  /// เช็คว่า text ว่างหรือไม่ (หลัง trim)
  bool get isEmpty => text.trim().isEmpty;

  /// เช็คว่า text ไม่ว่าง (หลัง trim)
  bool get isNotEmpty => text.trim().isNotEmpty;

  /// เช็คว่ามีค่าและความยาวมากกว่าที่กำหนด
  bool hasMinLength(int minLength) {
    return text.trim().length >= minLength;
  }

  /// เช็คว่าเป็นตัวเลขหรือไม่
  bool get isNumeric {
    final trimmed = text.trim();
    return trimmed.isNotEmpty && int.tryParse(trimmed) != null;
  }

  /// เช็คว่าเป็นเบอร์โทรศัพท์หรือไม่ (10 หลัก)
  bool get isValidPhoneNumber {
    final trimmed = text.trim();
    return RegExp(r'^[0-9]{10}$').hasMatch(trimmed);
  }

  /// เช็คว่าเป็นอีเมลหรือไม่
  bool get isValidEmail {
    final trimmed = text.trim();
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(trimmed);
  }

  /// เช็คว่าเป็นเลขบัตรประชาชนหรือไม่ (13 หลัก)
  bool get isValidIdCard {
    final trimmed = text.trim();
    return RegExp(r'^[0-9]{13}$').hasMatch(trimmed);
  }
}
