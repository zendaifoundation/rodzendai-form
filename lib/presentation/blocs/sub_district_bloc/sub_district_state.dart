part of 'sub_district_bloc.dart';

sealed class SubDistrictState extends Equatable {
  const SubDistrictState();

  @override
  List<Object?> get props => [];
}

final class SubDistrictInitial extends SubDistrictState {}

final class SubDistrictLoadInProgress extends SubDistrictState {}

final class SubDistrictLoadSuccess extends SubDistrictState {
  const SubDistrictLoadSuccess({
    this.subDistricts = const [],
    this.selectedSubDistrictCode,
  });

  final List<SubDistrictModel> subDistricts;
  final int? selectedSubDistrictCode;

  @override
  List<Object?> get props => [subDistricts, selectedSubDistrictCode];
}

final class SubDistrictLoadFailure extends SubDistrictState {
  const SubDistrictLoadFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
