import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'version_info_event.dart';
part 'version_info_state.dart';

class VersionInfoBloc extends Bloc<VersionInfoEvent, VersionInfoState> {
  VersionInfoBloc() : super(VersionInfoInitial()) {
    on<VersionInfoGetEvent>(_versionInfoGetEvent);
  }

  Future<void> _versionInfoGetEvent(VersionInfoGetEvent event, Emitter<VersionInfoState> emit) async {
    emit(VersionInfoLoading());
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      emit(VersionInfoSuccess(packageInfo: packageInfo));
    } catch (e) {
      log('_versionInfoGetEvent error $e');
      emit(VersionInfoFailure());
    }
  }
}
