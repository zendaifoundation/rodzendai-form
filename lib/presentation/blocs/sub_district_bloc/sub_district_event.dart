part of 'sub_district_bloc.dart';

sealed class SubDistrictEvent extends Equatable {
  const SubDistrictEvent();

  @override
  List<Object?> get props => [];
}

final class SubDistrictRequested extends SubDistrictEvent {
  const SubDistrictRequested({
    required this.districtId,
    this.selectedSubDistrictId,
  });

  final int districtId;
  final int? selectedSubDistrictId;

  @override
  List<Object?> get props => [districtId, selectedSubDistrictId];
}

final class SubDistrictCleared extends SubDistrictEvent {
  const SubDistrictCleared();
}
