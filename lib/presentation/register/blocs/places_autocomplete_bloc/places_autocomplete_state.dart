part of 'places_autocomplete_bloc.dart';

abstract class PlacesAutocompleteState extends Equatable {
  const PlacesAutocompleteState();

  @override
  List<Object?> get props => [];
}

class PlacesAutocompleteInitial extends PlacesAutocompleteState {
  const PlacesAutocompleteInitial();
}

class PlacesAutocompleteLoading extends PlacesAutocompleteState {
  const PlacesAutocompleteLoading();
}

class PlacesAutocompleteLoaded extends PlacesAutocompleteState {
  final List<Map<String, dynamic>> predictions;

  const PlacesAutocompleteLoaded(this.predictions);

  @override
  List<Object?> get props => [predictions];
}

class PlacesAutocompleteError extends PlacesAutocompleteState {
  final String message;

  const PlacesAutocompleteError(this.message);

  @override
  List<Object?> get props => [message];
}

class PlacesAutocompleteSelected extends PlacesAutocompleteState {
  final Map<String, dynamic> selectedPlace;

  const PlacesAutocompleteSelected(this.selectedPlace);

  @override
  List<Object?> get props => [selectedPlace];
}
