import 'dart:js_interop';

import 'package:rodzendai_form/core/utils/env_helper.dart';

/// LINE Profile model
class LineProfile {
  final String userId;
  final String displayName;
  final String? pictureUrl;
  final String? statusMessage;

  LineProfile({
    required this.userId,
    required this.displayName,
    this.pictureUrl,
    this.statusMessage,
  });
}

// --- JS Interop bindings for LIFF SDK ---

@JS('liff.init')
external JSPromise<JSAny?> _liffInit(JSObject config);

@JS('liff.isLoggedIn')
external bool _liffIsLoggedIn();

@JS('liff.login')
external void _liffLogin();

@JS('liff.logout')
external void _liffLogout();

@JS('liff.getProfile')
external JSPromise<JSObject> _liffGetProfile();

@JS('liff.getAccessToken')
external String? _liffGetAccessToken();

@JS('liff.isInClient')
external bool _liffIsInClient();

@JS('liff.getOS')
external String? _liffGetOS();

extension type LiffProfile(JSObject _) implements JSObject {
  external String get userId;
  external String get displayName;
  external String? get pictureUrl;
  external String? get statusMessage;
}

/// LIFF Service - wrapper around the LIFF JS SDK
class LiffService {
  static final String liffId = EnvHelper.lineLiffId;

  /// Initialize LIFF
  static Future<void> init() async {
    try {
      final config = <String, String>{'liffId': liffId}.jsify();
      await _liffInit(config as JSObject).toDart;
    } catch (e) {
      throw Exception('LIFF init failed: $e');
    }
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    return _liffIsLoggedIn();
  }

  /// Trigger LINE Login
  static void login() {
    _liffLogin();
  }

  /// Logout
  static void logout() {
    _liffLogout();
  }

  /// Check if running inside LINE app
  static bool isInClient() {
    return _liffIsInClient();
  }

  /// Get OS
  static String? getOS() {
    return _liffGetOS();
  }

  /// Get access token
  static String? getAccessToken() {
    return _liffGetAccessToken();
  }

  /// Get user profile
  static Future<LineProfile> getProfile() async {
    try {
      final jsProfile = await _liffGetProfile().toDart;
      final profile = LiffProfile(jsProfile);
      return LineProfile(
        userId: profile.userId,
        displayName: profile.displayName,
        pictureUrl: profile.pictureUrl,
        statusMessage: profile.statusMessage,
      );
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }
}
