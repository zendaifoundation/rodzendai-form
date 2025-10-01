import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rodzendai_form/core/constants/message_constant.dart';

part 'check_register_status_event.dart';
part 'check_register_status_state.dart';

class CheckRegisterStatusBloc
    extends Bloc<CheckRegisterStatusEvent, CheckRegisterStatusState> {
  CheckRegisterStatusBloc() : super(CheckRegisterStatusInitial()) {
    on<CheckRegisterStatusRequestEvent>((
      CheckRegisterStatusRequestEvent event,
      Emitter<CheckRegisterStatusState> emit,
    ) async {
      emit(CheckRegisterStatusLoading());
      try {
        await Future.delayed(const Duration(seconds: 2));
        emit(CheckRegisterStatusSuccess());
      } catch (e) {
        emit(CheckRegisterStatusFailure(message: e.toString()));
      }
    });
  }
}
