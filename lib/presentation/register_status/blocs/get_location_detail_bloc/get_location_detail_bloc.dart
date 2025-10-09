import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rodzendai_form/core/constants/message_constant.dart';
import 'package:rodzendai_form/core/services/geocoding_service.dart';

part 'get_location_detail_event.dart';
part 'get_location_detail_state.dart';

class GetLocationDetailBloc
    extends Bloc<GetLocationDetailEvent, GetLocationDetailState> {
  final GeocodingService _geocodingService;

  GetLocationDetailBloc({GeocodingService? geocodingService})
    : _geocodingService = geocodingService ?? GeocodingService(),
      super(GetLocationDetailInitial()) {
    on<GetLocationDetailRequestEvent>(_onGetLocationDetailRequestEvent);
  }

  FutureOr<void> _onGetLocationDetailRequestEvent(
    GetLocationDetailRequestEvent event,
    Emitter<GetLocationDetailState> emit,
  ) async {
    try {
      emit(GetLocationDetailLoading());

      log('🔍 Fetching address for: ${event.latitude}, ${event.longitude}');

      final addressDetail = await _geocodingService.getAddressDetail(
        latitude: event.latitude,
        longitude: event.longitude,
      );

      if (addressDetail != null) {
        log('✅ Address found: ${addressDetail.formattedAddress}');
        emit(GetLocationDetailSuccess(addressDetail: addressDetail));
      } else {
        log('❌ Address not found');
        emit(
          const GetLocationDetailFailure(
            message: 'ไม่สามารถค้นหาที่อยู่จากพิกัดนี้ได้',
          ),
        );
      }
    } catch (e) {
      log('❌ Error fetching address: $e');
      emit(
        GetLocationDetailFailure(message: 'เกิดข้อผิดพลาด: ${e.toString()}'),
      );
    }
  }
}
