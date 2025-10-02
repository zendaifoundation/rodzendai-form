import 'package:rodzendai_form/models/interfaces/crm_status_type.dart';
import 'package:rodzendai_form/models/patient_transports_model.dart';
import 'package:rodzendai_form/models/patient_transports_case_crm_model.dart';

class PatientTransportItemModel {
  final String? id;
  final String? patientName;
  final String? status;
  final DateTime? appointmentDate;

  PatientTransportItemModel({
    required this.id,
    required this.patientName,
    required this.status,
    required this.appointmentDate,
  });

  static PatientTransportItemModel fromPatientTransportsModel(
    PatientTransportsModel element,
  ) {
    return PatientTransportItemModel(
      id: element.id,
      patientName: element.patientName,
      status: element.status,
      appointmentDate: element.appointmentDate,
    );
  }

  static PatientTransportItemModel fromPatientTransportsCaseCrmModel(
    PatientTransportsCaseCrmModel element,
  ) {
    return PatientTransportItemModel(
      id: element.id,
      patientName: element.patientInfo?.fullName,
      status: CrmStatusType.fromCode(element.status?.status)?.displayName,
      appointmentDate: element.appointmentInfo?.appointmentDate,
    );
  }
}
