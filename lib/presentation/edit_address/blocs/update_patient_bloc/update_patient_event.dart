part of 'update_patient_bloc.dart';

sealed class UpdatePatientEvent {}

class UpdatePatientSubmitEvent extends UpdatePatientEvent {
  UpdatePatientSubmitEvent({
    required this.idCardNumber,
    required this.updateData,
  });
  final String idCardNumber;
  final Map<String, dynamic> updateData;
}

class UpdatePatientReset extends UpdatePatientEvent {}
