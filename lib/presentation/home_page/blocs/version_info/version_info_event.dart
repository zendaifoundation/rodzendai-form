part of 'version_info_bloc.dart';

sealed class VersionInfoEvent extends Equatable {
  const VersionInfoEvent();

  @override
  List<Object> get props => [];
}

class VersionInfoGetEvent extends VersionInfoEvent {
  const VersionInfoGetEvent();
}
