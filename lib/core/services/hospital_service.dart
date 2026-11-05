import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:rodzendai_form/core/constants/apis.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';

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

  /// ทุก customerCode ดึงรายชื่อจาก API ทะเบียนสถานพยาบาลกลาง
  /// (`/api/v1/form/health-facilities` — เห็นจังหวัด/ประเภทไหน ตั้งที่ admin:
  /// ตั้งค่า → พื้นที่ให้บริการ → แท็บ "ฟอร์มลงทะเบียน")
  /// ถ้า API ล้มเหลวหรือได้รายการว่าง (ยังไม่ได้ตั้งค่า) จะ fallback ไปอ่าน CSV ใน assets
  ///
  /// customerCode ที่ CSV เดิมบันทึกรหัส 9 หลักใหม่ (เช่น GA0024434) แทน hcode
  /// ต้องบันทึกรหัสแบบเดิมต่อ ไม่งั้นผู้ป่วยเก่ากับใหม่ใช้รหัสคนละแบบ
  static const Set<String> _newCodeCustomerCodes = {'kanchanaburi'};

  /// ดึงรายชื่อจาก API — คืน null ถ้าเรียกไม่สำเร็จหรือได้รายการว่าง
  /// (ยังไม่ได้ตั้งค่าฟอร์ม/ยังไม่นำเข้าทะเบียน)
  static Future<List<HospitalData>?> _loadFromApi(String customerCode) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: Apis.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );
      final res = await dio.get(
        '/api/v1/form/health-facilities',
        queryParameters: {'customerCode': customerCode},
      );
      final data = res.data?['data'];
      final items = (data?['items'] as List?) ?? const [];
      log(
        '[GET] ${res.realUri} -> ${res.statusCode} '
        'configured: ${data?['configured']}, '
        'provinceCodes: ${data?['provinceCodes']}, items: ${items.length}',
      );
      if (items.isEmpty) {
        log('ทะเบียนสถานพยาบาลของ $customerCode ว่าง');
        return null;
      }

      String? str(dynamic v) {
        final s = v?.toString().trim() ?? '';
        return s.isEmpty ? null : s;
      }

      return items.map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        // บันทึกรหัสแบบเดียวกับ CSV เดิมของ customerCode นั้น — ส่วนใหญ่เป็น
        // hcode 5 หลัก (CRM/รายงานอิง hcode) แห่งที่เปิดใหม่ไม่มี hcode → ใช้รหัส 9 หลักใหม่
        final hCode = _newCodeCustomerCodes.contains(customerCode)
            ? (str(m['code']) ?? '')
            : (str(m['hcode']) ?? str(m['code']) ?? '');
        final name = str(m['name']) ?? '';
        return HospitalData(
          hCode: hCode,
          name: name,
          displayName: '$hCode : $name',
          subDistrict: str(m['subdistrictName']),
          district: str(m['districtName']),
          province: str(m['provinceName']),
        );
      }).toList();
    } catch (e) {
      log('ดึงทะเบียนสถานพยาบาลจาก API ไม่สำเร็จ: $e');
      return null;
    }
  }

  /// อ่านรายชื่อโรงพยาบาล — ดึงจาก API ก่อน ถ้าไม่ได้ค่อยอ่าน CSV
  static Future<List<HospitalData>> loadHospitals() async {
    // ถ้ามี cache แล้วให้ return ทันที
    if (_cachedHospitals != null) {
      return _cachedHospitals!;
    }

    final customerCode = EnvHelper.customerCode;
    if (customerCode != null && customerCode.isNotEmpty) {
      final fromApi = await _loadFromApi(customerCode);
      if (fromApi != null) {
        log('โหลดสถานพยาบาลจาก API ${fromApi.length} แห่ง ($customerCode)');
        _cachedHospitals = fromApi;
        return fromApi;
      }
      log('API ไม่มีข้อมูล ($customerCode) — fallback อ่าน CSV');
    }

    try {
      // อ่านไฟล์ CSV
      log('customerCode -> $customerCode');
      String csvString = '';

      if (customerCode == 'samed') {
        log('read csv hospitals_samed');
        csvString = await rootBundle.loadString(
          'assets/files/hospitals_samed.csv',
        );
      } else if (customerCode == 'kanchanaburi') {
        log('read csv hospitals_kanchanaburi');
        csvString = await rootBundle.loadString(
          'assets/files/hospitals_kanchanaburi.csv',
        );
      } else {
        log('read csv hospitals');
        csvString = await rootBundle.loadString('assets/files/hospitals.csv');
      }

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
      // hospitals.add(
      //   HospitalData(
      //     hCode: '',
      //     name: 'อื่นๆ',
      //     displayName: 'อื่นๆ',
      //     subDistrict: null,
      //     district: null,
      //     province: null,
      //   ),
      // );

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
