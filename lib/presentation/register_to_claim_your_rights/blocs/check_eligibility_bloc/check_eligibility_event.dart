part of 'check_eligibility_bloc.dart';

sealed class CheckEligibilityEvent extends Equatable {
  const CheckEligibilityEvent();

  @override
  List<Object?> get props => [];
}

class CheckEligibilityRequestEvent extends CheckEligibilityEvent {
  const CheckEligibilityRequestEvent({this.idCardNumber});
  final String? idCardNumber;

  @override
  List<Object?> get props => [idCardNumber];
}
