import 'dart:developer';
import 'dart:ui_web';

class EnvHelper {
  EnvHelper._();

  static String get firebaseApiKey {
    const result = String.fromEnvironment('FIREBASE_API_KEY');
    if (result.isEmpty) {
      throw AssertionError(
        'FIREBASE_API_KEY is not set. Please use --dart-define-from-file=keys.json',
      );
    }
    return result;
  }

  static String get firebaseAppId {
    const result = String.fromEnvironment('FIREBASE_APP_ID');
    if (result.isEmpty) {
      throw AssertionError(
        'FIREBASE_APP_ID is not set. Please use --dart-define-from-file=keys.json',
      );
    }
    return result;
  }

  static String get firebaseMessagingSenderId {
    const result = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    if (result.isEmpty) {
      throw AssertionError(
        'FIREBASE_MESSAGING_SENDER_ID is not set. Please use --dart-define-from-file=keys.json',
      );
    }
    return result;
  }

  static String get firebaseProjectId {
    const result = String.fromEnvironment('FIREBASE_PROJECT_ID');
    if (result.isEmpty) {
      throw AssertionError(
        'FIREBASE_PROJECT_ID is not set. Please use --dart-define-from-file=keys.json',
      );
    }
    return result;
  }

  static String get firebaseAuthDomain {
    const result = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
    if (result.isEmpty) {
      throw AssertionError(
        'FIREBASE_AUTH_DOMAIN is not set. Please use --dart-define-from-file=keys.json',
      );
    }
    return result;
  }

  static String get firebaseStorageBucket {
    const result = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
    if (result.isEmpty) {
      throw AssertionError(
        'FIREBASE_STORAGE_BUCKET is not set. Please use --dart-define-from-file=keys.json',
      );
    }
    return result;
  }

  static String get firebaseMeasurementId {
    const result = String.fromEnvironment('FIREBASE_MEASUREMENT_ID');
    if (result.isEmpty) {
      throw AssertionError(
        'FIREBASE_MEASUREMENT_ID is not set. Please use --dart-define-from-file=keys.json',
      );
    }
    return result;
  }

  static String get googleAPIKey {
    const result = String.fromEnvironment('GOOGLE_API_KEY');
    if (result.isEmpty) {
      throw AssertionError(
        'GOOGLE_API_KEY is not set. Please use --dart-define-from-file=keys.json',
      );
    }
    return result;
  }

  static String get environment {
    const result = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'sandbox',
    );
    log('environment = $result');
    if (result.isEmpty) {
      return 'sandbox';
    }
    return result;
  }

  /// ตรวจสอบว่าอยู่ใน production environment หรือไม่
  static bool get isProduction => environment.toLowerCase() == 'production';

  /// ตรวจสอบว่าอยู่ใน development/sandbox environment หรือไม่
  static bool get isDevelopment => !isProduction;

  /// สร้าง storage path ตาม environment
  /// - Development: sandbox/appointment_docs/{patientId}
  /// - Production: appointment_docs/{patientId}
  static String getStoragePath(String path) {
    if (isDevelopment) {
      return 'sandbox/$path';
    }
    return path;
  }

  static String getFirestorePath(String path) {
    if (isDevelopment) {
      return 'sandbox/$path';
    }
    return path;
  }
}
