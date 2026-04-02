part of 'id_card_reader_bloc.dart';

sealed class IdCardReaderState extends Equatable {
  const IdCardReaderState();

  @override
  List<Object?> get props => [];
}

class IDCardInitial extends IdCardReaderState {
  const IDCardInitial();
}

class IDCardConnecting extends IdCardReaderState {
  const IDCardConnecting();
}

class IDCardConnected extends IdCardReaderState {
  const IDCardConnected({required this.agentName});
  /// ชื่อ agent ที่ connect สำเร็จ เช่น "IDWAgent" หรือ "ZendaiAgent"
  final String agentName;
  @override
  List<Object?> get props => [agentName];
}


class IDCardReading extends IdCardReaderState {
  const IDCardReading();
}

class IDCardReadSuccess extends IdCardReaderState {
  const IDCardReadSuccess(this.payload);
  final IDCardPayload payload;
  @override
  List<Object?> get props => [payload];
}

class IDCardFailure extends IdCardReaderState {
  const IDCardFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class IDCardPayload extends Equatable {
  const IDCardPayload({
    required this.idCard,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.bridthDate,
    required this.rawParts,
  });
  final String? idCard;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? address;
  final String? bridthDate;
  final List<String?> rawParts;

  @override
  List<Object?> get props => [
    idCard,
    fullName,
    firstName,
    lastName,
    address,
    bridthDate,
    rawParts,
  ];

  @override
  String toString() {
    return 'IDCardPayload(idCard: $idCard, fullName: $fullName, firstName: $firstName, lastName: $lastName, address: $address,bridthDate : $bridthDate, rawParts: $rawParts)';
  }
}
