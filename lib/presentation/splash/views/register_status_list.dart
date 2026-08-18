import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/date_helper.dart';
import 'package:rodzendai_form/models/get_patient_transport_response_model.dart';
import 'package:rodzendai_form/models/interfaces/service_type.dart';
import 'package:rodzendai_form/models/patient_usage_report_model.dart';
import 'package:rodzendai_form/presentation/splash/widgets/card_patient_empty.dart';

class RegisterStatusList extends StatelessWidget {
  const RegisterStatusList({
    super.key,
    required this.patientTransports,
    this.usageReport,
  });
  final List<PatientTransport> patientTransports;

  /// รายงานสิทธิ์แยกตามโครงการจาก backend (trip_summary) — ถ้ามีจะใช้ตัวเลขนี้
  /// แทนการนับฝั่ง client เพื่อให้ตรงกับหน้า admin ทะเบียนผู้ป่วย
  final PatientUsageReportModel? usageReport;
  @override
  Widget build(BuildContext context) {
    if (patientTransports.isEmpty) {
      return CardPatientEmpty();
    }
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: AppShadow.primaryShadow,
      ),
      child: Builder(
        builder: (context) {
          // เรียงข้อมูลตามวันที่จากใหม่ไปเก่า
          final sortedTransports = [...patientTransports]
            ..sort((a, b) {
              final dateA = a.appointmentInfo?.appointmentDate;
              final dateB = b.appointmentInfo?.appointmentDate;

              // จัดการกรณี null
              if (dateA == null && dateB == null) return 0;
              if (dateA == null) return 1;
              if (dateB == null) return -1;

              // เรียงจากใหม่ไปเก่า (descending)
              return dateB.compareTo(dateA);
            });

          final statusCounts = _countByStatus(sortedTransports);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                'ผลการค้นหา (${sortedTransports.length} รายการ)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              _buildStatusSummary(statusCounts),
              _buildRightsSection(sortedTransports),
              //_buildServiceTypeSummary(serviceTypeCounts),
              Divider(
                color: AppColors.secondary.withOpacity(0.16),
                thickness: 1,
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) {
                  return SizedBox(height: 16);
                },
                itemBuilder: (context, index) {
                  final PatientTransport patientTransport =
                      sortedTransports[index];
                  log(
                    'patientTransport -> ${patientTransport.appointmentInfo?.appointmentDate}',
                  );
                  return _buildCardItem(patientTransport: patientTransport);
                },
                itemCount: sortedTransports.length,
              ),
            ],
          );
        },
      ),
    );
  }

  _buildCardItem({required PatientTransport patientTransport}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadow.primaryShadow,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgHeaderCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: AppShadow.primaryShadow,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.secondary.withOpacity(0.16),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Row(
                  children: [
                    Text(
                      'สถานะ: ',
                      style: AppTextStyles.bold.copyWith(
                        fontSize: 16,
                        color: AppColors.textLight,
                      ),
                    ),
                    Text(
                      _getStatusText(patientTransport.status?.status),
                      style: AppTextStyles.bold.copyWith(
                        fontSize: 16,
                        color: _getStatusColor(patientTransport.status?.status),
                      ),
                    ),
                  ],
                ),
                SelectableText(
                  patientTransport.caseId ?? '',
                  style: AppTextStyles.bold.copyWith(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                _buildTextRow(
                  title: 'วันที่นัดหมาย: ',
                  // value: DateHelper.dateTimeThaiDefault(
                  //   patientTransport.appointmentDate?.millisecondsSinceEpoch,
                  // ),
                  value: DateHelper.dateTimeThaiDefault(
                    patientTransport
                        .appointmentInfo
                        ?.appointmentDate
                        ?.millisecondsSinceEpoch,
                  ),
                ),
                _buildTextRow(
                  title: 'ชื่อ-นามสกุลผู้ป่วย: ',
                  value: patientTransport.patientInfo?.fullName ?? '-',
                ),
                _buildTextRow(
                  title: 'สถานพยาบาล: ',
                  value: patientTransport.appointmentInfo?.hospitalName ?? '-',
                ),
                _buildTextRow(
                  title: 'ความต้องการใช้บริการ: ',
                  value: _getServiceTypeDisplay(patientTransport),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _countRightsUsed(List<PatientTransport> transports) {
    log('Counting rights used for ${transports.length} transports');
    var count = 0;
    for (var i = 0; i < transports.length; i++) {
      final t = transports[i];
      final status = t.status?.status;
      final caseId = t.caseId ?? t.id ?? '-';

      if (status != '1') {
        log(
          '[${i + 1}/${transports.length}] case=$caseId status=$status '
          '-> ข้าม (นับเฉพาะ status 1)',
        );
        continue;
      }

      final drivers = t.driver ?? const <Driver>[];
      final ambulances = drivers.where((d) => d.carType == '1').toList();
      count += ambulances.length; //นับจำนวนรถพยาบาลที่ใช้บริการ

      log(
        '[${i + 1}/${transports.length}] case=$caseId status=$status '
        '-> ${ambulances.length} เที่ยว '
        '(driver ทั้งหมด ${drivers.length}, carType=1 ${ambulances.length}) '
        'รวมสะสม $count',
      );

      for (var j = 0; j < ambulances.length; j++) {
        final d = ambulances[j];
        log(
          '    เที่ยวที่ ${j + 1}: idTransport=${d.idTransport} '
          'ทะเบียน=${d.carLicense} คนขับ=${d.driverName} '
          'วันที่=${d.serviceDate} รับ=${d.pickupTime} ส่ง=${d.dropoffTime}',
        );
      }
    }
    log('Total rights used: $count');
    return count;
  }

  /// แสดงสิทธิ์ที่ใช้ไป — ถ้ามี usageReport จาก backend จะโชว์แยกตามโครงการ
  /// (ตัวเลขตรงกับหน้า admin ทะเบียนผู้ป่วย) ถ้าไม่มีจะ fallback ไปนับฝั่ง client
  Widget _buildRightsSection(List<PatientTransport> transports) {
    final report = usageReport;
    // แสดงเฉพาะโครงการปัจจุบันของผู้ป่วย (displayProjects กรองให้แล้ว)
    final projectsToShow = report?.displayProjects ?? const [];
    if (report == null || projectsToShow.isEmpty) {
      // fallback: ไม่มีรายงานจาก backend → นับฝั่ง client แบบเดิม
      return _buildRightsUsedRow(_countRightsUsed(transports));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: projectsToShow.map((p) => _buildProjectRightsRow(p)).toList(),
    );
  }

  Widget _buildProjectRightsRow(UsageProjectReport project) {
    final used = project.usedRights;
    final max = project.maxUsage;
    final remaining = project.remainingRights;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.project,
            style: AppTextStyles.bold.copyWith(
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text.rich(
              TextSpan(
                style: AppTextStyles.regular.copyWith(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
                children: [
                  const TextSpan(text: 'ใช้สิทธิ์ไปแล้ว: '),
                  TextSpan(
                    text: max != null ? '$used/$max' : '$used',
                    style: AppTextStyles.bold.copyWith(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const TextSpan(text: ' เที่ยว'),
                  if (remaining != null) ...[
                    const TextSpan(text: '  •  คงเหลือ '),
                    TextSpan(
                      text: '$remaining',
                      style: AppTextStyles.bold.copyWith(
                        fontSize: 14,
                        color: remaining <= 0 ? Colors.red : AppColors.primary,
                      ),
                    ),
                    const TextSpan(text: ' เที่ยว'),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'ขาไป ${project.departureTrips} • ขากลับ ${project.returnTrips}',
              style: AppTextStyles.regular.copyWith(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightsUsedRow(int rightsUsed) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text(
            'ใช้สิทธิ์ไปแล้ว: ',
            style: AppTextStyles.regular.copyWith(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
          Text(
            '$rightsUsed',
            style: AppTextStyles.bold.copyWith(
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
          Text(
            ' เที่ยว',
            style: AppTextStyles.regular.copyWith(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Map<ServiceType, int> _countByServiceType(List<PatientTransport> transports) {
    const includedStatuses = {'1', '5'};
    final counts = <ServiceType, int>{};
    for (final t in transports) {
      final status = t.status?.status;
      if (!includedStatuses.contains(status)) continue;
      final type = _resolveServiceType(t);
      if (type == null) continue;
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return counts;
  }

  ServiceType? _resolveServiceType(PatientTransport patientTransport) {
    final requests = patientTransport.transportRequest;
    if (requests == null || requests.isEmpty) return null;
    if (requests.length > 1) return ServiceType.roundTrip;
    final req = requests.first;
    if (req.returnSchedule == true) return ServiceType.inbound;
    if (req.departureSchedule == true) return ServiceType.outbound;
    return null;
  }

  int _tripsForServiceType(ServiceType type) {
    return type == ServiceType.roundTrip ? 2 : 1;
  }

  Widget _buildServiceTypeSummary(Map<ServiceType, int> counts) {
    const order = [
      ServiceType.outbound,
      ServiceType.inbound,
      ServiceType.roundTrip,
    ];
    final keys = order.where(counts.containsKey).toList();
    if (keys.isEmpty) return const SizedBox.shrink();

    final totalTrips = keys.fold<int>(0, (sum, type) {
      log(
        'Calculating trips for service type $type: count=${counts[type]}, trips per service=${_tripsForServiceType(type)}',
      );
      return sum + (counts[type] ?? 0) * _tripsForServiceType(type);
    });

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: keys.map((type) {
              final items = counts[type] ?? 0;
              final trips = items * _tripsForServiceType(type);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${type.displayName}: ',
                    style: AppTextStyles.regular.copyWith(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                  Text(
                    '$trips',
                    style: AppTextStyles.bold.copyWith(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    ' เที่ยว',
                    style: AppTextStyles.regular.copyWith(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'รวม: ',
                style: AppTextStyles.regular.copyWith(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),
              Text(
                '$totalTrips',
                style: AppTextStyles.bold.copyWith(
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
              Text(
                ' เที่ยว',
                style: AppTextStyles.regular.copyWith(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, int> _countByStatus(List<PatientTransport> transports) {
    final counts = <String, int>{};
    for (final t in transports) {
      final key = t.status?.status ?? '-';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  Widget _buildStatusSummary(Map<String, int> counts) {
    const order = ['4', '5', '1', '2', '3'];
    final keys = [
      ...order.where(counts.containsKey),
      ...counts.keys.where((k) => !order.contains(k)),
    ];

    if (keys.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: keys.map((k) {
          final color = _getStatusColor(k);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                _getStatusText(k),
                style: AppTextStyles.regular.copyWith(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${counts[k]}',
                style: AppTextStyles.bold.copyWith(fontSize: 14, color: color),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Row _buildTextRow({String? title, String? value}) {
    return Row(
      children: [
        Text(title ?? '', style: AppTextStyles.bold.copyWith(fontSize: 16)),
        Expanded(
          child: Text(
            value ?? '-',
            style: AppTextStyles.regular.copyWith(
              color: AppColors.textLight,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case '1':
        return 'สำเร็จ';
      case '2':
        return 'ไม่สำเร็จ';
      case '3':
        return 'ยกเลิก';
      case '4':
        //return 'รอดำเนินการ';
        return 'รอเจ้าหน้าที่ติดต่อกลับ';
      case '5':
        //return 'กำลังดำเนินการ';
        return 'จองคิวรถแล้ว';
      default:
        return '-';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case '1': // สำเร็จ
        return Colors.green;
      case '2': // ไม่สำเร็จ
        return Colors.red;
      case '3': // ยกเลิก
        return Colors.grey;
      case '4': // รอดำเนินการ
        return Colors.orange;
      case '5': // กำลังดำเนินการ
        return Colors.blue;
      default:
        return AppColors.textLight;
    }
  }

  String? _getServiceTypeDisplay(PatientTransport patientTransport) {
    List<TransportRequest>? transportRequest =
        patientTransport.transportRequest;
    if (transportRequest != null && transportRequest.isNotEmpty) {
      if (transportRequest.length > 1) {
        return ServiceType.roundTrip.displayName;
      } else {
        final req = transportRequest.first;
        if (req.returnSchedule == true) {
          return ServiceType.inbound.displayName;
        } else if (req.departureSchedule == true) {
          return ServiceType.outbound.displayName;
        } else {
          return '-';
        }
      }
    } else {
      return '-';
    }
  }
}
