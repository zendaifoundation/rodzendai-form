part of 'check_register_status_bloc.dart';

sealed class CheckRegisterStatusState extends Equatable {
  const CheckRegisterStatusState();

  @override
  List<Object> get props => [];
}

final class CheckRegisterStatusInitial extends CheckRegisterStatusState {}

final class CheckRegisterStatusLoading extends CheckRegisterStatusState {}

final class CheckRegisterStatusSuccess extends CheckRegisterStatusState {}

final class CheckRegisterStatusFailure extends CheckRegisterStatusState {
  const CheckRegisterStatusFailure({
    this.message = MessageConstant.defaultError,
  });
  final String message;

  @override
  List<Object> get props => [message];
}
