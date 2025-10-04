import 'package:flutter/foundation.dart';
import 'package:rodzendai_form/core/services/liff_service.dart';

/// Authentication Service
/// Manages user authentication state and profile
class AuthService extends ChangeNotifier {
  LiffProfile? _profile;
  bool _isAuthenticated = false;
  bool _isLoading = false;

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
    _isLoading = true;
    notifyListeners();

    try {
      final initialized = await LiffService.init();

      if (initialized && LiffService.isLoggedIn()) {
        _profile = await LiffService.getProfile();
        _isAuthenticated = _profile != null;
      } else {
        _isAuthenticated = false;
        _profile = null;
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      _isAuthenticated = false;
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with LINE
  Future<void> login() async {
    await LiffService.login();
  }

  /// Logout
  void logout() {
    LiffService.logout();
    _profile = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Refresh profile
  Future<void> refreshProfile() async {
    if (!LiffService.isLoggedIn()) {
      _profile = null;
      _isAuthenticated = false;
      notifyListeners();
      return;
    }

    try {
      _profile = await LiffService.getProfile();
      _isAuthenticated = _profile != null;
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
