import 'dart:developer';

import 'package:rodzendai_form/core/constants/message_constant.dart';

class ErrorMessage {
  static String mapError(String? message) {
    log('Mapping error message: $message');
    if (message != null) {
      switch (message) {
        case 'CONNECTION_ERROR':
          return 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้';
        case 'TIMEOUT_ERROR':
          return 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง';
        case 'NETWORK_ERROR':
          return 'เกิดข้อผิดพลาดด้านเครือข่าย โปรดลองอีกครั้ง';
        case 'SERVER_ERROR':
          return 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์ โปรดลองอีกครั้งภายหลัง';
        case 'INVALID_REQUEST':
          return 'คำขอไม่ถูกต้อง โปรดตรวจสอบข้อมูลและลองใหม่อีกครั้ง';
        default:
          log('Unknown error code: $message');
          return 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ โปรดลองอีกครั้ง';
      }
    }
    return message ?? MessageConstant.defaultError;
  }
}
