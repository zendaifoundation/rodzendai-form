import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/models/patient_response_model.dart';
import 'package:rodzendai_form/repositories/patient_repository.dart';

part 'get_patient_event.dart';
part 'get_patient_state.dart';

class GetPatientBloc extends Bloc<GetPatientEvent, GetPatientState> {
  GetPatientBloc() : super(GetPatientInitial()) {
    on<GetPatientByIdCardEvent>(_onGetPatient);
    on<GetPatientReset>(_onReset);
  }

  Future<void> _onGetPatient(
    GetPatientByIdCardEvent event,
    Emitter<GetPatientState> emit,
  ) async {
    emit(GetPatientLoading());
    try {
      log('🔍 GetPatientBloc: fetching patient ${event.idCardNumber}');
      final response = await locator<PatientRepository>()
          .getPatientByIdCardNumber(idCardNumber: event.idCardNumber);

      if (response.success == true && response.data != null) {
        log('✅ GetPatientBloc: success');
        emit(GetPatientSuccess(patient: response.data!));
      } else {
        final msg = response.message ?? 'ไม่พบข้อมูลผู้ป่วย';
        log('❌ GetPatientBloc: ${response.message}');
        emit(GetPatientFailure(message: msg));
      }
    } catch (e) {
      log('❌ GetPatientBloc error: $e');
      emit(GetPatientFailure(message: e.toString()));
    }
  }

  void _onReset(GetPatientReset event, Emitter<GetPatientState> emit) {
    emit(GetPatientInitial());
  }
}
