import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/core/network/api_result.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/repositories/patient_repository.dart';

part 'update_patient_event.dart';
part 'update_patient_state.dart';

class UpdatePatientBloc extends Bloc<UpdatePatientEvent, UpdatePatientState> {
  UpdatePatientBloc() : super(UpdatePatientInitial()) {
    on<UpdatePatientSubmitEvent>(_onUpdate);
    on<UpdatePatientReset>(_onReset);
  }

  Future<void> _onUpdate(
    UpdatePatientSubmitEvent event,
    Emitter<UpdatePatientState> emit,
  ) async {
    emit(UpdatePatientLoading());
    try {
      log('📝 UpdatePatientBloc: updating patient ${event.idCardNumber}');
      final result = await locator<PatientRepository>().updatePatient(
        patientIdCardNumber: event.idCardNumber,
        updateData: event.updateData,
      );

      switch (result) {
        case ApiSuccess():
          log('✅ UpdatePatientBloc: success');
          emit(UpdatePatientSuccess());
        case ApiFailure(:final error):
          log('❌ UpdatePatientBloc: ${error.message}');
          emit(UpdatePatientFailure(message: error.message));
      }
    } catch (e) {
      log('❌ UpdatePatientBloc error: $e');
      emit(UpdatePatientFailure(message: e.toString()));
    }
  }

  void _onReset(UpdatePatientReset event, Emitter<UpdatePatientState> emit) {
    emit(UpdatePatientInitial());
  }
}
