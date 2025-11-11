part of 'places_autocomplete_bloc.dart';

abstract class PlacesAutocompleteEvent extends Equatable {
  const PlacesAutocompleteEvent();

  @override
  List<Object?> get props => [];
}

class SearchPlacesEvent extends PlacesAutocompleteEvent {
  final String query;

  const SearchPlacesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearPlacesEvent extends PlacesAutocompleteEvent {
  const ClearPlacesEvent();
}

class SelectPlaceEvent extends PlacesAutocompleteEvent {
  final Map<String, dynamic> place;

  const SelectPlaceEvent(this.place);

  @override
  List<Object?> get props => [place];
}
