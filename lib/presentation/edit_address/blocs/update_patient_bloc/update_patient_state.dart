part of 'update_patient_bloc.dart';

sealed class UpdatePatientState {}

class UpdatePatientInitial extends UpdatePatientState {}

class UpdatePatientLoading extends UpdatePatientState {}

class UpdatePatientSuccess extends UpdatePatientState {}

class UpdatePatientFailure extends UpdatePatientState {
  UpdatePatientFailure({required this.message});
  final String message;
}
