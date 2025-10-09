part of 'get_location_detail_bloc.dart';

sealed class GetLocationDetailEvent extends Equatable {
  const GetLocationDetailEvent();

  @override
  List<Object> get props => [];
}

class GetLocationDetailRequestEvent extends GetLocationDetailEvent {
  const GetLocationDetailRequestEvent({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  List<Object> get props => [latitude, longitude];
}
