import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:rodzendai_form/core/error/app_error.dart';
import 'package:rodzendai_form/core/network/api_result.dart';
import 'package:rodzendai_form/core/network/interceptors.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/core/utils/mime_helper.dart';
import 'package:rodzendai_form/models/id_card_ocr_result_model.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_file_widget.dart';

/// OCR engine ที่ zendai-ocr รองรับ (`?provider=`) null = ค่า default ของ server
enum OcrProvider {
  easyocr('easyocr', 'EasyOCR (self-host)'),
  google('google', 'Google Vision');

  const OcrProvider(this.value, this.label);
  final String value;
  final String label;
}

/// เรียก zendai-ocr service (repo `zendai-ocr`, Node + Express)
///
///   POST {OCR_URL}/api/ocr/thai-id        multipart/form-data
///   header  x-api-key: {OCR_KEY}
///   field   image = รูปบัตร (jpg/png/webp/heic เท่านั้น ไม่รับ PDF)
///   query   provider = easyocr | google   (ไม่ส่ง = ค่าใน .env ของ server)
///
/// ตั้งค่าผ่าน dart-define `OCR_URL`, `OCR_KEY` (ดู .env.example)
class OcrRepository {
  OcrRepository({Dio? dio}) : _dio = dio ?? _buildDio();

  final Dio _dio;

  static const String thaiIdPath = '/api/ocr/thai-id';
  static const Set<String> supportedExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  static String get endpointUrl =>
      '${EnvHelper.ocrUrl ?? '(OCR_URL ไม่ได้ตั้ง)'}$thaiIdPath';

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvHelper.ocrUrl ?? '',
        headers: {
          if (EnvHelper.ocrApiKey != null) 'x-api-key': EnvHelper.ocrApiKey,
        },
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 90),
      ),
    );
    dio.interceptors.add(LoggerInterceptor());
    return dio;
  }

  Future<ApiResult<IdCardOcrResultModel>> readThaiIdCard({
    required UploadedFile file,
    OcrProvider? provider,
  }) async {
    if (!EnvHelper.isOcrConfigured) {
      return ApiResult.failure(
        const AppError(
          message: 'ยังไม่ได้ตั้งค่า OCR_URL / OCR_KEY ใน .env',
          code: 'OCR_NOT_CONFIGURED',
        ),
      );
    }
    final ext = file.extension.toLowerCase();
    if (!supportedExtensions.contains(ext)) {
      return ApiResult.failure(
        AppError(
          message: 'OCR รองรับเฉพาะไฟล์รูปภาพ (JPG, PNG, WEBP) ไม่รองรับ .$ext',
          code: 'UNSUPPORTED_FILE',
        ),
      );
    }

    try {
      final mime =
          MimeHelper.getMimeType(ext) ?? (ext == 'webp' ? 'image/webp' : null);
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          file.bytes,
          filename: file.name,
          contentType: mime == null ? null : MediaType.parse(mime),
        ),
      });

      log(
        '[OcrRepository] POST $thaiIdPath provider=${provider?.value} (${file.name}, ${file.size} bytes)',
      );
      final response = await _dio.post(
        thaiIdPath,
        data: formData,
        queryParameters: {if (provider != null) 'provider': provider.value},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final model = IdCardOcrResultModel.fromJson(data);
        if (!model.ok) {
          return ApiResult.failure(
            AppError(
              message: data['error']?.toString() ?? 'OCR ไม่สำเร็จ',
              code: 'OCR_FAILED',
              statusCode: response.statusCode,
              details: data,
            ),
          );
        }
        return ApiResult.success(model);
      }
      return ApiResult.failure(
        AppError(
          message: 'รูปแบบ response ไม่ถูกต้อง',
          code: 'BAD_RESPONSE',
          statusCode: response.statusCode,
          details: data,
        ),
      );
    } on DioException catch (e) {
      log('[OcrRepository] DioException: ${e.type} ${e.message}', error: e);
      return ApiResult.failure(_mapDioError(e));
    } catch (e) {
      log('[OcrRepository] Unexpected error: $e', error: e);
      return ApiResult.failure(
        AppError(
          message: 'เกิดข้อผิดพลาดที่ไม่คาดคิด',
          code: 'UNEXPECTED',
          details: e.toString(),
        ),
      );
    }
  }

  /// zendai-ocr ตอบ error เป็น `{ ok: false, error: "..." }`
  /// และถ้า browser โดน CORS block Dio จะได้ connectionError โดยไม่มี response
  static AppError _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map && data['error'] is String) {
      return AppError(
        message: data['error'] as String,
        code: status == 401 ? 'UNAUTHORIZED' : 'OCR_ERROR',
        statusCode: status,
        details: data,
      );
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const AppError(
        message: 'OCR ใช้เวลานานเกินกำหนด กรุณาลองใหม่',
        code: 'TIMEOUT_ERROR',
      );
    }
    if (e.response == null) {
      return AppError(
        message:
            'เชื่อมต่อ OCR service ไม่ได้ — ถ้ารันบน browser ให้เช็คว่า server ส่ง CORS header '
            '(Access-Control-Allow-Origin) หรือยัง',
        code: 'CONNECTION_ERROR',
        details: e.message,
      );
    }
    return AppError(
      message: e.message ?? 'เกิดข้อผิดพลาดจาก OCR service',
      code: 'OCR_ERROR',
      statusCode: status,
      details: data,
    );
  }
}
