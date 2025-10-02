import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/date_helper.dart';
import 'package:rodzendai_form/presentation/register_status/models/patient_transport_item_model.dart';
import 'package:rodzendai_form/presentation/splash/widgets/card_patient_empty.dart';

class RegisterStatusList extends StatelessWidget {
  const RegisterStatusList({super.key, required this.patientTransports});
  final List<PatientTransportItemModel> patientTransports;
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

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            'ผลการค้นหา (${patientTransports.length} รายการ)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Divider(color: AppColors.secondary.withOpacity(0.16), thickness: 1),
          ListView.separated(
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return SizedBox(height: 16);
            },
            itemBuilder: (context, index) {
              final patientTransport = patientTransports[index];
              return _buildCardItem(patientTransport: patientTransport);
            },
            itemCount: patientTransports.length,
          ),
        ],
      ),
    );
  }

  _buildCardItem({required PatientTransportItemModel patientTransport}) {
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
            child: Text(
              'สถานะ: ${patientTransport.status}',
              style: AppTextStyles.bold.copyWith(
                fontSize: 16,
                color: AppColors.textLight,
              ),
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
                  value: DateHelper.dateTimeThaiDefault(
                    patientTransport.appointmentDate?.millisecondsSinceEpoch,
                  ),
                ),
                _buildTextRow(
                  title: 'ชื่อ-นามสกุลผู้ป่วย: ',
                  value: patientTransport.patientName,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row _buildTextRow({String? title, String? value}) {
    return Row(
      children: [
        Text(title ?? '', style: AppTextStyles.bold),
        Expanded(
          child: Text(
            value ?? '-',
            style: AppTextStyles.regular.copyWith(color: AppColors.textLight),
          ),
        ),
      ],
    );
  }
}
