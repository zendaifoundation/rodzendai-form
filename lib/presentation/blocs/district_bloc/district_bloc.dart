import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/models/district_model.dart';

part 'district_event.dart';
part 'district_state.dart';

class DistrictBloc extends Bloc<DistrictEvent, DistrictState> {
  DistrictBloc() : super(DistrictInitial()) {
    on<DistrictRequested>(_onDistrictRequested);
    on<DistrictCleared>(_onDistrictCleared);
  }

  String? _cacheRecords;

  Future<void> _onDistrictRequested(
    DistrictRequested event,
    Emitter<DistrictState> emit,
  ) async {
    log('_onDistrictRequested -> ${event.selectedDistrictId}');
    emit(DistrictLoadInProgress());
    try {
      String? response;

      if (_cacheRecords != null) {
        response = _cacheRecords;
        log('read cache loadString thai_districts');
      } else {
        response = await rootBundle.loadString(
          'assets/files/thai_districts.json',
        );
        log('read loadString thai_districts');
        _cacheRecords = response;
      }

      final List<dynamic> data = response == null
          ? []
          : json.decode(response) as List<dynamic>;

      final districts = data
          .map((e) => DistrictModel.fromJson(e as Map<String, dynamic>))
          .where((district) => district.provinceId == event.provinceId)
          .toList();

      DistrictModel? selectedDistrict;
      if (event.selectedDistrictId != null) {
        selectedDistrict = districts.firstWhereOrNull(
          (district) => district.id == event.selectedDistrictId,
        );
      }

      emit(
        DistrictLoadSuccess(
          districts: districts,
          selectedDistrictId: selectedDistrict?.id,
        ),
      );
    } catch (error, stackTrace) {
      log('Error loading districts: $error', stackTrace: stackTrace);
      emit(
        const DistrictLoadFailure(message: 'ไม่สามารถโหลดรายชื่ออำเภอ/เขตได้'),
      );
    }
  }

  void _onDistrictCleared(DistrictCleared event, Emitter<DistrictState> emit) {
    emit(DistrictInitial());
  }
}
