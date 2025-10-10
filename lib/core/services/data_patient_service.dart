import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:rodzendai_form/models/patient_record_model.dart';

class DataPatientService {
  DataPatientService._();

  static List<PatientRecordModel>? _cachePatientRecords;

  /// อ่านรายชื่อโรงพยาบาลจากไฟล์ CSV
  static Future<List<PatientRecordModel>> loadList() async {
    // ถ้ามี cache แล้วให้ return ทันที
    if (_cachePatientRecords != null) {
      return _cachePatientRecords ?? [];
    }
    try {
      // อ่านไฟล์ CSV
      final String csvString = await rootBundle.loadString(
        'assets/files/first_5000_registration_records.csv',
      );

      // แยกบรรทัด
      final List<String> lines = csvString.split('\n');

      log('start processing CSV');
      log('lines length: ${lines.length}');

      // สร้าง list ไว้ข้างนอก loop
      List<PatientRecordModel> patientRecords = [];

      for (int i = 1; i < lines.length; i++) {
        //log(' processing line: $i / ${lines.length - 1} ');
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        // แยกคอลัมน์ด้วย comma
        final List<String> columns = line.split(',');
        //ลำดับ,เลขประจำตัวประชาชน,ชื่อผู้ป่วย,เบอร์ติดต่อ,ประเภทผู้ป่วย,ชื่อโรงพยาบาล

        //log('columns: ${columns.length} ');

        String? idCardNumber;
        String? patientName;
        String? phoneNumber;
        String? patientType;
        String? hospitalName;

        //ตอนนี้เอาแค่ที่ใช้ คือ idCardNumber

        if (columns.length > 1) {
          idCardNumber = columns[1].trim();
        }

        final model = PatientRecordModel(
          idCardNumber: idCardNumber,
          patientName: patientName,
          phoneNumber: phoneNumber,
          patientType: patientType,
          hospitalName: hospitalName,
        );
        patientRecords.add(model);
      }

      // เก็บใน cache และ return หลังจาก loop เสร็จ
      _cachePatientRecords = patientRecords;
      return patientRecords;
    } catch (e) {
      log('Error loading hospitals: $e');
      // ถ้าอ่านไฟล์ไม่ได้ ให้ return รายการเริ่มต้น
      return [];
    }
  }
}
