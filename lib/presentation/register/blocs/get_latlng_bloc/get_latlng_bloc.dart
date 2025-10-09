import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rodzendai_form/core/services/geocoding_service.dart';

part 'get_latlng_event.dart';
part 'get_latlng_state.dart';

class GetLatLngBloc extends Bloc<GetLatLngEvent, GetLatLngState> {
  final GeocodingService _geocodingService;

  GetLatLngBloc({GeocodingService? geocodingService})
    : _geocodingService = geocodingService ?? GeocodingService(),
      super(GetLatLngInitial()) {
    on<GetLatLngFromPlaceIdEvent>(_onGetLatLngFromPlaceId);
    on<GetLatLngFromAddressEvent>(_onGetLatLngFromAddress);
  }

  /// จัดการ event ดึง lat/lng จาก place_id
  FutureOr<void> _onGetLatLngFromPlaceId(
    GetLatLngFromPlaceIdEvent event,
    Emitter<GetLatLngState> emit,
  ) async {
    try {
      emit(GetLatLngLoading());

      log('🔍 Fetching lat/lng from place_id: ${event.placeId}');

      final result = await _geocodingService.getLatLngFromPlaceId(
        event.placeId,
      );

      if (result != null) {
        final lat = result['lat'];
        final lng = result['lng'];

        if (lat != null && lng != null) {
          log('✅ Lat/Lng found: $lat, $lng');
          emit(GetLatLngSuccess(latitude: lat, longitude: lng));
        } else {
          log('❌ Lat/Lng is null');
          emit(
            const GetLatLngFailure(
              message: 'ไม่สามารถดึงพิกัดจาก Place ID ได้',
            ),
          );
        }
      } else {
        log('❌ Result is null');
        emit(
          const GetLatLngFailure(
            message: 'ไม่พบข้อมูลพิกัดสำหรับ Place ID นี้',
          ),
        );
      }
    } catch (e) {
      log('❌ Error fetching lat/lng from place_id: $e');
      emit(GetLatLngFailure(message: 'เกิดข้อผิดพลาด: ${e.toString()}'));
    }
  }

  /// จัดการ event ดึง lat/lng จากที่อยู่
  FutureOr<void> _onGetLatLngFromAddress(
    GetLatLngFromAddressEvent event,
    Emitter<GetLatLngState> emit,
  ) async {
    try {
      emit(GetLatLngLoading());

      log('🔍 Fetching lat/lng from address: ${event.address}');

      final result = await _geocodingService.getLatLngFromAddress(
        event.address,
      );

      if (result != null) {
        final lat = result['lat'];
        final lng = result['lng'];

        if (lat != null && lng != null) {
          log('✅ Lat/Lng found: $lat, $lng');
          emit(GetLatLngSuccess(latitude: lat, longitude: lng));
        } else {
          log('❌ Lat/Lng is null');
          emit(
            const GetLatLngFailure(message: 'ไม่สามารถดึงพิกัดจากที่อยู่ได้'),
          );
        }
      } else {
        log('❌ Result is null');
        emit(
          const GetLatLngFailure(message: 'ไม่พบข้อมูลพิกัดสำหรับที่อยู่นี้'),
        );
      }
    } catch (e) {
      log('❌ Error fetching lat/lng from address: $e');
      emit(GetLatLngFailure(message: 'เกิดข้อผิดพลาด: ${e.toString()}'));
    }
  }
}
