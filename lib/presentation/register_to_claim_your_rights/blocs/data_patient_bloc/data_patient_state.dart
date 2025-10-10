part of 'data_patient_bloc.dart';

abstract class DataPatientState {}

class DataPatientInitial extends DataPatientState {}

class DataPatientLoading extends DataPatientState {}

class DataPatientLoaded extends DataPatientState {
  final List<PatientRecordModel> dataPatients;

  DataPatientLoaded({required this.dataPatients});
}

class DataPatientError extends DataPatientState {
  final String message;

  DataPatientError(this.message);
}
