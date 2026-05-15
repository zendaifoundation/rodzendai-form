import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:rodzendai_form/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rodzendai_form/core/services/liff_service.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';

/// Authentication Service
/// Manages user authentication state and profile
class AuthService extends ChangeNotifier {
  LiffProfile? _profile;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  static const String _keyProfile = 'user_profile';
  static const String _keyIsAuthenticated = 'is_authenticated';
  static const String _keyExternalToken = 'external_token';
  static const String _keyLoginType = 'login_type'; // 'liff' or 'external'
  static const String _keyTokenExpiration =
      'token_expiration'; // เก็บเวลาหมดอายุของ token
  static const String _keyLoginSource =
      'login_source'; // เก็บที่มาของการ login เช่น 'admin'

  // ดึง SharedPreferences จาก locator
  SharedPreferences get _prefs => locator<SharedPreferences>();

  String? _externalToken;
  String? _loginType;
  int? _tokenExpiration; // timestamp (milliseconds since epoch)
  String? _loginSource; // ที่มาของการ login เช่น 'admin'

  LiffProfile? get profile => _profile;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  /// Get user display name
  String? get displayName => _profile?.displayName;

  /// Get user ID
  String? get userId => _profile?.userId;

  /// Get user picture URL
  String? get pictureUrl => _profile?.pictureUrl;

  /// Initialize authentication
  Future<void> initialize() async {
    log('🔵 AuthService: Starting initialization...');
    _isLoading = true;
    notifyListeners();

    try {
      // ลองโหลดข้อมูลจาก SharedPreferences ก่อน (สำหรับกรณี refresh)
      await _loadFromStorage();
      log(
        '🔵 AuthService: After load from storage - isAuth: $_isAuthenticated, profile: ${_profile?.displayName}',
      );

      final initialized = await LiffService.init();
      log(
        '🔵 AuthService: LIFF initialized: $initialized, isLoggedIn: ${LiffService.isLoggedIn()}',
      );

      if (initialized && LiffService.isLoggedIn()) {
        _profile = await LiffService.getProfile();
        _isAuthenticated = _profile != null;

        // บันทึกข้อมูลลง storage
        if (_isAuthenticated) {
          await _saveToStorage();
        }
        log('🔵 AuthService: Logged in via LIFF - ${_profile?.displayName}');
      } else if (!_isAuthenticated) {
        // ถ้าไม่ได้ login ผ่าน LIFF และไม่มีข้อมูลใน storage
        _isAuthenticated = false;
        _profile = null;
        await _clearStorage();
        log('🔵 AuthService: Not logged in, cleared storage');
      } else {
        log('🔵 AuthService: Using cached profile from storage');
      }
    } catch (e) {
      log('❌ Error initializing auth: $e');
      // ถ้า error แต่มีข้อมูลใน storage ให้ใช้ต่อ
      if (_profile == null) {
        _isAuthenticated = false;
        _profile = null;
      }
    } finally {
      _isLoading = false;
      log(
        '✅ AuthService: Initialization complete - isAuth: $_isAuthenticated, profile: ${_profile?.displayName}',
      );
      notifyListeners();
    }
  }

  /// โหลดข้อมูลจาก SharedPreferences
  Future<void> _loadFromStorage() async {
    try {
      log('🔍 AuthService: Loading from storage...');
      final isAuth = _prefs.getBool(_keyIsAuthenticated) ?? false;
      final profileJson = _prefs.getString(_keyProfile);
      final loginType = _prefs.getString(_keyLoginType);
      final externalToken = _prefs.getString(_keyExternalToken);
      final tokenExpiration = _prefs.getInt(_keyTokenExpiration);
      final loginSource = _prefs.getString(_keyLoginSource);

      log(
        '🔍 AuthService: Storage data - isAuth: $isAuth, hasProfile: ${profileJson != null}, loginType: $loginType',
      );

      if (isAuth && profileJson != null) {
        final profileMap = json.decode(profileJson) as Map<String, dynamic>;
        _profile = LiffProfile(
          userId: profileMap['userId'] as String,
          displayName: profileMap['displayName'] as String? ?? '',
          pictureUrl: profileMap['pictureUrl'] as String?,
          statusMessage: profileMap['statusMessage'] as String?,
        );
        _isAuthenticated = true;
        _loginType = loginType ?? 'liff';
        _externalToken = externalToken;
        _tokenExpiration = tokenExpiration;
        _loginSource = loginSource;

        // เช็คว่า token หมดอายุหรือยัง
        if (loginType == 'external' && isTokenExpired()) {
          log('⏰ [External Token] Token expired, clearing session');
          _isAuthenticated = false;
          _profile = null;
          await _clearStorage();
        } else {
          log(
            '✅ Loaded auth from storage: ${_profile?.displayName} (type: $_loginType)',
          );
        }
      } else {
        log('⚠️ No auth data found in storage');
      }
    } catch (e) {
      log('❌ Error loading auth from storage: $e');
    }
  }

