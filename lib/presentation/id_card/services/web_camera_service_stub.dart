import 'dart:typed_data';

import 'package:flutter/widgets.dart';

/// stub สำหรับ platform ที่ไม่ใช่ web
class WebCameraService {
  static bool get isSupported => false;

  bool get isStarted => false;
  Size? get videoSize => null;
  bool get supportsTakePhoto => false;
  bool get supportsTorch => false;
  bool get isBackCamera => false;

  Future<void> start() => throw UnsupportedError('WebCameraService: web only');
  Widget buildPreview() => const SizedBox.shrink();
  Future<void> setTorch(bool on) => throw UnsupportedError('web only');
  Future<({Uint8List bytes, bool isPhoto})> capture() =>
      throw UnsupportedError('web only');
  void stop() {}
}
