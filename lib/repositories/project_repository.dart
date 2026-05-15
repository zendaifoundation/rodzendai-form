import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:rodzendai_form/models/project_model.dart';

class ProjectRepository {
  ProjectRepository(Dio dio, {String? baseUrl}) : _dio = dio;
  final Dio _dio;

  Future<List<ProjectModel>> fetchProjects() async {
    try {
      log('🔍 Fetching projects...');

      final response = await _dio.get('/api/v1/projects');

      log('✅ Fetch projects response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final success = data['success'] as bool? ?? false;
        final code = data['code'] as String?;

        if (success && code == '00') {
          final list = (data['data'] as List<dynamic>?) ?? <dynamic>[];
          return list
              .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        final message = data['message'] as String? ?? 'ไม่สามารถดึงข้อมูลได้';
        throw Exception(message);
      }

      throw Exception(
        'ไม่สามารถดึงรายการ projects ได้: ${response.statusMessage}',
      );
    } on DioException catch (e) {
      log('❌ DioException in fetchProjects: ${e.message}', error: e);
      throw Exception('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์: ${e.message}');
    } catch (e) {
      log('❌ Unexpected error in fetchProjects: $e', error: e);
      rethrow;
    }
  }
}
