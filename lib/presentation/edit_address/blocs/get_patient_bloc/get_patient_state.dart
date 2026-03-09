part of 'get_patient_bloc.dart';

sealed class GetPatientState {}

class GetPatientInitial extends GetPatientState {}

class GetPatientLoading extends GetPatientState {}

class GetPatientSuccess extends GetPatientState {
  GetPatientSuccess({required this.patient});
  final PatientModel patient;
}

class GetPatientFailure extends GetPatientState {
  GetPatientFailure({required this.message});
  final String message;
}
