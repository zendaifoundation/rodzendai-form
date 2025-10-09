part of 'hospital_bloc.dart';

abstract class HospitalState {}

class HospitalInitial extends HospitalState {}

class HospitalLoading extends HospitalState {}

class HospitalLoaded extends HospitalState {
  final List<String> hospitals;
  final List<String> filteredHospitals;

  HospitalLoaded({required this.hospitals, List<String>? filteredHospitals})
    : filteredHospitals = filteredHospitals ?? hospitals;
}

class HospitalError extends HospitalState {
  final String message;

  HospitalError(this.message);
}
