part of 'check_register_status_bloc.dart';

sealed class CheckRegisterStatusEvent extends Equatable {
  const CheckRegisterStatusEvent();

  @override
  List<Object> get props => [];
}

class CheckRegisterStatusRequestEvent extends CheckRegisterStatusEvent {
  const CheckRegisterStatusRequestEvent({
    required this.idCardNumber,
    //    required this.travelDate,
  });

  final String idCardNumber;
  //final DateTime travelDate;

  @override
  List<Object> get props => [
    idCardNumber,
    //travelDate
  ];
}
