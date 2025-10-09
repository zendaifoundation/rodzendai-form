part of 'version_info_bloc.dart';

sealed class VersionInfoState extends Equatable {
  const VersionInfoState();

  @override
  List<Object> get props => [];
}

final class VersionInfoInitial extends VersionInfoState {}

final class VersionInfoLoading extends VersionInfoState {}

final class VersionInfoSuccess extends VersionInfoState {
  const VersionInfoSuccess({required this.packageInfo});
  final PackageInfo packageInfo;

  @override
  List<Object> get props => [packageInfo];
}

final class VersionInfoFailure extends VersionInfoState {}
