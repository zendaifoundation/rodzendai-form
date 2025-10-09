part of 'hospital_bloc.dart';

abstract class HospitalEvent {}

class LoadHospitalsEvent extends HospitalEvent {}

class SearchHospitalsEvent extends HospitalEvent {
  final String query;

  SearchHospitalsEvent(this.query);
}
