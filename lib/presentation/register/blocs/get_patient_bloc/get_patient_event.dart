part of 'get_patient_bloc.dart';

sealed class GetPatientEvent extends Equatable {
  const GetPatientEvent();

  @override
  List<Object> get props => [];
}

class GetPatientRequestEvent extends GetPatientEvent {
  const GetPatientRequestEvent(this.idCardNumber);
  final String idCardNumber;

  @override
  List<Object> get props => [idCardNumber];
}
