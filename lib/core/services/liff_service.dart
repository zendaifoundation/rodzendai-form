import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// LIFF Service for LINE Login integration
class LiffService {
  static const String _liffId = String.fromEnvironment(
    'LIFF_ID',
    defaultValue: 'YOUR_LIFF_ID_HERE',
  );

  static bool _isInitialized = false;
  static LiffProfile? _profile;

  /// Initialize LIFF
  static Future<bool> init() async {
    if (_isInitialized) return true;

    try {
      if (!kIsWeb) {
        debugPrint('LIFF is only available on web platform');
        return false;
      }

      // Check if liff is available
      if (!_isLiffAvailable()) {
        debugPrint('LIFF SDK is not loaded');
        return false;
      }

      // Initialize LIFF
      await _liffInit(_liffId);
      _isInitialized = true;
      debugPrint('LIFF initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Error initializing LIFF: $e');
      return false;
    }
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    if (!_isInitialized || !kIsWeb) return false;
    return _liffIsLoggedIn();
  }

  /// Login with LINE
  static Future<void> login() async {
    if (!_isInitialized) {
      await init();
    }
    _liffLogin();
  }

  /// Logout from LINE
  static void logout() {
    if (!_isInitialized || !kIsWeb) return;
    _liffLogout();
    _profile = null;
  }

  /// Get user profile
  static Future<LiffProfile?> getProfile() async {
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
      debugPrint('Error getting profile: $e');
      return null;
    }
  }

  /// Get access token
  static String? getAccessToken() {
    if (!_isInitialized || !kIsWeb) return null;
    try {
      return _liffGetAccessToken();
    } catch (e) {
      debugPrint('Error getting access token: $e');
      return null;
    }
  }

  /// Close LIFF window
  static void closeWindow() {
    if (!_isInitialized || !kIsWeb) return;
    _liffCloseWindow();
  }

  // JavaScript interop methods using dart:js_interop
  static bool _isLiffAvailable() {
    return _liff != null;
  }

  static _Liff? get _liff {
    final liffObj = web.window.getProperty('liff'.toJS);
    return liffObj != null && !liffObj.isUndefined && !liffObj.isNull
        ? liffObj as _Liff
        : null;
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

// Extension to get property from Window
extension WindowExtension on web.Window {
  external JSAny? getProperty(JSString name);
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
