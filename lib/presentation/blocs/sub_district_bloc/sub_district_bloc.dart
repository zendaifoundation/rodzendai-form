import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/models/sub_district_model.dart';

part 'sub_district_event.dart';
part 'sub_district_state.dart';

class SubDistrictBloc extends Bloc<SubDistrictEvent, SubDistrictState> {
  SubDistrictBloc() : super(SubDistrictInitial()) {
    on<SubDistrictRequested>(_onSubDistrictRequested);
    on<SubDistrictCleared>(_onSubDistrictCleared);
  }

  Future<void> _onSubDistrictRequested(
    SubDistrictRequested event,
    Emitter<SubDistrictState> emit,
  ) async {
    emit(SubDistrictLoadInProgress());
    try {
      final String response = await rootBundle.loadString(
        'assets/files/thai_subdistricts.json',
      );
      final List<dynamic> data = json.decode(response) as List<dynamic>;

      final subDistricts = data
          .map((e) => SubDistrictModel.fromJson(e as Map<String, dynamic>))
          .where((subDistrict) => subDistrict.amphureId == event.districtId)
          .toList();

      SubDistrictModel? selectedSubDistrict;
      if (event.selectedSubDistrictId != null) {
        selectedSubDistrict = subDistricts.firstWhereOrNull(
          (subDistrict) => subDistrict.id == event.selectedSubDistrictId,
        );
      }

      emit(
        SubDistrictLoadSuccess(
          subDistricts: subDistricts,
          selectedSubDistrictId: selectedSubDistrict?.id,
        ),
      );
    } catch (error, stackTrace) {
      log('Error loading sub-districts: $error', stackTrace: stackTrace);
      emit(
        const SubDistrictLoadFailure(
          message: 'ไม่สามารถโหลดรายชื่อตำบล/แขวงได้',
        ),
      );
    }
  }

  void _onSubDistrictCleared(
    SubDistrictCleared event,
    Emitter<SubDistrictState> emit,
  ) {
    emit(SubDistrictInitial());
  }
}
