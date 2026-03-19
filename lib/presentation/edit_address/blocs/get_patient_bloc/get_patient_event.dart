part of 'get_patient_bloc.dart';

sealed class GetPatientEvent {}

class GetPatientByIdCardEvent extends GetPatientEvent {
  GetPatientByIdCardEvent({required this.idCardNumber});
  final String idCardNumber;
}

class GetPatientReset extends GetPatientEvent {}
