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

  Future<void> _onDistrictRequested(
    DistrictRequested event,
    Emitter<DistrictState> emit,
  ) async {
    emit(DistrictLoadInProgress());
    try {
      final String response =
          await rootBundle.loadString('assets/files/thai_districts.json');
      final List<dynamic> data = json.decode(response) as List<dynamic>;

      final districts = data
          .map(
            (e) => DistrictModel.fromJson(e as Map<String, dynamic>),
          )
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
        const DistrictLoadFailure(
          message: 'ไม่สามารถโหลดรายชื่ออำเภอ/เขตได้',
        ),
      );
    }
  }

  void _onDistrictCleared(
    DistrictCleared event,
    Emitter<DistrictState> emit,
  ) {
    emit(DistrictInitial());
  }
}
