import 'dart:developer';

import 'package:rodzendai_form/core/services/project_policy_service.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';

/// ตัวเลือกประชากรของฟอร์มนี้ — อ่านจากโครงการที่ admin ผูก CUSTOMER_CODE ไว้
/// (admin: จัดการโครงการ → แก้ไขโครงการ → "ตัวเลือกประชากร" และ
/// "ฟอร์มลงทะเบียนที่ใช้โครงการนี้") แก้ที่ admin แล้วมีผลทันที ไม่ต้อง deploy ฟอร์มใหม่
///
/// ไม่พบโครงการที่ผูกไว้ / เรียก API ไม่สำเร็จ → รับเฉพาะคนในทะเบียนบ้าน (default)
class PopulationPolicyService {
  /// true = รับประชากรแฝง — ดึงโครงการผ่าน [ProjectPolicyService] (cache ร่วมกัน)
  static Future<bool> allowsLatentPopulation() async {
    final project = await ProjectPolicyService.current();
    log(
      'populationPolicy ของ ${EnvHelper.customerCode} -> '
      '${project?.populationPolicy} (โครงการ: ${project?.name})',
    );
    return project?.allowsLatentPopulation ?? false;
  }
}
