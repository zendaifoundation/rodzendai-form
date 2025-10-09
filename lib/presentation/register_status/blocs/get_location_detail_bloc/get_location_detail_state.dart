part of 'get_location_detail_bloc.dart';

sealed class GetLocationDetailState extends Equatable {
  const GetLocationDetailState();

  @override
  List<Object?> get props => [];
}

final class GetLocationDetailInitial extends GetLocationDetailState {}

final class GetLocationDetailLoading extends GetLocationDetailState {}

final class GetLocationDetailSuccess extends GetLocationDetailState {
  const GetLocationDetailSuccess({required this.addressDetail});
  final AddressDetail addressDetail;

  @override
  List<Object?> get props => [addressDetail];
}

final class GetLocationDetailFailure extends GetLocationDetailState {
  const GetLocationDetailFailure({this.message = MessageConstant.defaultError});
  final String message;

  @override
  List<Object?> get props => [message];
}
