import 'dart:developer';

import 'package:flutter/services.dart';

/// Model สำหรับเก็บข้อมูลโรงพยาบาล
class HospitalData {
  final String hCode;
  final String name;
  final String displayName; // HCODE : ชื่อโรงพยาบาล
  final String? subDistrict; // ตำบล/แขวง
  final String? district; // อำเภอ/เขต
  final String? province; // จังหวัด

  HospitalData({
    required this.hCode,
    required this.name,
    required this.displayName,
    this.subDistrict,
    this.district,
    this.province,
  });

  @override
  String toString() => displayName;
}

class HospitalService {
  static List<HospitalData>? _cachedHospitals;

  /// อ่านรายชื่อโรงพยาบาลจากไฟล์ CSV
  static Future<List<HospitalData>> loadHospitals() async {
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
      final List<HospitalData> hospitals = [];

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        // แยกคอลัมน์ด้วย comma
        final List<String> columns = line.split(',');

        if (columns.length >= 9) {
          // คอลัมน์ที่ 1: HCODE
          final String hCode = columns[1].trim();

          // คอลัมน์ที่ 3: ชื่อโรงพยาบาล
          final String hospitalName = columns[3].trim();

          // คอลัมน์ที่ 5: ตำบล/แขวง
          final String subDistrict = columns[5].trim();

          // คอลัมน์ที่ 6: อำเภอ/เขต
          final String district = columns[6].trim();

          // คอลัมน์ที่ 8: จังหวัด
          final String province = columns[8].trim();

          // สร้าง displayName
          final String displayName = hCode.isNotEmpty
              ? '$hCode : $hospitalName'
              : hospitalName;

          if (hCode.isNotEmpty && hospitalName.isNotEmpty) {
            hospitals.add(
              HospitalData(
                hCode: hCode,
                name: hospitalName,
                displayName: displayName,
                subDistrict: subDistrict.isNotEmpty ? subDistrict : null,
                district: district.isNotEmpty ? district : null,
                province: province.isNotEmpty ? province : null,
              ),
            );
          }
        }
      }

      // เรียงตามตัวอักษร
      hospitals.sort((a, b) => a.displayName.compareTo(b.displayName));

      // เพิ่มตัวเลือก "อื่นๆ" ท้ายสุด
      hospitals.add(
        HospitalData(
          hCode: '',
          name: 'อื่นๆ',
          displayName: 'อื่นๆ',
          subDistrict: null,
          district: null,
          province: null,
        ),
      );

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
  static List<HospitalData> searchHospitals(
    List<HospitalData> hospitals,
    String query,
  ) {
    if (query.isEmpty) return hospitals;

    return hospitals
        .where(
          (hospital) =>
              hospital.displayName.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              hospital.hCode.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  /// ค้นหาโรงพยาบาลจาก hCode
  static HospitalData? findByHCode(List<HospitalData> hospitals, String hCode) {
    try {
      return hospitals.firstWhere((h) => h.hCode == hCode);
    } catch (e) {
      return null;
    }
  }

  /// ค้นหาโรงพยาบาลจากชื่อ
  static HospitalData? findByName(List<HospitalData> hospitals, String name) {
    try {
      return hospitals.firstWhere(
        (h) => h.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
