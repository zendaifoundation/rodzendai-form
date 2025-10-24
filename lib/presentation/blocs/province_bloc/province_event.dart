part of 'province_bloc.dart';

sealed class ProvinceEvent extends Equatable {
  const ProvinceEvent();

  @override
  List<Object?> get props => [];
}

final class ProvinceRequested extends ProvinceEvent {
  const ProvinceRequested({this.selectedProvinceCode});

  final int? selectedProvinceCode;

  @override
  List<Object?> get props => [selectedProvinceCode];
}
