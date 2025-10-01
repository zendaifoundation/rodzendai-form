part of 'check_register_status_bloc.dart';

sealed class CheckRegisterStatusEvent extends Equatable {
  const CheckRegisterStatusEvent();

  @override
  List<Object> get props => [];
}

class CheckRegisterStatusRequestEvent extends CheckRegisterStatusEvent {
  const CheckRegisterStatusRequestEvent();

  @override
  List<Object> get props => [];
}
