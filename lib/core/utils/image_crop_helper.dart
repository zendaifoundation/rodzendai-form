import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// crop รูปด้วย dart:ui (ใช้ได้ทั้ง web และ native ไม่ต้องพึ่ง package เพิ่ม)
class ImageCropHelper {
  ImageCropHelper._();

  /// คืนขนาดรูป (px) จาก bytes
  static Future<Size> readSize(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final size = Size(
      frame.image.width.toDouble(),
      frame.image.height.toDouble(),
    );
    frame.image.dispose();
    codec.dispose();
    return size;
  }

  /// crop [bytes] ตาม [rect] (พิกัด px ของรูปต้นฉบับ) แล้ว encode เป็น PNG
  static Future<Uint8List> cropToPng(Uint8List bytes, Rect rect) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    try {
      final bounds = Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      );
      final src = rect.intersect(bounds);
      if (src.isEmpty) {
        throw StateError('crop rect อยู่นอกรูป: $rect / $bounds');
      }
      final outW = src.width.round();
      final outH = src.height.round();

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawImageRect(
        image,
        src,
        Rect.fromLTWH(0, 0, outW.toDouble(), outH.toDouble()),
        Paint()..filterQuality = FilterQuality.high,
      );
      final picture = recorder.endRecording();
      final out = await picture.toImage(outW, outH);
      picture.dispose();
      try {
        final data = await out.toByteData(format: ui.ImageByteFormat.png);
        if (data == null) throw StateError('encode PNG ไม่สำเร็จ');
        return data.buffer.asUint8List();
      } finally {
        out.dispose();
      }
    } finally {
      image.dispose();
      codec.dispose();
    }
  }
}
