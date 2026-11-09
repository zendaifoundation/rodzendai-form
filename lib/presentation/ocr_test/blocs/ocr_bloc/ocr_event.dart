part of 'ocr_bloc.dart';

sealed class OcrEvent extends Equatable {
  const OcrEvent();
  @override
  List<Object?> get props => [];
}

class OcrReadIdCardRequested extends OcrEvent {
  const OcrReadIdCardRequested(this.file, {this.provider});
  final UploadedFile file;

  /// null = ให้ server ใช้ engine default
  final OcrProvider? provider;
  @override
  List<Object?> get props => [file.name, file.size, provider];
}

class OcrResetRequested extends OcrEvent {
  const OcrResetRequested();
}
