import 'dart:js_util' as js_util;

import 'package:flutter/foundation.dart';

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

  // JavaScript interop methods
  static bool _isLiffAvailable() {
    return js_util.hasProperty(js_util.globalThis, 'liff');
  }

  static Future<void> _liffInit(String liffId) async {
    final liff = js_util.getProperty(js_util.globalThis, 'liff');
    await js_util.promiseToFuture(
      js_util.callMethod(liff, 'init', [
        js_util.jsify({'liffId': liffId}),
      ]),
    );
  }

  static bool _liffIsLoggedIn() {
    final liff = js_util.getProperty(js_util.globalThis, 'liff');
    return js_util.callMethod(liff, 'isLoggedIn', []);
  }

  static void _liffLogin() {
    final liff = js_util.getProperty(js_util.globalThis, 'liff');
    js_util.callMethod(liff, 'login', []);
  }

  static void _liffLogout() {
    final liff = js_util.getProperty(js_util.globalThis, 'liff');
    js_util.callMethod(liff, 'logout', []);
  }

  static Future<Map<String, dynamic>> _liffGetProfile() async {
    final liff = js_util.getProperty(js_util.globalThis, 'liff');
    final profile = await js_util.promiseToFuture(
      js_util.callMethod(liff, 'getProfile', []),
    );
    return _jsObjectToMap(profile);
  }

  static String? _liffGetAccessToken() {
    final liff = js_util.getProperty(js_util.globalThis, 'liff');
    return js_util.callMethod(liff, 'getAccessToken', []);
  }

  static void _liffCloseWindow() {
    final liff = js_util.getProperty(js_util.globalThis, 'liff');
    js_util.callMethod(liff, 'closeWindow', []);
  }

  static Map<String, dynamic> _jsObjectToMap(dynamic jsObject) {
    final map = <String, dynamic>{};
    final keys =
        js_util.callMethod(
              js_util.getProperty(js_util.globalThis, 'Object'),
              'keys',
              [jsObject],
            )
            as List<dynamic>;

    for (final key in keys) {
      map[key.toString()] = js_util.getProperty(jsObject, key.toString());
    }

    return map;
  }
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
