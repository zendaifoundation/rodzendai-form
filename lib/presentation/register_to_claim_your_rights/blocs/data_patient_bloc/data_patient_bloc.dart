import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/core/services/data_patient_service.dart';
import 'package:rodzendai_form/models/patient_record_model.dart';

part 'data_patient_event.dart';
part 'data_patient_state.dart';

class DataPatientBloc extends Bloc<DataPatientEvent, DataPatientState> {
  DataPatientBloc() : super(DataPatientInitial()) {
    on<LoadDataPatientsEvent>(_onLoadDataPatients);
  }

  Future<void> _onLoadDataPatients(
    LoadDataPatientsEvent event,
    Emitter<DataPatientState> emit,
  ) async {
    emit(DataPatientLoading());

    try {
      final dataPatients = await DataPatientService.loadList();
      emit(DataPatientLoaded(dataPatients: dataPatients));
    } catch (e) {
      emit(DataPatientError('ไม่สามารถโหลดรายชื่อผู้ป่วยที่มีสิทธิ์ได้: $e'));
    }
  }
}
