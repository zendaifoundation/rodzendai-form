import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rodzendai_form/core/error/app_error.dart';
import 'package:rodzendai_form/core/network/api_result.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/models/id_card_ocr_result_model.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_file_widget.dart';
import 'package:rodzendai_form/repositories/ocr_repository.dart';

part 'ocr_event.dart';
part 'ocr_state.dart';

class OcrBloc extends Bloc<OcrEvent, OcrState> {
  OcrBloc({OcrRepository? repository})
    : _repository = repository ?? locator<OcrRepository>(),
      super(const OcrInitial()) {
    on<OcrReadIdCardRequested>(_onReadIdCard);
    on<OcrResetRequested>((_, emit) => emit(const OcrInitial()));
  }

  final OcrRepository _repository;

  Future<void> _onReadIdCard(
    OcrReadIdCardRequested event,
    Emitter<OcrState> emit,
  ) async {
    emit(const OcrLoading());
    final stopwatch = Stopwatch()..start();
    final result = await _repository.readThaiIdCard(
      file: event.file,
      provider: event.provider,
    );
    stopwatch.stop();

    switch (result) {
      case ApiSuccess(:final data):
        emit(OcrSuccess(result: data, elapsed: stopwatch.elapsed));
      case ApiFailure(:final error):
        emit(OcrFailure(error: error, elapsed: stopwatch.elapsed));
    }
  }
}
