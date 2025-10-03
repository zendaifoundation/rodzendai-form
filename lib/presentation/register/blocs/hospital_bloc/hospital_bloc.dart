import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/core/services/hospital_service.dart';

part 'hospital_event.dart';
part 'hospital_state.dart';

class HospitalBloc extends Bloc<HospitalEvent, HospitalState> {
  HospitalBloc() : super(HospitalInitial()) {
    on<LoadHospitalsEvent>(_onLoadHospitals);
    on<SearchHospitalsEvent>(_onSearchHospitals);
  }

  Future<void> _onLoadHospitals(
    LoadHospitalsEvent event,
    Emitter<HospitalState> emit,
  ) async {
    emit(HospitalLoading());

    try {
      final hospitals = await HospitalService.loadHospitals();
      emit(HospitalLoaded(hospitals: hospitals));
    } catch (e) {
      emit(HospitalError('ไม่สามารถโหลดรายชื่อโรงพยาบาลได้: $e'));
    }
  }

  Future<void> _onSearchHospitals(
    SearchHospitalsEvent event,
    Emitter<HospitalState> emit,
  ) async {
    if (state is HospitalLoaded) {
      final currentState = state as HospitalLoaded;
      final filteredHospitals = HospitalService.searchHospitals(
        currentState.hospitals,
        event.query,
      );

      emit(
        HospitalLoaded(
          hospitals: currentState.hospitals,
          filteredHospitals: filteredHospitals,
        ),
      );
    }
  }
}
