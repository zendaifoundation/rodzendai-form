import 'dart:async';
import 'dart:developer';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// กล้องบน web ที่คุมเองทั้งหมด (ไม่ใช้ package camera) เพื่อให้
/// - ถ่ายภาพนิ่งเต็มเซ็นเซอร์ด้วย `ImageCapture.takePhoto()` (Chrome Android)
///   แทนการดึงเฟรมวิดีโอที่จำกัด ~1080p
/// - เข้าถึง MediaStreamTrack ตรง ๆ สำหรับ torch (แฟลช)
///
/// ถ้า browser ไม่มี ImageCapture (เช่น iOS Safari) จะ fallback เป็นวาดเฟรมวิดีโอลง canvas
class WebCameraService {
  static bool get isSupported => true;

  static int _viewSeq = 0;

  web.HTMLVideoElement? _video;
  web.MediaStream? _stream;
  web.MediaStreamTrack? _track;
  JSObject? _imageCapture;
  String? _viewType;
  Size? _videoSize;
  bool _supportsTorch = false;
  bool _isBackCamera = false;

  bool get isStarted => _stream != null;
  Size? get videoSize => _videoSize;
  bool get supportsTakePhoto => _imageCapture != null;
  bool get supportsTorch => _supportsTorch;
  bool get isBackCamera => _isBackCamera;

  /// เปิดกล้องหลัง (environment) ถ้าไม่มีใช้กล้องใดก็ได้ที่มี
  Future<void> start() async {
    stop();
    final mediaDevices = web.window.navigator.mediaDevices;

    web.MediaStream stream;
    try {
      stream = await mediaDevices
          .getUserMedia(_constraints(facing: 'environment', exact: true))
          .toDart;
    } catch (e) {
      log('[WebCamera] back camera (exact) failed: $e -> fallback any camera');
      stream = await mediaDevices
          .getUserMedia(_constraints(facing: 'environment', exact: false))
          .toDart;
    }
    _stream = stream;

    final tracks = stream.getVideoTracks().toDart;
    if (tracks.isEmpty) {
      stop();
      throw StateError('NotFoundError: ไม่มี video track');
    }
    final track = tracks.first;
    _track = track;

    final settings = track.getSettings();
    final facing = settings.has('facingMode')
        ? (settings['facingMode'] as JSString?)?.toDart
        : null;
    _isBackCamera = facing == 'environment';

    // torch รองรับไหม (getCapabilities มีเฉพาะ Chrome-based)
    _supportsTorch = false;
    try {
      if ((track as JSObject).has('getCapabilities')) {
        final caps = track.callMethod<JSObject>('getCapabilities'.toJS);
        _supportsTorch =
            caps.has('torch') &&
            ((caps['torch'] as JSBoolean?)?.toDart ?? false);
      }
    } catch (e) {
      log('[WebCamera] getCapabilities failed: $e');
    }

    // ImageCapture (ภาพนิ่งเต็มเซ็นเซอร์)
    _imageCapture = null;
    try {
      if (web.window.has('ImageCapture')) {
        final ctor = web.window['ImageCapture'] as JSFunction;
        _imageCapture = ctor.callAsConstructor<JSObject>(track);
      }
    } catch (e) {
      log('[WebCamera] ImageCapture unavailable: $e');
      _imageCapture = null;
    }

    // video element สำหรับ preview
    final video = web.HTMLVideoElement()
      ..autoplay = true
      ..muted = true
      ..setAttribute('playsinline', 'true')
      ..srcObject = stream;
    video.style
      ..width = '100%'
      ..height = '100%'
      ..objectFit = 'cover'
      ..pointerEvents = 'none'
      ..backgroundColor = 'black';
    _video = video;

    // รอ metadata เพื่อให้รู้ขนาดจริงของ stream
    if (video.readyState < 1) {
      await web.EventStreamProviders.loadedMetadataEvent
          .forTarget(video)
          .first
          .timeout(const Duration(seconds: 10));
    }
    await video.play().toDart;
    _videoSize = Size(
      video.videoWidth.toDouble(),
      video.videoHeight.toDouble(),
    );

    _viewType = 'web-camera-${_viewSeq++}';
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType!,
      (int viewId) => video,
    );

