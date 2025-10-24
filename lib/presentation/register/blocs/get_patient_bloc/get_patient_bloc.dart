import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rodzendai_form/core/constants/message_constant.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/models/patient_response_model.dart';
import 'package:rodzendai_form/repositories/patient_repository.dart';

part 'get_patient_event.dart';
part 'get_patient_state.dart';

class GetPatientBloc extends Bloc<GetPatientEvent, GetPatientState> {
  GetPatientBloc() : super(GetPatientInitial()) {
    on<GetPatientRequestEvent>((
      GetPatientRequestEvent event,
      Emitter<GetPatientState> emit,
    ) async {
      try {
        emit(GetPatientLoading());
        final response = await locator<PatientRepository>()
            .getPatientByIdCardNumber(idCardNumber: event.idCardNumber);
        log('GetPatientBloc Response: $response');
        if (response.code == '00' && response.data != null) {
          //return emit(GetPatientSuccess(patientData: response.data!));

          if (response.data?.remainingRights == 0) {
            return emit(
              GetPatientFailure(
                message:
                    'ไม่สามารถใช้สิทธิ์จองรถได้ เนื่องจากใช้สิทธิ์ครบแล้ว\nสามารถติดต่อเจ้าหน้าที่เพื่อสอบถามข้อมูลเพิ่มเติม',
              ),
            );
          } else {
            return emit(GetPatientSuccess(patientData: response.data!));
          }
        } else {
          return emit(
            GetPatientFailure(
              message:
                  'ไม่พบข้อมูลผู้ป่วยในระบบ กรุณาตรวจสอบหมายเลขบัตรประชาชนอีกครั้ง',
            ),
          );
        }
      } catch (e) {
        log('GetPatientBloc Error: $e');
        emit(GetPatientFailure(message: MessageConstant.submitting));
      }
    });
  }
}
