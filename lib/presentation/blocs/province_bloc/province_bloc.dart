import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/models/province_model.dart';

part 'province_event.dart';
part 'province_state.dart';

class ProvinceBloc extends Bloc<ProvinceEvent, ProvinceState> {
  ProvinceBloc() : super(ProvinceInitial()) {
    on<ProvinceRequested>(_onProvinceRequested);
  }

  static List<ProvinceModel>? _cacheProvinces;

  Future<void> _onProvinceRequested(
    ProvinceRequested event,
    Emitter<ProvinceState> emit,
  ) async {
    log('_onProvinceRequested -> ${event.selectedProvinceCode}');
    emit(ProvinceLoadInProgress());
    try {
      final String response = await rootBundle.loadString(
        'assets/files/provinces.json',
      );
      log('read loadString thai_provinces');
      final List<dynamic> data = json.decode(response);
      final provinces = data
          .map((e) => ProvinceModel.fromJson(e as Map<String, dynamic>))
          .toList();

      _cacheProvinces = provinces;
      ProvinceModel? selectedProvince;
      if (event.selectedProvinceCode != null) {
        selectedProvince = provinces.firstWhereOrNull(
          (province) => province.id == event.selectedProvinceCode,
        );
      }

      emit(
        ProvinceLoadSuccess(
          provinces: provinces,
          selectedProvinceCode: selectedProvince?.id,
        ),
      );
    } catch (error, stackTrace) {
      log('Error loading provinces: $error', stackTrace: stackTrace);
      emit(ProvinceLoadFailure(message: 'ไม่สามารถโหลดรายชื่อจังหวัดได้'));
    }
  }
}