    log(
      '[WebCamera] started ${_videoSize!.width.toInt()}x${_videoSize!.height.toInt()} '
      'facing=$facing takePhoto=$supportsTakePhoto torch=$_supportsTorch',
    );
  }

  web.MediaStreamConstraints _constraints({
    required String facing,
    required bool exact,
  }) {
    final video = <String, Object>{
      'facingMode': exact ? {'exact': facing} : {'ideal': facing},
      'width': {'ideal': 1920},
      'height': {'ideal': 1080},
    };
    return web.MediaStreamConstraints(video: video.jsify()!, audio: false.toJS);
  }

  Widget buildPreview() {
    final viewType = _viewType;
    if (viewType == null) return const SizedBox.shrink();
    return HtmlElementView(viewType: viewType);
  }

  Future<void> setTorch(bool on) async {
    final track = _track;
    if (track == null) throw StateError('กล้องยังไม่เปิด');
    final constraints =
        {
              'advanced': [
                {'torch': on},
              ],
            }.jsify()!
            as web.MediaTrackConstraints;
    await track.applyConstraints(constraints).toDart;
  }

  /// ถ่ายรูป: ใช้ ImageCapture.takePhoto() ถ้ามี ไม่งั้นดึงเฟรมวิดีโอ
  /// คืน bytes (JPEG) และ flag ว่าเป็นภาพนิ่งจริงหรือเฟรมวิดีโอ
  Future<({Uint8List bytes, bool isPhoto})> capture() async {
    final ic = _imageCapture;
    if (ic != null) {
      try {
        final blob = await _takePhoto(ic);
        final buf = await blob.arrayBuffer().toDart;
        return (bytes: buf.toDart.asUint8List(), isPhoto: true);
      } catch (e) {
        log('[WebCamera] takePhoto failed: $e -> fallback grabFrame');
      }
    }
    return (bytes: await _grabVideoFrame(), isPhoto: false);
  }

  Future<web.Blob> _takePhoto(JSObject ic) async {
    // ขอขนาดภาพใหญ่สุดที่กล้องให้ได้ ถ้าตั้งค่าไม่ได้ให้ถ่ายแบบ default
    try {
      final caps = await ic
          .callMethod<JSPromise<JSObject>>('getPhotoCapabilities'.toJS)
          .toDart;
      final w = caps['imageWidth'] as JSObject?;
      final h = caps['imageHeight'] as JSObject?;
      final maxW = (w?['max'] as JSNumber?)?.toDartInt;
      final maxH = (h?['max'] as JSNumber?)?.toDartInt;
      if (maxW != null && maxH != null && maxW > 0 && maxH > 0) {
        log('[WebCamera] takePhoto at ${maxW}x$maxH');
        final settings = {'imageWidth': maxW, 'imageHeight': maxH}.jsify()!;
        return await ic
            .callMethod<JSPromise<web.Blob>>('takePhoto'.toJS, settings)
            .toDart;
      }
    } catch (e) {
      log('[WebCamera] takePhoto with settings failed: $e -> default');
    }
    return await ic.callMethod<JSPromise<web.Blob>>('takePhoto'.toJS).toDart;
  }

  Future<Uint8List> _grabVideoFrame() async {
    final video = _video;
    if (video == null) throw StateError('กล้องยังไม่เปิด');
    final canvas = web.HTMLCanvasElement()
      ..width = video.videoWidth
      ..height = video.videoHeight;
    final ctx = canvas.getContext('2d') as web.CanvasRenderingContext2D;
    ctx.drawImage(video, 0, 0);
    final completer = Completer<web.Blob>();
    canvas.toBlob(
      (web.Blob? blob) {
        if (blob == null) {
          completer.completeError(StateError('canvas.toBlob คืน null'));
        } else {
          completer.complete(blob);
        }
      }.toJS,
      'image/jpeg',
      0.95.toJS,
    );
    final blob = await completer.future;
    final buf = await blob.arrayBuffer().toDart;
    return buf.toDart.asUint8List();
  }

  void stop() {
    final stream = _stream;
    if (stream != null) {
      for (final t in stream.getTracks().toDart) {
        t.stop();
      }
    }
    _video?.srcObject = null;
    _video = null;
    _stream = null;
    _track = null;
    _imageCapture = null;
    _videoSize = null;
    _supportsTorch = false;
  }
}
