import 'dart:developer';

import 'package:dio/dio.dart';

class PlacesService {
  final Dio _dio;
  PlacesService({Dio? dio}) : _dio = dio ?? Dio();

  /// ค้นหาสถานที่จาก keyword
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    try {
      final response = await _dio.get(
        '/api/v1/google-maps/place-autocomplete',
        queryParameters: {
          'input': query,
          'language': 'th',
          'components': 'country:th',
        },
      );
      log('response received - checking status code ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        log('Places API response: $data');
        if (data['status'] == 'OK' && data['predictions'] != null) {
          return List<Map<String, dynamic>>.from(data['predictions']);
        }
      }

      return [];
    } on DioException catch (e) {
      log('Error searching places: ${e.message}');
      return [];
    } catch (e) {
      log('Unexpected error: $e');
      return [];
    }
  }
}
