import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:rodzendai_form/core/constants/apis.dart';
import 'package:rodzendai_form/repositories/patient_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rodzendai_form/core/services/auth_service.dart';
import 'package:rodzendai_form/repositories/firebase_repository.dart';
import 'package:rodzendai_form/repositories/firebase_storeage_repository.dart';

/// Service Locator instance
/// ใช้ GetIt.instance เพื่อเข้าถึง dependency injection container
final locator = GetIt.instance;

/// Setup service locator
/// ควรเรียกใช้ใน main() ก่อน runApp()
Future<void> setupServiceLocator() async {
  // Register SharedPreferences (ต้อง await เพื่อให้ได้ instance จริง)
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register Services
  locator.registerLazySingleton<AuthService>(() => AuthService());

  // Register Repositories
  locator.registerLazySingleton<FirebaseRepository>(() => FirebaseRepository());
  locator.registerLazySingleton<FirebaseStorageRepository>(
    () => FirebaseStorageRepository(),
  );

  // Register PatientRepository with Dio dependency
  final dio = Dio(
    BaseOptions(
      baseUrl: Apis.baseUrl,
      headers: {"Content-Type": "application/json"},
    ),
  );

  // Register PatientRepository with the Dio instance and API base URL
  locator.registerLazySingleton<PatientRepository>(
    () => PatientRepository(dio, baseUrl: Apis.baseUrl),
  );
}
