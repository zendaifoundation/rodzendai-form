part of 'id_card_reader_bloc.dart';

sealed class IdCardReaderEvent extends Equatable {
  const IdCardReaderEvent();

  @override
  List<Object?> get props => [];
}

/// ขอให้ BLoC เริ่ม auto-detect และ connect agent
class IDCardConnectRequested extends IdCardReaderEvent {
  const IDCardConnectRequested();
}

/// ขอให้ส่งคำสั่งอ่านบัตร (ใช้หลัง connect สำเร็จแล้ว)
class IDCardReadRequested extends IdCardReaderEvent {
  const IDCardReadRequested();
}

/// ขอให้ reset กลับสู่ initial และปิด connection
class IDCardResetRequested extends IdCardReaderEvent {
  const IDCardResetRequested();
}

/// ขอให้ปิด connection (ใช้ตอนออกจากหน้า)
class IDCardCloseRequested extends IdCardReaderEvent {
  const IDCardCloseRequested();
}

/// internal — agent อ่านบัตรสำเร็จ ส่งข้อมูลกลับมา
class _IDCardDataReceived extends IdCardReaderEvent {
  const _IDCardDataReceived(this.data);
  final AgentCardData data;
  @override
  List<Object?> get props => [data];
}

/// internal — agent แจ้ง error
class _IDCardErrorReceived extends IdCardReaderEvent {
  const _IDCardErrorReceived(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
