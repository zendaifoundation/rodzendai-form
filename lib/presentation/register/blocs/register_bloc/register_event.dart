part of 'register_bloc.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterRequestEvent extends RegisterEvent {
  const RegisterRequestEvent({
    required this.data,
    required this.dataCaseCRM,
    this.documentAppointmentFile,
  });

  final Map<String, dynamic> data;
  final Map<String, dynamic> dataCaseCRM;
  final UploadedFile? documentAppointmentFile;

  @override
  List<Object?> get props => [documentAppointmentFile, dataCaseCRM];
}
