import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'id_card_agent.dart';

/// Agent สำหรับ ZendaiAgent ที่ port 15820
/// เป็น agent ที่เขียนเอง — protocol เรียบง่ายกว่า IDWAgent
/// ส่ง {"command": "read_card"} แล้วรอ response เดียวเลย ไม่มี GetReaderList
///
/// Response สำเร็จ:
/// {
///   "event": "card_data",
///   "data": {
///     "cid": "...", "firstnameTH": "...", "lastnameTH": "...",
///     "fullName": "...", "bridthDate": "24/12/1997", "address": "...", ...
///   }
/// }
///
/// Response error:
/// {"event": "error"}
class ZendaiAgent implements IdCardAgent {
  static const _uri = 'ws://localhost:15820/ZendaiAgent';
  static const _connectTimeout = Duration(seconds: 2);

  final _cardController = StreamController<AgentCardData>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  bool _disposed = false;

  @override
  String get name => 'ZendaiAgent';

  @override
  Stream<AgentCardData> get cardStream => _cardController.stream;

  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  Future<bool> connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_uri));

      await _channel!.ready.timeout(_connectTimeout);

      _sub = _channel!.stream.listen(
        _onMessage,
        onError: (Object err) {
          log('[$name] socket error: $err');
          if (!_disposed) _errorController.add(err.toString());
        },
        onDone: () {
          // server เปิดตลอด — ถ้า onDone ยิงแสดงว่า connection หลุดกะทันหัน
          // reconnect อัตโนมัติเพื่อให้พร้อมอ่านครั้งถัดไป
          log('[$name] connection closed unexpectedly, reconnecting...');
          if (!_disposed) _reconnect();
        },
      );

      log('[$name] connected to $_uri');

      // ZendaiAgent พร้อมรับคำสั่งได้เลยหลัง connect ไม่ต้อง GetReaderList
      return true;
    } catch (e) {
      log('[$name] connect failed: $e');
      _channel = null;
      return false;
    }
  }

  /// ZendaiAgent ใช้คำสั่ง read_card ตรงๆ ไม่มี option เพิ่มเติม
  @override
  void sendReadCard() {
    _sendJson({'command': 'read_card'});
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _sub?.cancel();
    _channel?.sink.close();
    _channel = null;
    _cardController.close();
    _errorController.close();
  }

  /// reconnect เมื่อ connection หลุด — ไม่ emit error เพราะ BLoC ไม่รู้เรื่อง
  /// พอ reconnect สำเร็จก็พร้อมรับ read_card ได้ทันที
  Future<void> _reconnect() async {
    _sub?.cancel();
    _channel?.sink.close();
    _channel = null;
    _sub = null;

    // รอสักครู่ก่อน retry
    await Future.delayed(const Duration(milliseconds: 500));
    if (_disposed) return;

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_uri));
      await _channel!.ready.timeout(_connectTimeout);

      _sub = _channel!.stream.listen(
        _onMessage,
        onError: (Object err) {
          log('[$name] socket error: $err');
          if (!_disposed) _errorController.add(err.toString());
        },
        onDone: () {
          log('[$name] connection closed unexpectedly, reconnecting...');
          if (!_disposed) _reconnect();
        },
      );
      log('[$name] reconnected');
    } catch (e) {
      log('[$name] reconnect failed: $e');
      if (!_disposed) _errorController.add('ขาดการเชื่อมต่อกับเครื่องอ่านบัตร');
    }
  }

  void _sendJson(Map<String, dynamic> payload) {
    log('[$name] send: $payload');
    _channel?.sink.add(jsonEncode(payload));
  }

  void _onMessage(dynamic raw) {
    // ป้องกัน message มาหลัง dispose() ถูกเรียกแล้ว
    if (_disposed) return;

    final decoded =
        (raw is String ? jsonDecode(raw) : raw) as Map<String, dynamic>;

    final event = decoded['event'] as String?;
    log('[$name] received event: $event');

    if (event == 'error') {
      _errorController.add('อ่านบัตรไม่สำเร็จ');
      return;
    }

    if (event == 'card_data') {
      final data = decoded['data'] as Map<String, dynamic>?;
      if (data == null) {
        _errorController.add('อ่านบัตรไม่สำเร็จ');
        return;
      }
      final cardData = _normalize(data);
      if (cardData == null) {
        _errorController.add('อ่านบัตรไม่สำเร็จ');
        return;
      }
      _cardController.add(cardData);
    }
    // event อื่นที่ไม่รู้จัก (เช่น "status") — ignore
  }

  /// แปลง ZendaiAgent response เป็น AgentCardData
  ///
  /// bridthDate จาก ZendaiAgent เป็น "dd/MM/yyyy" ค.ศ. เช่น "24/12/1997"
  /// ต้องแปลงเป็น "YYYYMMDD" พ.ศ. เช่น "25401224" ให้ตรงกับ IDWAgent
  /// เพราะ downstream (register_to_claim_your_rights_provider.dart:831)
  /// ทำ substring(0,4) แล้วลบ 543 อยู่แล้ว
  AgentCardData? _normalize(Map<String, dynamic> data) {
    final cid = data['cid'] as String?;
    final firstnameTH = data['firstnameTH'] as String?;
    final lastnameTH = data['lastnameTH'] as String?;
    final fullName = data['fullName'] as String?;
    final address = data['address'] as String?;
    final bridthDateRaw = data['bridthDate'] as String?; // "24/12/1997"

    // แปลง "dd/MM/yyyy" ค.ศ. → "YYYYMMdd" พ.ศ.
    final bridthDate = _convertBridthDate(bridthDateRaw);

    return AgentCardData(
      idCard: cid,
      firstName: firstnameTH,
      lastName: lastnameTH,
      fullName: fullName,
      address: address,
      bridthDate: bridthDate,
      // ZendaiAgent แยก field ให้หมดแล้ว rawParts ไม่มีประโยชน์
      // ใส่ข้อมูลสำคัญไว้เผื่อ downstream ที่ใช้ rawParts
      rawParts: [cid, firstnameTH, lastnameTH, address],
    );
  }

  /// แปลงวันเกิด "dd/MM/yyyy" ค.ศ. → "YYYYMMdd" พ.ศ.
  /// เช่น "24/12/1997" → "25401224"
  String? _convertBridthDate(String? raw) {
    if (raw == null) return null;
    final parts = raw.split('/');
    if (parts.length != 3) return null;

    final dd = parts[0].padLeft(2, '0');
    final mm = parts[1].padLeft(2, '0');
    final yearCE = int.tryParse(parts[2]);
    if (yearCE == null) return null;

    final yearBE = yearCE + 543; // ค.ศ. → พ.ศ.
    return '$yearBE$mm$dd'; // "25401224"
  }
}
