import 'package:flutter/material.dart';

class Validators {
  static String? validateIdCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกหมายเลขบัตรประชาชน';
    }
    if (value.length != 13) {
      return 'หมายเลขบัตรประชาชนต้องมี 13 หลัก';
    }
    if (!RegExp(r'^\d{13}$').hasMatch(value)) {
      return 'หมายเลขบัตรประชาชนต้องเป็นตัวเลขเท่านั้น';
    }
    return null; // หมายเลขบัตรประชาชนถูกต้อง
  }

  static String? validateTravelDate(String? date) {
    if (date == null || date.isEmpty) {
      return 'กรุณาเลือกวันที่เดินทาง';
    }
    return null; // วันที่เดินทางถูกต้อง
  }

  static FormFieldValidator<String> required(String? errMsg) {
    return (value) {
      if (value == null) {
        return errMsg;
      } else if (value.isEmpty) {
        return errMsg;
      }
      return null;
    };
  }
}
