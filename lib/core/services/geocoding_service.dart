import 'package:dio/dio.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';

class GeocodingService {
  final Dio _dio;
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  GeocodingService({Dio? dio}) : _dio = dio ?? Dio();

  /// Reverse Geocoding: แปลงพิกัด (lat, lng) เป็นที่อยู่
  Future<Map<String, dynamic>> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'latlng': '$latitude,$longitude',
          'key': EnvHelper.googleAPIKey,
          'language': 'th', // ใช้ภาษาไทย
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == 'OK' && data['results'] != null) {
          final results = data['results'] as List;
          if (results.isNotEmpty) {
            final firstResult = results[0];
            return {
              'success': true,
              'formattedAddress': firstResult['formatted_address'],
              'addressComponents': firstResult['address_components'],
              'placeId': firstResult['place_id'],
              'latitude': latitude,
              'longitude': longitude,
            };
          }
        }

        return {
          'success': false,
          'error': 'ไม่พบที่อยู่จากพิกัดนี้',
          'status': data['status'],
        };
      }

      return {
        'success': false,
        'error': 'เกิดข้อผิดพลาดในการเรียก API (${response.statusCode})',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': 'เกิดข้อผิดพลาด: ${e.message}',
        'type': e.type.toString(),
      };
    } catch (e) {
      return {'success': false, 'error': 'เกิดข้อผิดพลาดที่ไม่คาดคิด: $e'};
    }
  }

  /// ดึงข้อมูลที่อยู่แบบละเอียด
  Future<AddressDetail?> getAddressDetail({
    required double latitude,
    required double longitude,
  }) async {
    final result = await getAddressFromCoordinates(
      latitude: latitude,
      longitude: longitude,
    );

    if (result['success'] == true) {
      return AddressDetail.fromGeocodingResult(result);
    }

    return null;
  }
}

/// Model สำหรับเก็บรายละเอียดที่อยู่
class AddressDetail {
  final String formattedAddress;
  final String? subDistrict; // ตำบล/แขวง
  final String? district; // อำเภอ/เขต
  final String? province; // จังหวัด
  final String? postalCode; // รหัสไปรษณีย์
  final String? country; // ประเทศ
  final double latitude;
  final double longitude;
  final String? placeId;

  AddressDetail({
    required this.formattedAddress,
    this.subDistrict,
    this.district,
    this.province,
    this.postalCode,
    this.country,
    required this.latitude,
    required this.longitude,
    this.placeId,
  });

  factory AddressDetail.fromGeocodingResult(Map<String, dynamic> result) {
    final addressComponents = result['addressComponents'] as List? ?? [];

    String? getComponent(List<String> types) {
      for (var component in addressComponents) {
        final componentTypes = component['types'] as List? ?? [];
        for (var type in types) {
          if (componentTypes.contains(type)) {
            return component['long_name'];
          }
        }
      }
      return null;
    }

    return AddressDetail(
      formattedAddress: result['formattedAddress'] ?? '',
      subDistrict: getComponent(['sublocality_level 2', 'sublocality']),
      district: getComponent(['locality', 'administrative_area_level_2']),
      province: getComponent(['administrative_area_level_1']),
      postalCode: getComponent(['postal_code']),
      country: getComponent(['country']),
      latitude: result['latitude'] ?? 0.0,
      longitude: result['longitude'] ?? 0.0,
      placeId: result['placeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formattedAddress': formattedAddress,
      'subDistrict': subDistrict,
      'district': district,
      'province': province,
      'postalCode': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'placeId': placeId,
    };
  }

  @override
  String toString() {
    return formattedAddress;
  }
}
