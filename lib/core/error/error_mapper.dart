// core/error/error_mapper.dart
import 'package:dio/dio.dart';
import 'app_error.dart';

class ErrorMapper {
  static AppError fromDio(DioException e) {
    // Handle network/connection errors
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return const AppError(
        message: 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้',
        code: 'CONNECTION_ERROR',
      );
    }

    // Handle timeout errors
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const AppError(
        message: 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง',
        code: 'TIMEOUT_ERROR',
      );
    }

    // Handle response errors (400, 500, etc.)
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final message = (data is Map && data['message'] is String)
        ? data['message'] as String
        : (e.message ?? 'เกิดข้อผิดพลาดที่ไม่คาดคิด');
    final code = (data is Map && data['code'] is String)
        ? data['code'] as String
        : 'UNKNOWN';
    return AppError(
      message: message,
      code: code,
      statusCode: status,
      details: data,
    );
  }
}
