import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:rodzendai_form/models/create_appointment_response_model.dart';

class AppointmentRepository {
  AppointmentRepository(Dio dio, {String? baseUrl}) : _dio = dio;
  final Dio _dio;

  Future<CreateAppointmentResponseModel> createAppointment({
    required String? patientIdCardNumber,
    required FormData formdata,
  }) async {
    try {
      log('create appointment for ID: $patientIdCardNumber');

      final response = await _dio.post(
        '/api/v1/appointments/create',
        data: formdata,
      );

      log('Appointment create response: ${response.statusCode}');

      if (response.statusCode == 200) {
        log('create appointment successfully');
        log('response.data : ${response.data}');
        return CreateAppointmentResponseModel.fromJson(response.data);
      } else {
        final errorMessage = response.statusMessage ?? 'Unknown error';
        log('Appointment create failed: $errorMessage');
        throw Exception('ไม่สามารถดึงข้อมูลได้: $errorMessage');
      }
    } on DioException catch (e) {
      log('DioException in createAppointment: ${e.message}', error: e);
      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์: ${e.message}');
    } catch (e) {
      log('Unexpected error in createAppointment: $e', error: e);
      throw Exception('ไม่สามารถดึงข้อมูลได้: ${e.toString()}');
    }
  }
}
