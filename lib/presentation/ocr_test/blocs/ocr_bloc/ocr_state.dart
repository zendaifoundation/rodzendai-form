part of 'ocr_bloc.dart';

sealed class OcrState extends Equatable {
  const OcrState();
  @override
  List<Object?> get props => [];
}

class OcrInitial extends OcrState {
  const OcrInitial();
}

class OcrLoading extends OcrState {
  const OcrLoading();
}

class OcrSuccess extends OcrState {
  const OcrSuccess({required this.result, required this.elapsed});
  final IdCardOcrResultModel result;
  final Duration elapsed;
  @override
  List<Object?> get props => [result.raw, elapsed];
}

class OcrFailure extends OcrState {
  const OcrFailure({required this.error, required this.elapsed});
  final AppError error;
  final Duration elapsed;
  @override
  List<Object?> get props => [error.toString(), elapsed];
}
