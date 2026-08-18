part of 'district_bloc.dart';

sealed class DistrictState extends Equatable {
  const DistrictState();

  @override
  List<Object?> get props => [];
}

final class DistrictInitial extends DistrictState {}

final class DistrictLoadInProgress extends DistrictState {}

final class DistrictLoadSuccess extends DistrictState {
  const DistrictLoadSuccess({
    this.districts = const [],
    this.selectedDistrictCode,
  });

  final List<DistrictModel> districts;
  final int? selectedDistrictCode;

  @override
  List<Object?> get props => [districts, selectedDistrictCode];
}

final class DistrictLoadFailure extends DistrictState {
  const DistrictLoadFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
