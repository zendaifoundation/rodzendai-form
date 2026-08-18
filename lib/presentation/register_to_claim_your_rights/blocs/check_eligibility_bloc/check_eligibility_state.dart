part of 'check_eligibility_bloc.dart';

sealed class CheckEligibilityState extends Equatable {
  const CheckEligibilityState();

  @override
  List<Object> get props => [];
}

final class CheckEligibilityInitial extends CheckEligibilityState {}

final class CheckEligibilityLoading extends CheckEligibilityState {}

final class CheckEligibilitySuccess extends CheckEligibilityState {}

final class CheckEligibilityFailure extends CheckEligibilityState {
  const CheckEligibilityFailure({this.message = MessageConstant.defaultError});
  final String message;

  @override
  List<Object> get props => [message];
}
