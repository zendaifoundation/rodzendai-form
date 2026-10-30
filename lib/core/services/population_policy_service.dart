import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/repositories/project_repository.dart';

/// ตัวเลือกประชากรของฟอร์มนี้ — อ่านจากโครงการที่ admin ผูก CUSTOMER_CODE ไว้
/// (admin: จัดการโครงการ → แก้ไขโครงการ → "ตัวเลือกประชากร" และ
/// "ฟอร์มลงทะเบียนที่ใช้โครงการนี้") แก้ที่ admin แล้วมีผลทันที ไม่ต้อง deploy ฟอร์มใหม่
///
/// ไม่พบโครงการที่ผูกไว้ / เรียก API ไม่สำเร็จ → รับเฉพาะคนในทะเบียนบ้าน (default)
class PopulationPolicyService {
  static Future<bool>? _pending;

  /// true = รับประชากรแฝง — เรียกซ้ำได้ ดึงจาก API ครั้งเดียวต่อการเปิดแอป
  static Future<bool> allowsLatentPopulation() => _pending ??= _load();

  static Future<bool> _load() async {
    final customerCode = EnvHelper.customerCode;
    if (customerCode == null) return false;
    try {
      final projects = await locator<ProjectRepository>().fetchProjects();
      final project = projects.firstWhereOrNull(
        (p) => p.isActive && p.customerCodes.contains(customerCode),
      );
      log(
        'populationPolicy ของ $customerCode -> ${project?.populationPolicy} '
        '(โครงการ: ${project?.name})',
      );
      return project?.allowsLatentPopulation ?? false;
    } catch (e) {
      log('โหลด populationPolicy ไม่สำเร็จ: $e');
      _pending = null; // ให้ลองใหม่ครั้งถัดไป
      return false;
    }
  }
}