  /// บันทึกข้อมูลลง SharedPreferences
  Future<void> _saveToStorage() async {
    try {
      await _prefs.setBool(_keyIsAuthenticated, _isAuthenticated);

      if (_profile != null) {
        final profileMap = {
          'userId': _profile!.userId,
          'displayName': _profile!.displayName,
          'pictureUrl': _profile!.pictureUrl,
          'statusMessage': _profile!.statusMessage,
        };
        await _prefs.setString(_keyProfile, json.encode(profileMap));
        log('✅ Saved auth to storage: ${_profile?.displayName}');
      }
    } catch (e) {
      log('Error saving auth to storage: $e');
    }
  }

  /// ลบข้อมูลจาก SharedPreferences
  Future<void> _clearStorage() async {
    try {
      await _prefs.remove(_keyIsAuthenticated);
      await _prefs.remove(_keyProfile);
      await _prefs.remove(_keyExternalToken);
      await _prefs.remove(_keyLoginType);
      await _prefs.remove(_keyTokenExpiration);
      await _prefs.remove(_keyLoginSource);
      _externalToken = null;
      _loginType = null;
      _tokenExpiration = null;
      _loginSource = null;
      log('✅ Cleared auth from storage');
    } catch (e) {
      log('Error clearing auth from storage: $e');
    }
  }

  /// Login with LINE
  Future<void> login() async {
    await LiffService.login();
  }

  /// Logout
  Future<void> logout() async {
    LiffService.logout();
    _profile = null;
    _isAuthenticated = false;
    await _clearStorage();
    notifyListeners();
  }

  /// Refresh profile
  Future<void> refreshProfile() async {
    if (!LiffService.isLoggedIn()) {
      _profile = null;
      _isAuthenticated = false;
      await _clearStorage();
      notifyListeners();
      return;
    }

    try {
      _profile = await LiffService.getProfile();
      _isAuthenticated = _profile != null;

      if (_isAuthenticated) {
        await _saveToStorage();
      }

      notifyListeners();
    } catch (e) {
      log('Error refreshing profile: $e');
    }
  }

  /// Get access token
  String? getAccessToken() {
    // ถ้าเป็น external login ให้ใช้ external token
    if (_loginType == 'external' && _externalToken != null) {
      return _externalToken;
    }
    // ถ้าเป็น LIFF login ให้ใช้ LIFF access token
    return LiffService.getAccessToken();
  }

  /// Get login type
  String? get loginType => _loginType;

  /// Get login source (เช่น 'admin' จาก web-admin)
  String? get loginSource => _loginSource;

  /// เช็คว่า external token หมดอายุหรือยัง
  bool isTokenExpired() {
    if (_loginType != 'external' || _tokenExpiration == null) {
      return false; // ถ้าไม่ใช่ external login หรือไม่มี expiration ถือว่าไม่หมดอายุ
    }

    final now =
        DateTime.now().millisecondsSinceEpoch ~/ 1000; // แปลงเป็น seconds
    final isExpired = now >= _tokenExpiration!;

    if (isExpired) {
      log(
        '⏰ [External Token] Token expired at: ${DateTime.fromMillisecondsSinceEpoch(_tokenExpiration! * 1000)}',
      );
    }

    return isExpired;
  }

  /// Set external token (จาก web-admin)
  /// จะตรวจสอบ token กับ backend ก่อนบันทึก
  Future<bool> setExternalToken(
    String tempToken,
    String? userId, {
    String? source,
  }) async {
    try {
      log('🎫 Setting external token... (source=$source)');

      // ตรวจสอบ token กับ backend
      final isValid = await _verifyTempToken(tempToken);
      if (!isValid) {
        log('❌ Invalid temp token');
        return false;
      }

      _externalToken = tempToken;
      _loginType = 'external';
      _loginSource = source;
      _isAuthenticated = true;

      // บันทึกลง storage
      await _prefs.setString(_keyExternalToken, tempToken);
      await _prefs.setString(_keyLoginType, 'external');
      if (source != null && source.isNotEmpty) {
        await _prefs.setString(_keyLoginSource, source);
      } else {
        await _prefs.remove(_keyLoginSource);
      }
      await _saveToStorage();

      log('✅ External token set successfully');
      notifyListeners();
      return true;
    } catch (e) {
      log('❌ Error setting external token: $e');
      return false;
    }
  }

  /// ตรวจสอบ temp token กับ backend
  Future<bool> _verifyTempToken(String tempToken) async {
    try {
      final authRepo = locator<AuthRepository>();
      final userData = await authRepo.verifyTempToken(tempToken: tempToken);

      // อัพเดท profile จากข้อมูลที่ได้
      _profile = LiffProfile(
        userId: userData['uid'] as String,
        displayName: userData['name'] as String? ?? '-',
        pictureUrl: null,
        statusMessage: null,
      );

      // เก็บ expiration time (exp เป็น Unix timestamp ในหน่วย seconds)
      if (userData['exp'] != null) {
        _tokenExpiration = userData['exp'] as int;
        await _prefs.setInt(_keyTokenExpiration, _tokenExpiration!);

        final expiryDate = DateTime.fromMillisecondsSinceEpoch(
          _tokenExpiration! * 1000,
        );
        log('⏰ [External Token] Token will expire at: $expiryDate');
      }

      return true;
    } catch (e) {
      log('❌ Error verifying temp token: $e');
      return false;
    }
  }
}
