import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

mixin InputFormatters {
  static get phone => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ];
  static get citizenId => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(13),
      ];
  static get postalCode => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(5),
      ];
  static get number => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ];
  static get numberWithDecimal => [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        //LengthLimitingTextInputFormatter(10),
      ];

  static get password => [
        LengthLimitingTextInputFormatter(20),
      ];
  static get text => [
        FilteringTextInputFormatter.deny(RegExp(r"[^\u0E00-\u0E7Fa-zA-Z' ]|^'|'$|''")),
      ];

  static get textNoWhiteSpace => [
        FilteringTextInputFormatter.deny(RegExp(r"[^\u0E00-\u0E7Fa-zA-Z']|^'|'$|''")),
      ];

  static get alphaNumericNoWhiteSpace => [
        FilteringTextInputFormatter.deny(RegExp(r"[^\u0E00-\u0E7Fa-zA-Z_0987654321']|^'|'$|''")),
      ];

  static get quantity => [
        FilteringTextInputFormatter.allow(RegExp(r'^[-]{1}|[0-9]')),
      ];

  static get digitsOnly => [
        FilteringTextInputFormatter.digitsOnly,
      ];

  static get persen => [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ];

  static get thaiOrEngilsh => [
        FilteringTextInputFormatter.allow(RegExp("[a-zA-Zก-๙]")),
      ];
  static get tracking => [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
      ];

  static get name => [
        FilteringTextInputFormatter.allow(RegExp("[a-zA-Zก-๙ ]")),
      ];

  static get sku => [
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9-_]")),
      ];

  static get digitsLimit4 => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ];

  static digitsLimit(int limit) => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(limit),
      ];

  static List<TextInputFormatter> get numberWithDecimalAndComma => [
        NumberWithDecimalAndCommaInputFormatter(),
      ];

  static final percent = [
    FilteringTextInputFormatter.allow(
      RegExp(r'^100(\.0{0,2})?$|^(\d{1,2})(\.\d{0,2})?$'),
    ),
  ];
}

class NumberWithDecimalAndCommaInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,##0', 'en'); // ไม่มีทศนิยมตรงนี้

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // ลบ comma ออกก่อน
    String cleaned = newText.replaceAll(',', '');

    // ตรวจสอบว่ามีจุดทศนิยมหรือไม่
    int dotIndex = cleaned.indexOf('.');

    // ถ้ามีมากกว่าหนึ่งจุด ไม่อนุญาต
    if ('.'.allMatches(cleaned).length > 1) {
      return oldValue;
    }

    // ถ้าไม่ตรง pattern อนุญาตเลขและจุดทศนิยม 2 ตำแหน่ง
    if (!RegExp(r'^\d*\.?\d{0,2}$').hasMatch(cleaned)) {
      return oldValue;
    }

    if (cleaned.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String integerPart = '';
    String decimalPart = '';

    if (dotIndex >= 0) {
      integerPart = cleaned.substring(0, dotIndex);
      decimalPart = cleaned.substring(dotIndex); // รวมจุดทศนิยม
    } else {
      integerPart = cleaned;
    }

    // แปลงเลขจำนวนเต็ม (integerPart) โดยไม่สนใจทศนิยม
    int? intVal = int.tryParse(integerPart);
    if (intVal == null && integerPart.isNotEmpty) {
      return oldValue;
    }

    // ฟอร์แมตจำนวนเต็มด้วย comma
    String formattedInt = intVal == null ? '' : _formatter.format(intVal);

    // รวมกับทศนิยมเดิม (ถ้ามี)
    String finalText = formattedInt + decimalPart;

    // กำหนดตำแหน่งเคอร์เซอร์ (ให้ไปตำแหน่งท้ายสุด)
    int selectionIndex = finalText.length;

    return TextEditingValue(
      text: finalText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
