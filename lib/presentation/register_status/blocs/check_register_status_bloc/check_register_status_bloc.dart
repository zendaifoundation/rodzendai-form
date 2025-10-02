import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rodzendai_form/core/constants/message_constant.dart';
import 'package:rodzendai_form/models/patient_transports_model.dart';
import 'package:rodzendai_form/repositories/firebase_repository.dart';

part 'check_register_status_event.dart';
part 'check_register_status_state.dart';

class CheckRegisterStatusBloc
    extends Bloc<CheckRegisterStatusEvent, CheckRegisterStatusState> {
  final FirebaseRepository _firebaseRepository;

  CheckRegisterStatusBloc({FirebaseRepository? firebaseRepository})
    : _firebaseRepository = firebaseRepository ?? FirebaseRepository(),
      super(CheckRegisterStatusInitial()) {
    on<CheckRegisterStatusRequestEvent>((
      CheckRegisterStatusRequestEvent event,
      Emitter<CheckRegisterStatusState> emit,
    ) async {
      emit(CheckRegisterStatusLoading());
      try {
        final result = await _firebaseRepository.checkRegisterStatus(
          idCardNumber: event.idCardNumber,
          travelDate: event.travelDate,
        );
        emit(CheckRegisterStatusSuccess(data: result));
      } catch (e) {
        emit(CheckRegisterStatusFailure(message: e.toString()));
      }
    });
  }
}
