import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/image_crop_helper.dart';
import 'package:rodzendai_form/presentation/id_card/services/web_camera_service.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_file_widget.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';

/// หน้ากล้องถ่ายบัตรประชาชน มีกรอบ (อัตราส่วนบัตร 85.6 × 54 มม.) ช่วยจัดตำแหน่ง
///
/// ใช้ [WebCameraService] (getUserMedia + ImageCapture.takePhoto) เพื่อให้ได้
/// ภาพนิ่งเต็มเซ็นเซอร์บน Chrome Android ถ่ายแล้ว crop เฉพาะส่วนในกรอบ
/// แล้ว pop กลับเป็น [UploadedFile] (PNG)
class IdCardCameraPage extends StatefulWidget {
  const IdCardCameraPage({super.key});

  /// เปิดกล้อง คืน null ถ้าผู้ใช้ยกเลิก
  static Future<UploadedFile?> open(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push<UploadedFile>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const IdCardCameraPage(),
      ),
    );
  }

  @override
  State<IdCardCameraPage> createState() => _IdCardCameraPageState();
}

class _IdCardCameraPageState extends State<IdCardCameraPage>
    with WidgetsBindingObserver {
  static const double cardAspect = 85.6 / 54.0; // ≈ 1.586

  /// เผื่อขอบรอบกรอบตอน crop (สัดส่วนของกรอบ) กัน mapping คลาดเล็กน้อย
  static const double cropPadding = 0.02;

  final _camera = WebCameraService();
  String? _error;
  bool _initializing = true;
  bool _capturing = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camera.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        !_camera.isStarted &&
        !_initializing) {
      _start();
    }
  }

  Future<void> _start() async {
    if (!WebCameraService.isSupported) {
      setState(() {
        _error = 'โหมดกล้องในเว็บรองรับเฉพาะ Flutter web';
        _initializing = false;
      });
      return;
    }
    setState(() {
      _initializing = true;
      _error = null;
      _torchOn = false;
    });
    try {
      await _camera.start();
      if (!mounted) {
        _camera.stop();
        return;
      }
      setState(() => _initializing = false);
    } catch (e) {
      log('[IdCardCamera] start error: $e');
      if (!mounted) return;
      setState(() {
        _error = _describeError(e);
        _initializing = false;
      });
    }
  }

  String _describeError(Object e) {
    final msg = e.toString();
    String friendly;
    if (msg.contains('NotAllowedError') || msg.contains('PermissionDenied')) {
      friendly =
          'ไม่ได้รับอนุญาตให้ใช้กล้อง\n'
          'Chrome: แตะไอคอนแม่กุญแจ/ตั้งค่าเว็บไซต์ > สิทธิ์ > กล้อง > อนุญาต '
          'และเช็คว่าแอป Chrome มีสิทธิ์กล้องในตั้งค่า Android';
    } else if (msg.contains('NotFoundError')) {
      friendly = 'ไม่พบกล้องในอุปกรณ์นี้';
    } else if (msg.contains('NotReadableError') ||
        msg.contains('TrackStartError')) {
      friendly =
          'เปิดกล้องไม่ได้ อาจมีแอปหรือแท็บอื่นใช้กล้องอยู่ ปิดแล้วลองใหม่';
    } else if (msg.contains('OverconstrainedError')) {
      friendly = 'กล้องไม่รองรับค่าที่ขอ ลองใหม่อีกครั้ง';
    } else if (msg.contains('SecurityError') || msg.contains('secure')) {
      friendly = 'เบราว์เซอร์อนุญาตกล้องเฉพาะ HTTPS หรือ localhost';
    } else if (msg.contains('TimeoutException')) {
      friendly = 'กล้องไม่ตอบสนอง ลองใหม่อีกครั้ง';
    } else {
      friendly = 'เปิดกล้องไม่สำเร็จ';
    }
    return '$friendly\n\n[$msg]';
  }

  Future<void> _toggleTorch() async {
    try {
      await _camera.setTorch(!_torchOn);
      if (!mounted) return;
      setState(() => _torchOn = !_torchOn);
    } catch (e) {
      log('[IdCardCamera] torch failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กล้อง/เบราว์เซอร์นี้ไม่รองรับไฟแฟลช')),
      );
    }
  }

  /// กรอบบัตรในพิกัดของ viewport (widget)
  Rect _frameRect(Size viewport) {
    final width = math.min(viewport.width * 0.94, 560.0);
    final height = width / cardAspect;
    final left = (viewport.width - width) / 2;
    final top = math.max(24.0, viewport.height * 0.42 - height / 2);
    return Rect.fromLTWH(left, top, width, height);
  }

  /// วาง [content] แบบ cover ใน [viewport]: คืน scale และ offset
  ({double scale, Offset offset}) _coverTransform(Size content, Size viewport) {
    final scale = math.max(
      viewport.width / content.width,
      viewport.height / content.height,
    );
    final offset = Offset(
      (viewport.width - content.width * scale) / 2,
      (viewport.height - content.height * scale) / 2,
    );
    return (scale: scale, offset: offset);
  }

  /// แปลงกรอบจากพิกัด viewport -> พิกัด px ของภาพที่ถ่ายได้
  ///
  /// ภาพจาก takePhoto อาจมีอัตราส่วนต่างจาก video (เช่น 4:3 กับ 16:9)
  /// สมมติว่า video เป็นบริเวณกึ่งกลางของภาพนิ่ง (ครอบเต็มด้านที่สั้นกว่า)
  Rect _frameToImageRect({
    required Rect frame,
    required Size viewport,
    required Size video,
    required Size image,
  }) {
    // 1) viewport -> video px (preview แสดงแบบ cover)
    final v = _coverTransform(video, viewport);
    final inVideo = Rect.fromLTWH(
      (frame.left - v.offset.dx) / v.scale,
      (frame.top - v.offset.dy) / v.scale,
      frame.width / v.scale,
      frame.height / v.scale,
    );

    // 2) video px -> image px (video อยู่กึ่งกลางภาพ ขยายเท่าที่ใส่ในภาพได้พอดี)
    final s = math.min(image.width / video.width, image.height / video.height);
    final dx = (image.width - video.width * s) / 2;
    final dy = (image.height - video.height * s) / 2;
    final inImage = Rect.fromLTWH(
      inVideo.left * s + dx,
      inVideo.top * s + dy,
      inVideo.width * s,
      inVideo.height * s,
    );

    // 3) เผื่อขอบเล็กน้อย
    final padX = inImage.width * cropPadding;
    final padY = inImage.height * cropPadding;
    return inImage.inflate(math.max(padX, padY));
  }

  Future<void> _capture(Size viewport) async {
    final video = _camera.videoSize;
    if (!_camera.isStarted || video == null || _capturing) return;
    setState(() => _capturing = true);
    try {
      final shot = await _camera.capture();
      final imageSize = await ImageCropHelper.readSize(shot.bytes);
      final cropRect = _frameToImageRect(
        frame: _frameRect(viewport),
        viewport: viewport,
        video: video,
        image: imageSize,
      );
      log(
        '[IdCardCamera] ${shot.isPhoto ? 'photo' : 'video-frame'} '
        '${imageSize.width.toInt()}x${imageSize.height.toInt()} '
        '(video ${video.width.toInt()}x${video.height.toInt()}) '
        'crop=${cropRect.left.toInt()},${cropRect.top.toInt()} '
        '${cropRect.width.toInt()}x${cropRect.height.toInt()}',
      );

      final cropped = await ImageCropHelper.cropToPng(shot.bytes, cropRect);
      if (!mounted) return;
      Navigator.of(context).pop(
        UploadedFile(
          name: 'id_card_${DateTime.now().millisecondsSinceEpoch}.png',
          bytes: cropped,
          size: cropped.length,
          extension: 'png',
        ),
      );
    } catch (e) {
      log('[IdCardCamera] capture error: $e');
      if (!mounted) return;
      setState(() => _error = 'ถ่ายรูปไม่สำเร็จ\n\n[$e]');
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewport = Size(constraints.maxWidth, constraints.maxHeight);
            return Stack(
              fit: StackFit.expand,
              children: [
                _buildPreview(viewport),
                if (_camera.isStarted)
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _CardFramePainter(frame: _frameRect(viewport)),
                    ),
                  ),
                _buildTopBar(),
                _buildHint(viewport),
                _buildBottomBar(viewport),
                if (_initializing)
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.white),
                  ),
                if (_error != null) _buildError(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPreview(Size viewport) {
    final video = _camera.videoSize;
    if (!_camera.isStarted || video == null) return const SizedBox.expand();
    final t = _coverTransform(video, viewport);
    return ClipRect(
      child: Stack(
        children: [
          Positioned(
            left: t.offset.dx,
            top: t.offset.dy,
            width: video.width * t.scale,
            height: video.height * t.scale,
            child: _camera.buildPreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final ready = _camera.isStarted && !_initializing && !_capturing;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'ยกเลิก',
          ),
          const Spacer(),
          if (ready && !_camera.supportsTakePhoto)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Tooltip(
                message: 'เบราว์เซอร์นี้ไม่รองรับถ่ายภาพนิ่ง ได้ภาพจากวิดีโอ',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'โหมดวิดีโอ',
                    style: AppTextStyles.medium.copyWith(
                      fontSize: 12,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          if (_camera.supportsTorch)
            IconButton(
              icon: Icon(
                _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: _torchOn ? AppColors.warning : AppColors.white,
                size: 28,
              ),
              onPressed: ready ? _toggleTorch : null,
              tooltip: _torchOn ? 'ปิดแฟลช' : 'เปิดแฟลช',
            ),
        ],
      ),
    );
  }

  Widget _buildHint(Size viewport) {
    final frame = _frameRect(viewport);
    return Positioned(
      top: frame.bottom + 16,
      left: 16,
      right: 16,
      child: Text(
        'วางบัตรประชาชนให้พอดีกรอบ ถ่ายในที่สว่าง ไม่มีแสงสะท้อน',
        textAlign: TextAlign.center,
        style: AppTextStyles.medium.copyWith(
          color: AppColors.white,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildBottomBar(Size viewport) {
    final ready =
        _camera.isStarted && !_initializing && !_capturing && _error == null;
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: ready ? () => _capture(viewport) : null,
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 4),
              color: ready ? AppColors.white : AppColors.grey,
            ),
            child: _capturing
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(
                    Icons.photo_camera,
                    color: AppColors.primary,
                    size: 34,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            const Icon(
              Icons.videocam_off_outlined,
              size: 40,
              color: AppColors.error,
            ),
            SelectableText(
              _error!,
              textAlign: TextAlign.center,
              style: AppTextStyles.regular,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                ButtonCustom(text: 'ลองใหม่', onPressed: _start),
                ButtonCustom(
                  text: 'ปิด',
                  backgroundColor: AppColors.secondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// วาด mask ทึบรอบกรอบบัตร + ขอบมน + มุมกรอบ + ไกด์ตำแหน่งรูปถ่าย
class _CardFramePainter extends CustomPainter {
  const _CardFramePainter({required this.frame});
  final Rect frame;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(frame, const Radius.circular(14));

    final mask = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(mask, Paint()..color = Colors.black.withValues(alpha: 0.6));

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final corner = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const len = 28.0;
    final l = frame.left, t = frame.top, r = frame.right, b = frame.bottom;
    canvas
      ..drawLine(Offset(l, t + len), Offset(l, t + 10), corner)
      ..drawLine(Offset(l + 10, t), Offset(l + len, t), corner)
      ..drawLine(Offset(r - len, t), Offset(r - 10, t), corner)
      ..drawLine(Offset(r, t + 10), Offset(r, t + len), corner)
      ..drawLine(Offset(l, b - len), Offset(l, b - 10), corner)
      ..drawLine(Offset(l + 10, b), Offset(l + len, b), corner)
      ..drawLine(Offset(r - len, b), Offset(r - 10, b), corner)
      ..drawLine(Offset(r, b - 10), Offset(r, b - len), corner);

    // ไกด์ตำแหน่งรูปถ่ายบนบัตร (มุมขวาล่าง ตามตำแหน่งจริงบนบัตรประชาชนไทย)
    final photo = Rect.fromLTWH(
      frame.left + frame.width * 0.76,
      frame.top + frame.height * 0.47,
      frame.width * 0.21,
      frame.height * 0.46,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(photo, const Radius.circular(6)),
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _CardFramePainter old) => old.frame != frame;
}
