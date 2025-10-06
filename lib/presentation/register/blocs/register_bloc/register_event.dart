part of 'register_bloc.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterRequestEvent extends RegisterEvent {
  const RegisterRequestEvent({
    required this.data,
    this.documentAppointmentFile,
  });

  final Map<String, dynamic> data;
  final UploadedFile? documentAppointmentFile;

  @override
  List<Object?> get props => [documentAppointmentFile];
}
