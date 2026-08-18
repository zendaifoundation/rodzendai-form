// core/error/app_error.dart
class AppError {
  final String message;
  final String code;
  final int? statusCode;
  final dynamic details;
  const AppError({
    required this.message,
    required this.code,
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    return 'AppError(message: $message, code: $code, statusCode: $statusCode, details: $details)';
  }
}
