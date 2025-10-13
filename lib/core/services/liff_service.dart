import 'dart:developer';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';

/// Helper function to get liff from window object
@JS('liff')
external JSAny? get _liffGlobal;

/// LIFF Service for LINE Login integration
class LiffService {
  // Toggle mock LIFF helpers via --dart-define=DEV_MODE=true
  static const bool _isDevelopment =
      bool.fromEnvironment('DEV_MODE', defaultValue: false);
  static const String _liffId = String.fromEnvironment(
    'LIFF_ID',
    defaultValue: 'YOUR_LIFF_ID_HERE',
  );

  static bool _isInitialized = false;
  static LiffProfile? _profile;
  static LiffProfile? _mockProfile;

  static bool get _isMockMode =>
      _isDevelopment || _liffId.isEmpty || _liffId == 'YOUR_LIFF_ID_HERE';

  /// Returns true when LIFF runs in mocked/development mode.
  static bool get isMockMode => _isMockMode;

  static LiffProfile _ensureMockProfile() {
    _mockProfile ??= LiffProfile(
      userId: 'LIFF_DEV_USER',
      displayName: 'LIFF Development User',
      pictureUrl:
          'https://dummyimage.com/200x200/009688/ffffff.png&text=LINE+DEV',
      statusMessage: 'Mock profile (DEV_MODE)',
    );
    return _mockProfile!;
  }

  /// Initialize LIFF
  static Future<bool> init() async {
    if (_isInitialized) return true;

    if (_isMockMode) {
      _isInitialized = true;
      _profile ??= _ensureMockProfile();
      log(
        'LIFF initialized in mock mode (DEV_MODE=${_isDevelopment}, LIFF_ID="$_liffId")',
      );
      return true;
    }

    try {
      if (!kIsWeb) {
        log('LIFF is only available on web platform');
        return false;
      }

      // Check if liff is available
      if (!_isLiffAvailable()) {
        log('LIFF SDK is not loaded');
        return false;
      }

      // Initialize LIFF
      await _liffInit(_liffId);
      _isInitialized = true;
      log('LIFF initialized successfully');
      return true;
    } catch (e) {
      log('Error initializing LIFF: $e');
      return false;
    }
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    if (_isMockMode) return true;
    if (!_isInitialized || !kIsWeb) return false;
    return _liffIsLoggedIn();
  }

  /// Login with LINE
  static Future<void> login() async {
    if (_isMockMode) {
      _isInitialized = true;
      _profile ??= _ensureMockProfile();
      return;
    }
    if (!_isInitialized) {
      await init();
    }
    _liffLogin();
  }

  /// Logout from LINE
  static void logout() {
    if (_isMockMode) {
      _profile = null;
      return;
    }
    if (!_isInitialized || !kIsWeb) return;
    _liffLogout();
    _profile = null;
  }

  /// Get user profile
  static Future<LiffProfile?> getProfile() async {
    if (_isMockMode) {
      _profile ??= _ensureMockProfile();
      return _profile;
    }

    if (_profile != null) return _profile;

    if (!_isInitialized) {
      final initialized = await init();
      if (!initialized) return null;
    }

    if (!isLoggedIn()) return null;

    try {
      final profileData = await _liffGetProfile();
      _profile = LiffProfile.fromJson(profileData);
      return _profile;
    } catch (e) {
      final errorMessage = e.toString();
      log('Error getting profile: $errorMessage');

      // Check if it's a permission/scope error
      if (errorMessage.contains('permission') ||
          errorMessage.contains('scope') ||
          errorMessage.contains('not in LIFF app scope')) {
        log('❌ LIFF scope error detected!');
        log('⚠️  Please add "profile" scope to your LIFF app in LINE Developers Console');
        log('📝 Steps: LINE Developers Console → Your Channel → LIFF → Select your app → Add "profile" scope → Update');
      }

      return null;
    }
  }

  /// Get access token
  static String? getAccessToken() {
    if (_isMockMode) return 'mock-access-token';
    if (!_isInitialized || !kIsWeb) return null;
    try {
      return _liffGetAccessToken();
    } catch (e) {
      log('Error getting access token: $e');
      return null;
    }
  }

  /// Close LIFF window
  static void closeWindow() {
    if (_isMockMode) return;
    if (!_isInitialized || !kIsWeb) return;
    _liffCloseWindow();
  }

  // JavaScript interop methods using dart:js_interop
  static bool _isLiffAvailable() {
    return _liff != null;
  }

  static _Liff? get _liff {
    try {
      final liffObj = _liffGlobal;
      return liffObj != null && !liffObj.isUndefined && !liffObj.isNull
          ? liffObj as _Liff
          : null;
    } catch (e) {
      log('Error getting liff property: $e');
      return null;
    }
  }

  static Future<void> _liffInit(String liffId) async {
    final liff = _liff;
    if (liff == null) return;

    final config = _LiffConfig(liffId: liffId.toJS);
    await liff.init(config).toDart;
  }

  static bool _liffIsLoggedIn() {
    final liff = _liff;
    return liff?.isLoggedIn().toDart ?? false;
  }

  static void _liffLogin() {
    final liff = _liff;
    liff?.login();
  }

  static void _liffLogout() {
    final liff = _liff;
    liff?.logout();
  }

  static Future<Map<String, dynamic>> _liffGetProfile() async {
    final liff = _liff;
    if (liff == null) return {};

    final profile = await liff.getProfile().toDart;
    return {
      'userId': profile.userId.toDart,
      'displayName': profile.displayName.toDart,
      'pictureUrl': profile.pictureUrl?.toDart,
      'statusMessage': profile.statusMessage?.toDart,
    };
  }

  static String? _liffGetAccessToken() {
    final liff = _liff;
    return liff?.getAccessToken()?.toDart;
  }

  static void _liffCloseWindow() {
    final liff = _liff;
    liff?.closeWindow();
  }
}

// JS Interop definitions for LIFF
@JS()
@anonymous
extension type _Liff._(JSObject _) implements JSObject {
  external JSPromise<JSAny?> init(_LiffConfig config);
  external JSBoolean isLoggedIn();
  external void login();
  external void logout();
  external JSPromise<_LiffProfile> getProfile();
  external JSString? getAccessToken();
  external void closeWindow();
}

@JS()
@anonymous
extension type _LiffConfig._(JSObject _) implements JSObject {
  external factory _LiffConfig({JSString liffId});
}

@JS()
@anonymous
extension type _LiffProfile._(JSObject _) implements JSObject {
  external JSString get userId;
  external JSString get displayName;
  external JSString? get pictureUrl;
  external JSString? get statusMessage;
}

/// LINE User Profile Model
class LiffProfile {
  final String userId;
  final String displayName;
  final String? pictureUrl;
  final String? statusMessage;

  LiffProfile({
    required this.userId,
    required this.displayName,
    this.pictureUrl,
    this.statusMessage,
  });

  factory LiffProfile.fromJson(Map<String, dynamic> json) {
    return LiffProfile(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      pictureUrl: json['pictureUrl'] as String?,
      statusMessage: json['statusMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'pictureUrl': pictureUrl,
      'statusMessage': statusMessage,
    };
  }
}
