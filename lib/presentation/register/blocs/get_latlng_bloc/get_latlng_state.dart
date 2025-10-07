part of 'get_latlng_bloc.dart';

abstract class GetLatLngState extends Equatable {
  const GetLatLngState();

  @override
  List<Object?> get props => [];
}

/// สถานะเริ่มต้น
class GetLatLngInitial extends GetLatLngState {}

/// สถานะกำลังโหลด
class GetLatLngLoading extends GetLatLngState {}

/// สถานะสำเร็จ
class GetLatLngSuccess extends GetLatLngState {
  final double latitude;
  final double longitude;

  const GetLatLngSuccess({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

/// สถานะล้มเหลว
class GetLatLngFailure extends GetLatLngState {
  final String message;

  const GetLatLngFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
