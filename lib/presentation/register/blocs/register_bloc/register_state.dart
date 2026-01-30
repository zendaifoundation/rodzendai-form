part of 'register_bloc.dart';

sealed class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

final class RegisterInitial extends RegisterState {}

final class RegisterLoading extends RegisterState {}

final class RegisterSuccess extends RegisterState {
  const RegisterSuccess({this.appointmentDates  = const []});
  final List<AppointmentDateModel> appointmentDates;
  @override
  List<Object> get props => [appointmentDates];
}

final class RegisterFailure extends RegisterState {
  const RegisterFailure({this.message = MessageConstant.defaultError});
  final String message;

  @override
  List<Object> get props => [message];
}
