import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';
import 'package:rodzendai_form/models/patient_transports_model.dart';
import 'package:rodzendai_form/presentation/splash/widgets/card_patient_empty.dart';

class RegisterStatusList extends StatelessWidget {
  const RegisterStatusList({super.key, required this.patientTransports});
  final List<PatientTransportsModel> patientTransports;
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadow.primaryShadow,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            'ผลการค้นหา (${patientTransports.length} รายการ)',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Divider(color: AppColors.secondary.withOpacity(0.16), thickness: 1),
          ...List.generate(patientTransports.length, (index) {
            final patientTransport = patientTransports[index];
            return _buildCardItem(patientTransport: patientTransport);
          }),
        ],
      ),
    );
  }

  _buildCardItem({required PatientTransportsModel patientTransport}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            child: Text('สถานะการจอง: ${patientTransport.status}'),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text('วันที่นัดหมาย: ${patientTransport.appointmentDate}'),
                Text('ชื่อ-นามสกุลผู้ป่วย: ${patientTransport.patientName}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
