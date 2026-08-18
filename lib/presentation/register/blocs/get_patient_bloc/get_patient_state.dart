part of 'get_patient_bloc.dart';

sealed class GetPatientState extends Equatable {
  const GetPatientState();

  @override
  List<Object> get props => [];
}

final class GetPatientInitial extends GetPatientState {}

final class GetPatientLoading extends GetPatientState {}

final class GetPatientSuccess extends GetPatientState {
  const GetPatientSuccess({this.patientData});
  final PatientModel? patientData;
  @override
  List<Object> get props => [patientData ?? ''];
}

final class GetPatientFailure extends GetPatientState {
  const GetPatientFailure({this.message = MessageConstant.defaultError});
  final String message;

  @override
  List<Object> get props => [message];
}
