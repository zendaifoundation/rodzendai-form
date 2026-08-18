part of 'id_card_reader_bloc.dart';

sealed class IdCardReaderEvent extends Equatable {
  const IdCardReaderEvent();

  @override
  List<Object?> get props => [];
}

class IDCardConnectRequested extends IdCardReaderEvent {
  const IDCardConnectRequested();
}

class IDCardSelectReaderRequested extends IdCardReaderEvent {
  const IDCardSelectReaderRequested({required this.readerName});
  final String readerName;
  @override
  List<Object?> get props => [readerName];
}

class IDCardReadRequested extends IdCardReaderEvent {
  const IDCardReadRequested();
}

class IDCardResetRequested extends IdCardReaderEvent {
  const IDCardResetRequested();
}

class _IDCardSocketMessage extends IdCardReaderEvent {
  const _IDCardSocketMessage(this.raw);
  final dynamic raw;
  @override
  List<Object?> get props => [raw];
}

class _IDCardSocketError extends IdCardReaderEvent {
  const _IDCardSocketError(this.message);
  final Object message;
  @override
  List<Object?> get props => [message];
}


class IDCardCloseRequested extends IdCardReaderEvent {
  const IDCardCloseRequested();
}