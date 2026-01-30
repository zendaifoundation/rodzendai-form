import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/core/services/places_service.dart';

part 'places_autocomplete_event.dart';
part 'places_autocomplete_state.dart';

class PlacesAutocompleteBloc
    extends Bloc<PlacesAutocompleteEvent, PlacesAutocompleteState> {
  final PlacesService _placesService;
  Timer? _debounce;

  PlacesAutocompleteBloc({required PlacesService placesService})
    : _placesService = placesService,
      super(const PlacesAutocompleteInitial()) {
    on<SearchPlacesEvent>(_onSearchPlaces);
    on<ClearPlacesEvent>(_onClearPlaces);
    on<SelectPlaceEvent>(_onSelectPlace);
  }

  Future<void> _onSearchPlaces(
    SearchPlacesEvent event,
    Emitter<PlacesAutocompleteState> emit,
  ) async {
    // Cancel previous debounce timer
    _debounce?.cancel();

    // Return if query is too short
    if (event.query.length < 2) {
      emit(const PlacesAutocompleteInitial());
      return;
    }

    // Create new debounce timer
    final completer = Completer<void>();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      completer.complete();
    });

    await completer.future;

    emit(const PlacesAutocompleteLoading());

    try {
      log('🔍 Searching places with query: ${event.query}');

      final predictions = await _placesService.searchPlaces(event.query);

      log('✅ Found ${predictions.length} predictions');

      emit(PlacesAutocompleteLoaded(predictions));
    } catch (e) {
      log('❌ Error searching places: $e');
      emit(PlacesAutocompleteError('เกิดข้อผิดพลาดในการค้นหาสถานที่: $e'));
    }
  }

  void _onClearPlaces(
    ClearPlacesEvent event,
    Emitter<PlacesAutocompleteState> emit,
  ) {
    _debounce?.cancel();
    emit(const PlacesAutocompleteInitial());
  }

  void _onSelectPlace(
    SelectPlaceEvent event,
    Emitter<PlacesAutocompleteState> emit,
  ) {
    log('📍 Place selected: ${event.place['description']}');
    emit(PlacesAutocompleteSelected(event.place));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
