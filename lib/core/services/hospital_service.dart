import 'dart:developer';

import 'package:flutter/services.dart';

class HospitalService {
  static List<String>? _cachedHospitals;

  /// อ่านรายชื่อโรงพยาบาลจากไฟล์ CSV
  static Future<List<String>> loadHospitals() async {
    // ถ้ามี cache แล้วให้ return ทันที
    if (_cachedHospitals != null) {
      return _cachedHospitals!;
    }

    try {
      // อ่านไฟล์ CSV
      final String csvString = await rootBundle.loadString(
        'assets/files/hospitals.csv',
      );

      // แยกบรรทัด
      final List<String> lines = csvString.split('\n');

      // ข้ามบรรทัดแรก (header) และแปลงข้อมูล
      final List<String> hospitals = [];

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        // แยกคอลัมน์ด้วย comma
        final List<String> columns = line.split(',');

        if (columns.length >= 2) {
          // เอาเฉพาะคอลัมน์ HNAME (คอลัมน์ที่ 2)
          String hospitalName = columns[1].trim();

          // ลบ HCODE ออก (เช่น "11468 : " -> "")
          if (hospitalName.contains(':')) {
            hospitalName = hospitalName.split(':').last.trim();
          }

          if (hospitalName.isNotEmpty) {
            hospitals.add(hospitalName);
          }
        }
      }

      // เรียงตามตัวอักษร
      hospitals.sort((a, b) => a.compareTo(b));

      // เพิ่มตัวเลือก "อื่นๆ" ท้ายสุด
      hospitals.add('อื่นๆ');

      // เก็บใน cache
      _cachedHospitals = hospitals;

      return hospitals;
    } catch (e) {
      log('Error loading hospitals: $e');
      // ถ้าอ่านไฟล์ไม่ได้ ให้ return รายการเริ่มต้น
      return [];
    }
  }

  /// ล้าง cache (ใช้เมื่อต้องการ reload ข้อมูล)
  static void clearCache() {
    _cachedHospitals = null;
  }

  /// ค้นหาโรงพยาบาล
  static List<String> searchHospitals(List<String> hospitals, String query) {
    if (query.isEmpty) return hospitals;

    return hospitals
        .where(
          (hospital) => hospital.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
