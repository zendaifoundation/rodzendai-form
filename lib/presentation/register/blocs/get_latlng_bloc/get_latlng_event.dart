part of 'get_latlng_bloc.dart';

abstract class GetLatLngEvent extends Equatable {
  const GetLatLngEvent();

  @override
  List<Object?> get props => [];
}

/// Event สำหรับดึง lat/lng จาก place_id
class GetLatLngFromPlaceIdEvent extends GetLatLngEvent {
  final String placeId;

  const GetLatLngFromPlaceIdEvent({required this.placeId});

  @override
  List<Object?> get props => [placeId];
}

/// Event สำหรับดึง lat/lng จากที่อยู่
class GetLatLngFromAddressEvent extends GetLatLngEvent {
  final String address;

  const GetLatLngFromAddressEvent({required this.address});

  @override
  List<Object?> get props => [address];
}
