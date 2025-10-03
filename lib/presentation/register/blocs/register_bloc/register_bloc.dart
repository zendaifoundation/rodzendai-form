import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rodzendai_form/core/constants/message_constant.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterEvent>((event, emit) async {
      try {
        emit(RegisterLoading());
        await Future.delayed(const Duration(seconds: 2));
        emit(RegisterSuccess());
      } catch (e) {
        emit(RegisterFailure());
      }
    });
  }
}
