part of 'district_bloc.dart';

sealed class DistrictEvent extends Equatable {
  const DistrictEvent();

  @override
  List<Object?> get props => [];
}

final class DistrictRequested extends DistrictEvent {
  const DistrictRequested({
    required this.provinceId,
    this.selectedDistrictId,
  });

  final int provinceId;
  final int? selectedDistrictId;

  @override
  List<Object?> get props => [provinceId, selectedDistrictId];
}

final class DistrictCleared extends DistrictEvent {
  const DistrictCleared();
}
