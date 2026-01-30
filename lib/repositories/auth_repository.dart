import 'dart:developer';

import 'package:dio/dio.dart';

/// Repository สำหรับจัดการ Authentication
class AuthRepository {
  AuthRepository(Dio dio, {String? baseUrl}) : _dio = dio;
  final Dio _dio;

  /// ตรวจสอบ temp token ที่ได้จาก web-admin
  ///
  /// Parameters:
  /// - [tempToken]: Token ชั่วคราวที่ได้รับจาก web-admin
  ///
  /// Returns:
  /// - Map<String, dynamic> ข้อมูล user ถ้า token ถูกต้อง
  ///
  /// Throws:
  /// - Exception ถ้า token ไม่ถูกต้องหรือหมดอายุ
  Future<Map<String, dynamic>> verifyTempToken({
    required String tempToken,
  }) async {
    try {
      log('🔍 Verifying temp token...');

      final response = await _dio.post(
        '/api/v1/auth/verify-temp-token',
        options: Options(headers: {'Authorization': 'Bearer $tempToken'}),
      );

      log('✅ Verify token response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        final success = data['success'] as bool? ?? false;
        final code = data['code'] as String?;

        if (success && code == '00') {
          final dataObj = data['data'] as Map<String, dynamic>?;
          if (dataObj != null && dataObj['user'] != null) {
            final user = dataObj['user'] as Map<String, dynamic>;
            log('✅ Token verified successfully for user: ${user['name']}');
            return user;
          } else {
            throw Exception('ไม่พบข้อมูลผู้ใช้');
          }
        } else {
          final message = data['message'] as String? ?? 'Token ไม่ถูกต้อง';
          throw Exception(message);
        }
      } else {
        final errorMessage = response.statusMessage ?? 'Unknown error';
        log('❌ Token verification failed: $errorMessage');
        throw Exception('ไม่สามารถตรวจสอบ token ได้: $errorMessage');
      }
    } on DioException catch (e) {
      log('❌ DioException in verifyTempToken: ${e.message}', error: e);

      if (e.response?.statusCode == 401) {
        throw Exception('Token ไม่ถูกต้องหรือหมดอายุ');
      } else if (e.response?.statusCode == 400) {
        throw Exception('ข้อมูล token ไม่ถูกต้อง');
      }

      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์: ${e.message}');
    } catch (e) {
      log('❌ Unexpected error in verifyTempToken: $e', error: e);
      throw Exception('ไม่สามารถตรวจสอบ token ได้: ${e.toString()}');
    }
  }

  /// แลกเปลี่ยน temp token เป็น access token จริง (ถ้าต้องการ)
  ///
  /// Parameters:
  /// - [tempToken]: Token ชั่วคราวที่ได้รับจาก web-admin
  ///
  /// Returns:
  /// - String access token ที่ใช้ในการเรียก API อื่นๆ
  Future<String> exchangeTempToken({required String tempToken}) async {
    try {
      log('🔄 Exchanging temp token for access token...');

      final response = await _dio.post(
        '/api/v1/auth/exchange-token',
        data: {'tempToken': tempToken},
      );

      log('✅ Exchange token response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final accessToken = data['accessToken'] as String?;

        if (accessToken != null && accessToken.isNotEmpty) {
          log('✅ Access token obtained successfully');
          return accessToken;
        } else {
          throw Exception('ไม่ได้รับ access token');
        }
      } else {
        final errorMessage = response.statusMessage ?? 'Unknown error';
        log('❌ Token exchange failed: $errorMessage');
        throw Exception('ไม่สามารถแลกเปลี่ยน token ได้: $errorMessage');
      }
    } on DioException catch (e) {
      log('❌ DioException in exchangeTempToken: ${e.message}', error: e);

      if (e.response?.statusCode == 401) {
        throw Exception('Token หมดอายุหรือไม่ถูกต้อง');
      }

      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์: ${e.message}');
    } catch (e) {
      log('❌ Unexpected error in exchangeTempToken: $e', error: e);
      throw Exception('ไม่สามารถแลกเปลี่ยน token ได้: ${e.toString()}');
    }
  }
}
