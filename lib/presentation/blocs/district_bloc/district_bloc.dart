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
  static List<DistrictModel>? _cacheDistricts;

  /// Find district code by Thai name and province code
  static Future<int?> findDistrictCodeByName(
    String districtNameTh,
    int provinceCode,
  ) async {
    try {
      // Load cache if not already loaded
      if (_cacheDistricts == null) {
        final String response = await rootBundle.loadString(
          'assets/files/districts.json',
        );
        final List<dynamic> data = json.decode(response);
        _cacheDistricts = data
            .map((e) => DistrictModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Search for district by Thai name and province code
      final district = _cacheDistricts?.firstWhereOrNull(
        (d) =>
            d.districtNameTh?.trim() == districtNameTh.trim() &&
            d.provinceCode == provinceCode,
      );

      return district?.districtCode;
    } catch (error, stackTrace) {
      log('Error finding district by name: $error', stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> _onDistrictRequested(
    DistrictRequested event,
    Emitter<DistrictState> emit,
  ) async {
    log('_onDistrictRequested -> ${event.selectedDistrictCode}');
    emit(DistrictLoadInProgress());
    try {
      String? response;

      if (_cacheRecords != null) {
        response = _cacheRecords;
        log('read cache loadString districts');
      } else {
        response = await rootBundle.loadString(
          'assets/files/districts.json',
        );
        log('read loadString districts');
        _cacheRecords = response;
      }

      final List<dynamic> data = response == null
          ? []
          : json.decode(response) as List<dynamic>;

      final districts = data
          .map((e) => DistrictModel.fromJson(e as Map<String, dynamic>))
          .where((district) => district.provinceCode == event.provinceCode)
          .toList();

      DistrictModel? selectedDistrict;
      if (event.selectedDistrictCode != null) {
        selectedDistrict = districts.firstWhereOrNull(
          (district) => district.id == event.selectedDistrictCode,
        );
      }

      emit(
        DistrictLoadSuccess(
          districts: districts,
          selectedDistrictCode: selectedDistrict?.id,
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
