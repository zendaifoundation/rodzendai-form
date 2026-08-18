part of 'sub_district_bloc.dart';

sealed class SubDistrictEvent extends Equatable {
  const SubDistrictEvent();

  @override
  List<Object?> get props => [];
}

final class SubDistrictRequested extends SubDistrictEvent {
  const SubDistrictRequested({
    required this.districtCode,
    this.selectedSubDistrictCode,
  });

  final int districtCode;
  final int? selectedSubDistrictCode;

  @override
  List<Object?> get props => [districtCode, selectedSubDistrictCode];
}

final class SubDistrictCleared extends SubDistrictEvent {
  const SubDistrictCleared();
}
