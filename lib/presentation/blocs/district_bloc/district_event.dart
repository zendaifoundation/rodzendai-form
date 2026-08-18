part of 'district_bloc.dart';

sealed class DistrictEvent extends Equatable {
  const DistrictEvent();

  @override
  List<Object?> get props => [];
}

final class DistrictRequested extends DistrictEvent {
  const DistrictRequested({
    required this.provinceCode,
    this.selectedDistrictCode,
  });

  final int provinceCode;
  final int? selectedDistrictCode;

  @override
  List<Object?> get props => [provinceCode, selectedDistrictCode];
}

final class DistrictCleared extends DistrictEvent {
  const DistrictCleared();
}
