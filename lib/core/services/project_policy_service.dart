import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/models/project_model.dart';
import 'package:rodzendai_form/repositories/project_repository.dart';

/// โครงการที่ admin ผูก CUSTOMER_CODE ของฟอร์มนี้ไว้ — ใช้อ่านค่าตั้งค่าต่าง ๆ
/// ของโครงการ (populationPolicy, registrationOpen ฯลฯ) แก้ที่ admin แล้วมีผลทันที
/// ไม่ต้อง deploy ฟอร์มใหม่
///
/// ดึงจาก API ครั้งเดียวต่อการเปิดแอป ถ้าดึงไม่สำเร็จจะลองใหม่ครั้งถัดไป
class ProjectPolicyService {
  static Future<ProjectModel?>? _pending;

  /// โครงการที่ผูกกับฟอร์มนี้ — null ถ้าไม่พบหรือเรียก API ไม่สำเร็จ
  static Future<ProjectModel?> current() => _pending ??= _load();

  /// เปิดรับลงทะเบียนรับสิทธิ์หรือไม่ — ไม่พบโครงการ / API ล้มเหลว → เปิด (default)
  static Future<bool> isRegistrationOpen() async {
    final project = await current();
    final open = project?.isRegistrationOpen ?? true;
    log('registrationOpen ของ ${EnvHelper.customerCode} -> $open');
    return open;
  }

  static Future<ProjectModel?> _load() async {
    final customerCode = EnvHelper.customerCode;
    if (customerCode == null) return null;
    try {
      final projects = await locator<ProjectRepository>().fetchProjects();
      final project = projects.firstWhereOrNull(
        (p) => p.isActive && p.customerCodes.contains(customerCode),
      );
      log('โครงการของ $customerCode -> ${project?.name}');
      return project;
    } catch (e) {
      log('โหลดโครงการของฟอร์มไม่สำเร็จ: $e');
      _pending = null; // ให้ลองใหม่ครั้งถัดไป
      return null;
    }
  }
}
