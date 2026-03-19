import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/services/auth_service.dart';
import 'package:rodzendai_form/core/services/liff_service.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/widgets/loading_widget.dart';

class SplashPageV2 extends StatefulWidget {
  const SplashPageV2({super.key});

  @override
  State<SplashPageV2> createState() => _SplashPageV2State();
}

class _SplashPageV2State extends State<SplashPageV2> {
  String _status = 'กำลังโหลด...';
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    if (_isNavigating) return;

    final authService = locator<AuthService>();

    try {
      _setStatus('กำลังเชื่อมต่อ...');

      // Auth already initialized in main.dart before runApp
      if (!mounted) return;

      // Dev / mock mode — bypass auth check
      if (LiffService.isMockMode) {
        log('⚠️ SplashPageV2: mock mode, navigating to home');
        _setStatus('โหมดพัฒนา');
        _navigate('/home');
        return;
      }

      // Authenticated via LIFF
      if (authService.isAuthenticated) {
        log('✅ SplashPageV2: authenticated as ${authService.displayName}');
        _setStatus('เข้าสู่ระบบสำเร็จ');
        _navigate('/home');
        return;
      }

      // Not authenticated — trigger LIFF login (redirects the browser)
      log('🔒 SplashPageV2: not authenticated, starting LIFF login...');
      _setStatus('กำลังเข้าสู่ระบบ LINE...');
      await LiffService.login();

      // If login() does not redirect (e.g. already handled), re-check
      if (!mounted) return;
      if (authService.isAuthenticated) {
        _navigate('/home');
      }
    } catch (e) {
      log('❌ SplashPageV2: error during initialization: $e');
      if (!mounted) return;
      _setStatus('เกิดข้อผิดพลาด กรุณาลองใหม่');
    }
  }

  void _setStatus(String status) {
    if (mounted) setState(() => _status = status);
  }

  void _navigate(String path) {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/img_logo.png', width: 300, height: 300),
            const SizedBox(height: 32),
            LoadingWidget(),
            const SizedBox(height: 24),
            Text(_status, style: AppTextStyles.regular.copyWith(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
