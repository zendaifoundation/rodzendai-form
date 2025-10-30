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

  String? _cacheRecords;
  List<SubDistrictModel>? _cacheSubDistricts;
  static List<SubDistrictModel>? _staticCacheSubDistricts;

  /// Find subdistrict code by Thai name and district code
  static Future<int?> findSubDistrictCodeByName(
    String subDistrictNameTh,
    int districtCode,
  ) async {
    try {
      // Load cache if not already loaded
      if (_staticCacheSubDistricts == null) {
        final String response = await rootBundle.loadString(
          'assets/files/subdistricts.json',
        );
        final List<dynamic> data = json.decode(response);
        _staticCacheSubDistricts = data
            .map((e) => SubDistrictModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Search for subdistrict by Thai name and district code
      final subDistrict = _staticCacheSubDistricts?.firstWhereOrNull(
        (sd) =>
            sd.subdistrictNameTh?.trim() == subDistrictNameTh.trim() &&
            sd.districtCode == districtCode,
      );

      return subDistrict?.subdistrictCode;
    } catch (error, stackTrace) {
      log('Error finding subdistrict by name: $error', stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> _onSubDistrictRequested(
    SubDistrictRequested event,
    Emitter<SubDistrictState> emit,
  ) async {
    log('_onSubDistrictRequested -> ${event.selectedSubDistrictCode}');
    emit(SubDistrictLoadInProgress());
    try {
      String? response;

      if (_cacheRecords != null) {
        response = _cacheRecords;
        log('read cache loadString thai_subdistricts');
      } else {
        response = await rootBundle.loadString(
          'assets/files/subdistricts.json',
        );
        _cacheRecords = response;
        log('read loadString thai_subdistricts');
      }

      final List<dynamic> data = response == null
          ? []
          : json.decode(response) as List<dynamic>;

      final subDistricts = data
          .map((e) => SubDistrictModel.fromJson(e as Map<String, dynamic>))
          .where(
            (subDistrict) => subDistrict.districtCode == event.districtCode,
          )
          .toList();
      _cacheSubDistricts = subDistricts;

      SubDistrictModel? selectedSubDistrict;
      if (event.selectedSubDistrictCode != null) {
        selectedSubDistrict = subDistricts.firstWhereOrNull(
          (subDistrict) =>
              subDistrict.subdistrictCode == event.selectedSubDistrictCode,
        );
      }

      emit(
        SubDistrictLoadSuccess(
          subDistricts: subDistricts,
          selectedSubDistrictCode: selectedSubDistrict?.subdistrictCode,
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
