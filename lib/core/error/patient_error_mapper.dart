import 'package:rodzendai_form/core/error/error_message.dart';

class PatientErrorMapper {
  static String map(String code) {
    switch (code) {
      case 'PATIENT_EXISTS':
        return 'ผู้ป่วยนี้มีอยู่ในระบบแล้ว';
      case 'INVALID_HN':
        return 'หมายเลข HN ไม่ถูกต้อง';
      default:
        return ErrorMessage.mapError(code);
    }
  }
}