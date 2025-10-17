import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:rodzendai_form/models/check_eligibility_model.dart';

class PatientRepository {
  PatientRepository(Dio dio, {String? baseUrl}) : _dio = dio;
  final Dio _dio;

  Future<CheckEligibilityModel> checkEligibility({
    required String? patientIdCardNumber,
  }) async {
    try {
      log('Checking eligibility for ID: $patientIdCardNumber');

      final response = await _dio.post(
        '/api/v1/patients/check-eligibility',
        data: {'idCardNumber': patientIdCardNumber},
      );

      log('Eligibility check response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final checkEligibilityModel = CheckEligibilityModel.fromJson(
          response.data,
        );
        log('Eligibility check succeeded');
        return checkEligibilityModel;
      } else {
        final errorMessage = response.statusMessage ?? 'Unknown error';
        log('Eligibility check failed: $errorMessage');
        throw Exception('ไม่สามารถดึงข้อมูลได้: $errorMessage');
      }
    } on DioException catch (e) {
      log('DioException in checkEligibility: ${e.message}', error: e);
      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์: ${e.message}');
    } catch (e) {
      log('Unexpected error in checkEligibility: $e', error: e);
      throw Exception('ไม่สามารถดึงข้อมูลได้: ${e.toString()}');
    }
  }

  Future<dynamic> createPatient({required FormData fomdata}) async {
    try {
      log('Creating patient');

      final response = await _dio.post('/api/v1/patients', data: fomdata);

      log('Create patient response: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('Create patient succeeded');
        log('response.data: ${response.data}');
        return response.data;
      } else {
        final errorMessage = response.statusMessage ?? 'Unknown error';
        log('Create patient failed: $errorMessage');
        throw Exception('ไม่สามารถสร้างข้อมูลผู้ป่วยได้: $errorMessage');
      }
    } on DioException catch (e) {
      log('DioException in createPatient: ${e.message}', error: e);
      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์: ${e.message}');
    } catch (e) {
      log('Unexpected error in createPatient: $e', error: e);
      throw Exception('ไม่สามารถสร้างข้อมูลผู้ป่วยได้: ${e.toString()}');
    }
  }
}
