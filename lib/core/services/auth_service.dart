import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rodzendai_form/core/services/liff_service.dart';

/// Authentication Service
/// Manages user authentication state and profile
class AuthService extends ChangeNotifier {
  LiffProfile? _profile;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  static const String _keyProfile = 'user_profile';
  static const String _keyIsAuthenticated = 'is_authenticated';

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
    debugPrint('🔵 AuthService: Starting initialization...');
    _isLoading = true;
    notifyListeners();

    try {
      // ลองโหลดข้อมูลจาก SharedPreferences ก่อน (สำหรับกรณี refresh)
      await _loadFromStorage();
      debugPrint(
        '🔵 AuthService: After load from storage - isAuth: $_isAuthenticated, profile: ${_profile?.displayName}',
      );

      final initialized = await LiffService.init();
      debugPrint(
        '🔵 AuthService: LIFF initialized: $initialized, isLoggedIn: ${LiffService.isLoggedIn()}',
      );

      if (initialized && LiffService.isLoggedIn()) {
        _profile = await LiffService.getProfile();
        _isAuthenticated = _profile != null;

        // บันทึกข้อมูลลง storage
        if (_isAuthenticated) {
          await _saveToStorage();
        }
        debugPrint(
          '🔵 AuthService: Logged in via LIFF - ${_profile?.displayName}',
        );
      } else if (!_isAuthenticated) {
        // ถ้าไม่ได้ login ผ่าน LIFF และไม่มีข้อมูลใน storage
        _isAuthenticated = false;
        _profile = null;
        await _clearStorage();
        debugPrint('🔵 AuthService: Not logged in, cleared storage');
      } else {
        debugPrint('🔵 AuthService: Using cached profile from storage');
      }
    } catch (e) {
      debugPrint('❌ Error initializing auth: $e');
      // ถ้า error แต่มีข้อมูลใน storage ให้ใช้ต่อ
      if (_profile == null) {
        _isAuthenticated = false;
        _profile = null;
      }
    } finally {
      _isLoading = false;
      debugPrint(
        '✅ AuthService: Initialization complete - isAuth: $_isAuthenticated, profile: ${_profile?.displayName}',
      );
      notifyListeners();
    }
  }

  /// โหลดข้อมูลจาก SharedPreferences
  Future<void> _loadFromStorage() async {
    try {
      debugPrint('🔍 AuthService: Loading from storage...');
      final prefs = await SharedPreferences.getInstance();
      final isAuth = prefs.getBool(_keyIsAuthenticated) ?? false;
      final profileJson = prefs.getString(_keyProfile);

      debugPrint(
        '🔍 AuthService: Storage data - isAuth: $isAuth, hasProfile: ${profileJson != null}',
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
        debugPrint('✅ Loaded auth from storage: ${_profile?.displayName}');
      } else {
        debugPrint('⚠️ No auth data found in storage');
      }
    } catch (e) {
      debugPrint('❌ Error loading auth from storage: $e');
    }
  }

  /// บันทึกข้อมูลลง SharedPreferences
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsAuthenticated, _isAuthenticated);

      if (_profile != null) {
        final profileMap = {
          'userId': _profile!.userId,
          'displayName': _profile!.displayName,
          'pictureUrl': _profile!.pictureUrl,
          'statusMessage': _profile!.statusMessage,
        };
        await prefs.setString(_keyProfile, json.encode(profileMap));
        debugPrint('✅ Saved auth to storage: ${_profile?.displayName}');
      }
    } catch (e) {
      debugPrint('Error saving auth to storage: $e');
    }
  }

  /// ลบข้อมูลจาก SharedPreferences
  Future<void> _clearStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyIsAuthenticated);
      await prefs.remove(_keyProfile);
      debugPrint('✅ Cleared auth from storage');
    } catch (e) {
      debugPrint('Error clearing auth from storage: $e');
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
      debugPrint('Error refreshing profile: $e');
    }
  }

  /// Get access token
  String? getAccessToken() {
    return LiffService.getAccessToken();
  }
}
