import 'dart:async';

/// ข้อมูลที่ normalize แล้วจาก agent ทุกตัว
/// ทุก agent ต้องแปลง response ของตัวเองให้กลายเป็น AgentCardData นี้
class AgentCardData {
  const AgentCardData({
    required this.idCard,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.address,
    /// รูปแบบ: "YYYYMMDD" พ.ศ. เพื่อให้ตรงกับที่ downstream ใช้อยู่
    /// ตัวอย่าง: "25401224"
    required this.bridthDate,
    required this.rawParts,
  });

  final String? idCard;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? address;
  final String? bridthDate;
  final List<String?> rawParts;
}

/// Abstract interface ที่ agent ทุกตัวต้อง implement
/// ทำให้ BLoC ไม่รู้จัก agent โดยตรง — สามารถ swap ได้โดยไม่ต้องแก้ BLoC
abstract class IdCardAgent {
  /// Stream ที่ปล่อย AgentCardData เมื่ออ่านบัตรสำเร็จ
  Stream<AgentCardData> get cardStream;

  /// Stream ที่ปล่อย error message เมื่อเกิดข้อผิดพลาด
  Stream<String> get errorStream;

  /// ชื่อ agent สำหรับ log และ debug
  String get name;

  /// เชื่อมต่อ WebSocket — return true ถ้าสำเร็จ, false ถ้าไม่ได้
  Future<bool> connect();

  /// ส่งคำสั่งอ่านบัตร
  void sendReadCard();

  /// ปิด connection และ clean up resource
  void dispose();
}
