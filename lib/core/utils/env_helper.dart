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
}
