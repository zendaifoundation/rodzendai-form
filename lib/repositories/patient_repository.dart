import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:rodzendai_form/models/check_eligibility_model.dart';
import 'package:rodzendai_form/models/check_register_patient_response_model.dart';
import 'package:rodzendai_form/models/patient_response_model.dart';

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

  Future<CheckRegisterPatientResponseModel> checkRegister({
    required String? patientIdCardNumber,
  }) async {
    try {
      log('Checking register for ID: $patientIdCardNumber');

      final response = await _dio.post(
        '/api/v1/patients/check-register',
        data: {'idCardNumber': patientIdCardNumber},
      );

      log('Register check response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final model = CheckRegisterPatientResponseModel.fromJson(response.data);
        log('Eligibility check succeeded');
        return model;
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

  Future<PatientResponseModel> getPatientByIdCardNumber({
    required String idCardNumber,
  }) async {
    try {
      log('Getting patient by ID: $idCardNumber');

      final response = await _dio.post(
        '/api/v1/patients/getPatientByIdCardNumber',
        data: {'idCardNumber': idCardNumber},
      );

      log('Get patient response: ${response.statusCode}');
      final statusCode = response.statusCode ?? 0;
      if (statusCode == 200) {
        log('Get patient succeeded');
        log('response.data: ${response.data}');
        return PatientResponseModel.fromJson(response.data);
      }
      final serverMsg = () {
        final d = response.data;
        if (d is Map && d['message'] is String) return d['message'] as String;
        return response.statusMessage ?? 'Unknown error';
      }();

      if (statusCode == 400) {
        throw Exception('bad request: $serverMsg');
      } else if (statusCode == 404) {
        throw Exception('ไม่พบข้อมูลผู้ป่วยจากเลขบัตรที่ให้มา');
      } else if (statusCode == 422) {
        throw Exception('ข้อมูลไม่ผ่านการตรวจสอบ: $serverMsg');
      } else if (statusCode >= 500) {
        throw Exception('เซิร์ฟเวอร์ขัดข้อง: $serverMsg');
      } else {
        throw Exception('ไม่สามารถดึงข้อมูลผู้ป่วยได้: $serverMsg');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('การเชื่อมต่อหมดเวลา กรุณาลองใหม่');
      }

      if (e.type == DioExceptionType.badResponse) {
        final code = e.response?.statusCode ?? 0;
        final msg =
            (e.response?.data is Map && e.response?.data['message'] is String)
            ? e.response?.data['message'] as String
            : e.message ?? 'Unknown error';
        if (code == 400) throw Exception('bad request: $msg');
        if (code == 404) throw Exception('ไม่พบข้อมูลผู้ป่วยจากเลขบัตรที่ให้มา');
        if (code == 422) throw Exception('ข้อมูลไม่ผ่านการตรวจสอบ: $msg');
        if (code >= 500) throw Exception('เซิร์ฟเวอร์ขัดข้อง: $msg');
        throw Exception('ไม่สามารถดึงข้อมูลผู้ป่วยได้: $msg');
      }

      // อื่นๆ เช่น network ผิดพลาด
      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์: ${e.message}');
    } catch (e) {
      log('Unexpected error in getPatientByIdCardNumber: $e', error: e);
      throw Exception('ไม่สามารถดึงข้อมูลผู้ป่วยได้: ${e.toString()}');
    }
  }
}
