part of 'register_to_claim_your_rights_bloc.dart';

sealed class RegisterToClaimYourRightsState extends Equatable {
  const RegisterToClaimYourRightsState();

  @override
  List<Object> get props => [];
}

final class RegisterToClaimYourRightsInitial extends RegisterToClaimYourRightsState {}

final class RegisterToClaimYourRightsLoading extends RegisterToClaimYourRightsState {}

final class RegisterToClaimYourRightsSuccess extends RegisterToClaimYourRightsState {}

final class RegisterToClaimYourRightsFailure extends RegisterToClaimYourRightsState {
  const RegisterToClaimYourRightsFailure({this.message = MessageConstant.defaultError});
  final String message;

  @override
  List<Object> get props => [message];
}
