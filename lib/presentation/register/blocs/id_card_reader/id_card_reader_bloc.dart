import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'agents/id_card_agent.dart';
import 'agents/idw_agent.dart';
import 'agents/zendai_agent.dart';

part 'id_card_reader_event.dart';
part 'id_card_reader_state.dart';

/// BLoC สำหรับจัดการการอ่านบัตรประชาชน
///
/// รองรับ 2 agent:
///   - IDWAgent  (ws://localhost:14820) — agent สำเร็จรูป, protocol มี GetReaderList
///   - ZendaiAgent (ws://localhost:15820) — agent ที่เขียนเอง, ส่ง read_card ได้เลย
///
/// Auto-detect: ลอง IDWAgent ก่อน ถ้าไม่ได้ภายใน 2 วิ ลอง ZendaiAgent
/// ถ้าไม่ได้ทั้งคู่ → IDCardFailure
class IdCardReaderBloc extends Bloc<IdCardReaderEvent, IdCardReaderState> {
  IdCardReaderBloc() : super(IDCardInitial()) {
    on<IDCardConnectRequested>(_onConnectRequested);
    on<IDCardReadRequested>(_onReadRequested);
    on<_IDCardDataReceived>(_onDataReceived);
    on<_IDCardErrorReceived>(_onErrorReceived);
    on<IDCardResetRequested>(_onResetRequested);
    on<IDCardCloseRequested>(_onIDCardCloseRequested);
  }

  IdCardAgent? _agent;
  StreamSubscription? _cardSub;
  StreamSubscription? _errorSub;

  /// สร้าง candidates ใหม่ทุกครั้งที่ connect
  /// เพราะ agent ที่ dispose แล้วไม่สามารถใช้ซ้ำได้
  List<IdCardAgent> _buildCandidates() => [IDWAgent(), ZendaiAgent()];

  Future<void> _onConnectRequested(
    IDCardConnectRequested event,
    Emitter<IdCardReaderState> emit,
  ) async {
    if (_agent != null) return; // connect อยู่แล้ว ไม่ต้องทำซ้ำ
    emit(const IDCardConnecting());

    // สร้าง candidates ใหม่ทุกครั้ง — ป้องกันปัญหา _disposed จากรอบก่อน
    final candidates = _buildCandidates();

    for (final candidate in candidates) {
      log('[IdCardReaderBloc] trying ${candidate.name}...');
      final connected = await candidate.connect();

      if (connected) {
        _agent = candidate;
        _subscribeToAgent(candidate);

        // dispose candidates ที่ไม่ได้ใช้
        for (final other in candidates) {
          if (other != candidate) other.dispose();
        }

        log('[IdCardReaderBloc] connected via ${candidate.name}');
        emit(IDCardConnected(agentName: candidate.name));
        return;
      }

      log('[IdCardReaderBloc] ${candidate.name} failed, trying next...');
      candidate.dispose();
    }

    emit(const IDCardFailure('ไม่พบเครื่องอ่านบัตร\nกรุณาตรวจสอบว่าเปิดโปรแกรมอ่านบัตรแล้ว'));
  }

  void _onReadRequested(
    IDCardReadRequested event,
    Emitter<IdCardReaderState> emit,
  ) {
    if (_agent == null) return;
    emit(const IDCardReading());
    _agent!.sendReadCard();
  }

  void _onDataReceived(
    _IDCardDataReceived event,
    Emitter<IdCardReaderState> emit,
  ) {
    // แปลง AgentCardData → IDCardPayload ที่ downstream ใช้อยู่
    final payload = IDCardPayload(
      idCard: event.data.idCard,
      fullName: event.data.fullName,
      firstName: event.data.firstName,
      lastName: event.data.lastName,
      address: event.data.address,
      bridthDate: event.data.bridthDate,
      rawParts: event.data.rawParts,
    );
    log('[IdCardReaderBloc] card read success: $payload');
    emit(IDCardReadSuccess(payload));
  }

  void _onErrorReceived(
    _IDCardErrorReceived event,
    Emitter<IdCardReaderState> emit,
  ) {
    log('[IdCardReaderBloc] error: ${event.message}');

    // "Connection closed" จาก onDone — server เปิดตลอด แสดงว่าฝั่ง client ปิดเอง
    // ไม่ต้อง emit failure หรือ dispose เพราะยังสามารถส่ง read_card ได้อีก
    if (event.message == 'Connection closed') return;

    emit(IDCardFailure(event.message));
    _disposeAgent();
  }

  void _onResetRequested(
    IDCardResetRequested event,
    Emitter<IdCardReaderState> emit,
  ) {
    _disposeAgent();
    emit(const IDCardInitial());
  }

  void _onIDCardCloseRequested(
    IDCardCloseRequested event,
    Emitter<IdCardReaderState> emit,
  ) {
    _disposeAgent();
    emit(const IDCardInitial());
  }

  /// subscribe รับ card data และ error จาก agent ที่เลือก
  void _subscribeToAgent(IdCardAgent agent) {
    _cardSub = agent.cardStream.listen((data) {
      add(_IDCardDataReceived(data));
    });
    _errorSub = agent.errorStream.listen((message) {
      add(_IDCardErrorReceived(message));
    });
  }

  void _disposeAgent() {
    _cardSub?.cancel();
    _errorSub?.cancel();
    _cardSub = null;
    _errorSub = null;
    _agent?.dispose();
    _agent = null;
  }

  @override
  Future<void> close() {
    _disposeAgent();
    return super.close();
  }
}
