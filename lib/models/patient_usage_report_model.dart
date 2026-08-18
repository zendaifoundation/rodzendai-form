/// รายงานการใช้สิทธิ์เดินทางของผู้ป่วย แยกตามโครงการ
/// map จาก endpoint POST /api/v1/patients/getPatientUsageReport
/// ตัวเลขชุดนี้เป็นตัวจริงตามเกณฑ์คิดสิทธิ์ (อ่านจาก trip_summary ฝั่ง backend)
class PatientUsageReportModel {
  const PatientUsageReportModel({
    this.nationalID,
    this.name,
    this.patientType,
    this.currentProject,
    this.overall,
    this.projects = const [],
  });

  final String? nationalID;
  final String? name;
  final String? patientType;

  /// โครงการปัจจุบันของผู้ป่วย — ควรโชว์เฉพาะโครงการนี้
  final String? currentProject;
  final UsageOverall? overall;
  final List<UsageProjectReport> projects;

  /// รายการโครงการที่ควรแสดง: ถ้ารู้โครงการปัจจุบันให้เหลือแค่ตัวนั้น
  /// (maxUsage/คงเหลือ ผูกกับโควตาโครงการปัจจุบันเท่านั้น) ไม่งั้นแสดงทั้งหมด
  List<UsageProjectReport> get displayProjects {
    if (currentProject == null) return projects;
    final filtered =
        projects.where((p) => p.project == currentProject).toList();
    return filtered.isNotEmpty ? filtered : projects;
  }

  factory PatientUsageReportModel.fromJson(Map<String, dynamic> json) {
    // รองรับทั้งกรณีห่อด้วย ResponseHandler ({ data: {...} }) และตัว data ตรง ๆ
    final Map<String, dynamic> data =
        (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return PatientUsageReportModel(
      nationalID: data['nationalID'] as String?,
      name: data['name'] as String?,
      patientType: data['patient_type'] as String?,
      currentProject: data['currentProject'] as String?,
      overall: data['overall'] is Map<String, dynamic>
          ? UsageOverall.fromJson(data['overall'] as Map<String, dynamic>)
          : null,
      projects: (data['projects'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(UsageProjectReport.fromJson)
          .toList(),
    );
  }
}

class UsageOverall {
  const UsageOverall({
    this.departureTrips = 0,
    this.returnTrips = 0,
    this.totalTrips = 0,
  });

  final int departureTrips;
  final int returnTrips;
  final int totalTrips;

  factory UsageOverall.fromJson(Map<String, dynamic> json) {
    return UsageOverall(
      departureTrips: (json['departureTrips'] as num?)?.toInt() ?? 0,
      returnTrips: (json['returnTrips'] as num?)?.toInt() ?? 0,
      totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
    );
  }
}

class UsageProjectReport {
  const UsageProjectReport({
    required this.project,
    this.maxUsage,
    this.usedRights = 0,
    this.departureTrips = 0,
    this.returnTrips = 0,
    this.remainingRights,
  });

  final String project;
  final int? maxUsage;
  final int usedRights;
  final int departureTrips;
  final int returnTrips;
  final int? remainingRights;

  factory UsageProjectReport.fromJson(Map<String, dynamic> json) {
    return UsageProjectReport(
      project: (json['project'] as String?) ?? '-',
      maxUsage: (json['maxUsage'] as num?)?.toInt(),
      usedRights: (json['usedRights'] as num?)?.toInt() ?? 0,
      departureTrips: (json['departureTrips'] as num?)?.toInt() ?? 0,
      returnTrips: (json['returnTrips'] as num?)?.toInt() ?? 0,
      remainingRights: (json['remainingRights'] as num?)?.toInt(),
    );
  }
}
