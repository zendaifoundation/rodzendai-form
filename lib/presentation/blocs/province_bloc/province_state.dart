part of 'province_bloc.dart';

sealed class ProvinceState extends Equatable {
  const ProvinceState();

  @override
  List<Object?> get props => [];
}

final class ProvinceInitial extends ProvinceState {}

final class ProvinceLoadInProgress extends ProvinceState {}

final class ProvinceLoadSuccess extends ProvinceState {
  const ProvinceLoadSuccess({
    this.provinces = const [],
    this.selectedProvinceId,
  });

  final List<ProvinceModel> provinces;
  final int? selectedProvinceId;

  @override
  List<Object?> get props => [provinces, selectedProvinceId];
}

final class ProvinceLoadFailure extends ProvinceState {
  const ProvinceLoadFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
