import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'id_card_agent.dart';

/// Agent สำหรับ IDWAgent ที่ port 14820
/// เป็น agent สำเร็จรูปที่มี protocol GetReaderList → SelectReader → ReadIDCard
/// Response format: {"Message": "ReadIDCardR", "Status": 0, "IDNumber": "...", "IDText": "..."}
class IDWAgent implements IdCardAgent {
  static const _uri = 'ws://localhost:14820/IDWAgent';

  /// timeout สำหรับ connect — ถ้าเกิน 2 วินาทียังไม่ได้ ถือว่า agent ไม่ได้รัน
  static const _connectTimeout = Duration(seconds: 2);

  final _cardController = StreamController<AgentCardData>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  bool _disposed = false;

  @override
  String get name => 'IDWAgent';

  @override
  Stream<AgentCardData> get cardStream => _cardController.stream;

  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  Future<bool> connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_uri));

      // WebSocketChannel.connect() ไม่ throw ทันที — ต้อง await ready หรือใช้ timeout
      // รอให้ connection พร้อม หรือหมดเวลา
      await _channel!.ready.timeout(_connectTimeout);

      // subscribe รับ message
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

      log('[$name] connected to $_uri');

      // IDWAgent ต้องขอ reader list ก่อนเสมอ
      _sendJson({'Command': 'GetReaderList'});
      return true;
    } catch (e) {
      log('[$name] connect failed: $e');
      _channel = null;
      return false;
    }
  }

  /// IDWAgent ใช้คำสั่ง ReadIDCard พร้อม option
  @override
  void sendReadCard() {
    _sendJson({
      'Command': 'ReadIDCard',
      'IDNumberRead': true,
      'IDTextRead': true,
      'IDPhotoRead': false,
      'IDATextRead': true,
    });
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

  /// reconnect เมื่อ connection หลุด แล้วขอ GetReaderList ใหม่
  Future<void> _reconnect() async {
    _sub?.cancel();
    _channel?.sink.close();
    _channel = null;
    _sub = null;

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
      _sendJson({'Command': 'GetReaderList'});
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
    if (_disposed) return;
    final decoded = (raw is String ? jsonDecode(raw) : raw) as Map<String, dynamic>;

    final message = decoded['Message'] as String?;
    final status = decoded['Status'];

    log('[$name] received: message=$message status=$status');

    if (message == 'GetReaderListR') {
      final readers = (decoded['ReaderList'] as List?)?.cast<String>() ?? [];
      if (readers.isEmpty) {
        _errorController.add('ไม่พบเครื่องอ่านบัตร');
        return;
      }
      // เลือก reader ตัวแรกอัตโนมัติ
      _sendJson({'Command': 'SelectReader', 'ReaderName': readers.first});
      return;
    }

    if (message == 'SelectReaderR') {
      log('[$name] reader selected: ${decoded['ReaderName']}');
      // ready แล้ว — BLoC จะ call sendReadCard() เอง
      return;
    }

    if (message == 'ReadIDCardR') {
      if (status != 0) {
        _errorController.add('อ่านบัตรไม่สำเร็จ, code: $status');
        return;
      }
      final data = _parse(decoded);
      if (data == null) {
        _errorController.add('อ่านบัตรไม่สำเร็จ');
        return;
      }
      _cardController.add(data);
    }
  }

  /// แปลง IDWAgent response เป็น AgentCardData
  /// IDText เป็น string ที่คั่นด้วย '#' ต้องแยก parse เอง
  /// bridthDate จาก IDWAgent เป็น "YYYYMMDD" พ.ศ. อยู่แล้ว ไม่ต้องแปลง
  AgentCardData? _parse(Map<String, dynamic> data) {
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

    // IDWAgent ให้ bridthDate เป็น "YYYYMMDD" พ.ศ. เช่น "25401224"
    final bridthDate = parts.firstWhereOrNull(
      (p) => RegExp(r'^[0-9]{8}$').hasMatch(p),
    );

    return AgentCardData(
      idCard: idNumber,
      firstName: firstName,
      lastName: lastName,
      fullName: '$firstName $lastName'.trim(),
      address: address,
      bridthDate: bridthDate,
      rawParts: parts,
    );
  }
}
