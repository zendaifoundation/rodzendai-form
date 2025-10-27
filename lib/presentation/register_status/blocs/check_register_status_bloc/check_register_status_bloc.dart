import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rodzendai_form/core/constants/message_constant.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/models/get_patient_transport_response_model.dart';
import 'package:rodzendai_form/presentation/register_status/models/patient_transport_item_model.dart';
import 'package:rodzendai_form/repositories/firebase_repository.dart';
import 'package:rodzendai_form/repositories/patient_repository.dart';

part 'check_register_status_event.dart';
part 'check_register_status_state.dart';

class CheckRegisterStatusBloc
    extends Bloc<CheckRegisterStatusEvent, CheckRegisterStatusState> {
  final FirebaseRepository _firebaseRepository;

  CheckRegisterStatusBloc({required FirebaseRepository firebaseRepository})
    : _firebaseRepository = firebaseRepository,
      super(CheckRegisterStatusInitial()) {
    on<CheckRegisterStatusRequestEvent>(_onCheckRegisterStatusRequestEvent);
  }

  // FutureOr<void> _onCheckRegisterStatusRequestEvent(
  //   CheckRegisterStatusRequestEvent event,
  //   Emitter<CheckRegisterStatusState> emit,
  // ) async {
  //   emit(CheckRegisterStatusLoading());
  //   try {
  //     final checkRegisterStatus = await _firebaseRepository.checkRegisterStatus(
  //       idCardNumber: event.idCardNumber,
  //       travelDate: event.travelDate,
  //     );
  //     final checkRegisterStatusCasefromCRM = await _firebaseRepository
  //         .checkRegisterStatusCasefromCRM(
  //           idCardNumber: event.idCardNumber,
  //           //travelDate: event.travelDate,
  //         );

  //     List<PatientTransportItemModel> items = [];

  //     for (var element in checkRegisterStatus) {
  //       items.add(
  //         PatientTransportItemModel.fromPatientTransportsModel(element),
  //       );
  //     }

  //     for (var element in checkRegisterStatusCasefromCRM) {
  //       items.add(
  //         PatientTransportItemModel.fromPatientTransportsCaseCrmModel(element),
  //       );
  //     }

  //     emit(CheckRegisterStatusSuccess(data: items));
  //   } catch (e) {
  //     emit(CheckRegisterStatusFailure(message: e.toString()));
  //   }
  // }

  Future<void> _onCheckRegisterStatusRequestEvent(
    CheckRegisterStatusRequestEvent event,
    Emitter<CheckRegisterStatusState> emit,
  ) async {
    emit(CheckRegisterStatusLoading());
    try {
      final PatientRepository patientRepository = locator<PatientRepository>();
      final response = await patientRepository.getPatientTransport(
        idCardNumber: event.idCardNumber,
      );
      emit(CheckRegisterStatusSuccess(data: response.data ?? []));
    } catch (e) {
      emit(CheckRegisterStatusFailure(message: e.toString()));
    }
  }
}
