import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'id_card_reader_event.dart';
part 'id_card_reader_state.dart';

class IdCardReaderBloc extends Bloc<IdCardReaderEvent, IdCardReaderState> {
  IdCardReaderBloc({
    // this.agentUri =
    //     'ws://localhost:14820/IDWAgent', // For local testing with IDWAgent
    this.agentUri =
        'ws://192.168.1.119:14820/IDWAgent', // android ip address  URI
  }) : super(IDCardInitial()) {
    on<IDCardConnectRequested>(_onConnectRequested);
    on<IDCardSelectReaderRequested>(_onSelectReaderRequested);
    on<IDCardReadRequested>(_onReadRequested);
    on<_IDCardSocketMessage>(_onSocketMessage);
    on<_IDCardSocketError>(_onSocketError);
    on<IDCardResetRequested>(_onResetRequested);
    on<IDCardCloseRequested>(_onIDCardCloseRequested);
  }

  final String agentUri;
  WebSocketChannel? _channel;
  StreamSubscription? _channelSub;

  Future<void> _onConnectRequested(
    IDCardConnectRequested event,
    Emitter<IdCardReaderState> emit,
  ) async {
    if (_channel != null) return;
    emit(const IDCardConnecting());
    try {
      _channel = WebSocketChannel.connect(Uri.parse(agentUri));
      _channelSub = _channel!.stream.listen(
        (dynamic raw) => add(_IDCardSocketMessage(raw)),
        onError: (Object err, StackTrace st) => add(_IDCardSocketError(err)),
        onDone: () => add(const _IDCardSocketError('Connection closed')),
      );
      emit(const IDCardConnected());
      _sendJson({'Command': 'GetReaderList'});
    } catch (err) {
      emit(IDCardFailure(err.toString()));
    }
  }

  void _onSelectReaderRequested(
    IDCardSelectReaderRequested event,
    Emitter<IdCardReaderState> emit,
  ) {
    if (_channel == null) return;
    _sendJson({'Command': 'SelectReader', 'ReaderName': event.readerName});
  }

  void _onReadRequested(
    IDCardReadRequested event,
    Emitter<IdCardReaderState> emit,
  ) {
    if (_channel == null) return;
    emit(const IDCardReading());
    _sendJson({
      'Command': 'ReadIDCard',
      'IDNumberRead': true,
      'IDTextRead': true,
      'IDPhotoRead': false,
      'IDATextRead': true,
    });
  }

  Future<void> _onSocketMessage(
    _IDCardSocketMessage event,
    Emitter<IdCardReaderState> emit,
  ) async {
    final dynamic decoded = event.raw is String
        ? jsonDecode(event.raw as String)
        : event.raw;
    final message = decoded['Message'] as String?;

    if (message == 'GetReaderListR') {
      final readers = (decoded['ReaderList'] as List?)?.cast<String>() ?? [];
      if (readers.isEmpty) {
        emit(const IDCardFailure('ไม่พบเครื่องอ่านบัตร'));
      } else {
        emit(IDCardReaderListLoaded(readers: readers));
        add(IDCardSelectReaderRequested(readerName: readers.first));
      }
      return;
    }

    if (message == 'SelectReaderR') {
      emit(IDCardReaderReady(readerName: decoded['ReaderName'] as String?));
      return;
    }

    if (message == 'ReadIDCardR') {
      final payload = _parseReadCard(decoded);
      if (payload == null) {
        emit(const IDCardFailure('อ่านบัตรไม่สำเร็จ'));
      } else {
        emit(IDCardReadSuccess(payload));
      }
      return;
    }
  }

  void _onSocketError(
    _IDCardSocketError event,
    Emitter<IdCardReaderState> emit,
  ) {
    if (event.message == 'Failed to connect WebSocket') {
      log('ไม่สามารถเชื่อมต่อกับ ID Card Agent ได้');
    }
    emit(IDCardFailure(event.message.toString()));
    _disposeChannel();
  }

  void _onResetRequested(
    IDCardResetRequested event,
    Emitter<IdCardReaderState> emit,
  ) {
    _disposeChannel();
    emit(const IDCardInitial());
  }

  void _sendJson(Map<String, dynamic> payload) {
    _channel?.sink.add(jsonEncode(payload));
  }

  void _onIDCardCloseRequested(
    IDCardCloseRequested event,
    Emitter<IdCardReaderState> emit,
  ) {
    if (_channel == null) {
      return;
    }

    _channel = null;
    _channelSub = null;

    emit(const IDCardInitial());
  }

  IDCardPayload? _parseReadCard(Map data) {
    final idNumber = data['IDNumber'] as String?;
    final idTextRaw = data['IDText'] as String?;
    if (idNumber == null || idTextRaw == null) return null;

    final parts = idTextRaw
        .split('#')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final thaiParts = parts.where((p) => RegExp(r'[ก-๙]').hasMatch(p)).toList();
    const prefixes = ['นาย', 'นาง', 'นางสาว', 'น.ส.', 'ด.ช.', 'ด.ญ.'];
    final nameParts = thaiParts.where((p) => !prefixes.contains(p)).toList();
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts[1] : '';
    final engNameEndIndex = parts.indexWhere(
      (p) => RegExp(r'^[A-Za-z]+$').hasMatch(p),
      6,
    );
    final addrStart = parts.indexWhere(
      (p) => RegExp(r'^[0-9]').hasMatch(p),
      engNameEndIndex == -1 ? 0 : engNameEndIndex + 1,
    );
    int addrEnd = -1;
    if (addrStart != -1) {
      addrEnd = parts.indexWhere(
        (p) => p.startsWith('จังหวัด') || p == 'กรุงเทพมหานคร',
        addrStart,
      );
    }
    final address = addrStart == -1
        ? ''
        : (addrEnd == -1
              ? parts.sublist(addrStart).join(' ')
              : parts.sublist(addrStart, addrEnd + 1).join(' '));

    return IDCardPayload(
      idCard: idNumber,
      fullName: '$firstName $lastName'.trim(),
      firstName: firstName,
      lastName: lastName,
      rawParts: parts,
      address: address,
    );
  }

  @override
  Future<void> close() {
    _disposeChannel();
    return super.close();
  }

  void _disposeChannel() {
    _channelSub?.cancel();
    _channelSub = null;
    _channel?.sink.close();
    _channel = null;
  }
}
