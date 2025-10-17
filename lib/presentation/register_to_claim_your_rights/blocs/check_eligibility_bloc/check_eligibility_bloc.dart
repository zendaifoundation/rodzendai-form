import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rodzendai_form/core/constants/message_constant.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/repositories/patient_repository.dart';

part 'check_eligibility_event.dart';
part 'check_eligibility_state.dart';

class CheckEligibilityBloc
    extends Bloc<CheckEligibilityEvent, CheckEligibilityState> {
  CheckEligibilityBloc() : super(CheckEligibilityInitial()) {
    on<CheckEligibilityRequestEvent>(_onCheckEligibilityRequestEvent);
  }

  Future<void> _onCheckEligibilityRequestEvent(
    CheckEligibilityRequestEvent event,
    Emitter<CheckEligibilityState> emit,
  ) async {
    try {
      log('_onCheckEligibilityRequestEvent -> event: $event');
      emit(CheckEligibilityLoading());

      final PatientRepository patientRepository = locator<PatientRepository>();
      final checkEligibilityModel = await patientRepository.checkEligibility(
        patientIdCardNumber: event.idCardNumber,
      );

      log('checkEligibility Response: ${checkEligibilityModel.toJson()}');

      // Handle different eligibility scenarios
      final isEligible = checkEligibilityModel.data?.isEligible ?? false;
      final message = checkEligibilityModel.data?.reason ?? '';
      final patientData = checkEligibilityModel.data;

      log('Status: success=$isEligible, message=$message');
      log(
        'Patient: name=${patientData?.patient?.name}, type=${patientData?.patient?.type}, hospital=${patientData?.patient?.hospital}',
      );

      if (isEligible) {
        // Patient is eligible
        emit(CheckEligibilitySuccess());
      } else {
        // Patient is not eligible - show reason from server
        final failureMessage = message.isNotEmpty
            ? message
            : 'ท่านไม่สามารถเข้าร่วมโครงการนี้ได้ในขณะนี้';
        log('Patient not eligible: $failureMessage');
        emit(CheckEligibilityFailure(message: failureMessage));
      }
    } on Exception catch (e) {
      // Handle specific exceptions from repository
      log('CheckEligibilityBloc Exception: $e');
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      log('CheckEligibilityBloc errorMessage : $errorMessage');
      emit(CheckEligibilityFailure(message: 'The connection errored'));
    } catch (e) {
      // Unexpected errors
      log('CheckEligibilityBloc Unexpected error: $e');
      emit(CheckEligibilityFailure(message: 'The connection errored'));
    }
  }
}
