import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/services/auth_service.dart';
import 'package:rodzendai_form/core/services/liff_service.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/widgets/loading_widget.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _status = 'กำลังเชื่อมต่อ...';
  bool _isNavigating = false; // ป้องกัน navigation หลายครั้ง

  @override
  void initState() {
    super.initState();
    // ใช้ WidgetsBinding เพื่อรอให้ widget build เสร็จก่อน
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeApp();
      }
    });
  }

  Future<void> _initializeApp() async {
    if (_isNavigating) return; // ป้องกัน double navigation

    try {
      final authService = locator<AuthService>();
      final uri = Uri.base;

      log('🔄 Starting app initialization...');
      log('🔍 URL: ${uri.toString()}');

      // ⭐ เช็คว่ามี session เดิมอยู่หรือไม่ (กรณี refresh หน้า)
      await authService.initialize();

      if (authService.isAuthenticated && authService.loginType == 'external') {
        // เช็คว่า token หมดอายุหรือยัง
        if (authService.isTokenExpired()) {
          log('⏰ [External Login] Token expired, need to re-authenticate');

          if (!mounted) return;
          setState(
            () => _status = 'Token หมดอายุ กำลังเปลี่ยนไปใช้ LINE Login...',
          );
          await Future.delayed(const Duration(seconds: 2));

          // ลบ session เดิม
          await authService.logout();

          // ไปที่ LIFF login (ไม่ return ให้ทำงานต่อ)
          log(
            '➡️ [External Login] Token expired, falling through to LIFF login',
          );
        } else {
          // Token ยังไม่หมดอายุ ไปหน้า home
          log('✅ [External Login] Found existing external session (valid)');

          if (!mounted) return;
          setState(() => _status = 'พบข้อมูลการเข้าสู่ระบบ');
          await Future.delayed(const Duration(milliseconds: 300));

          if (!mounted || _isNavigating) return;
          _isNavigating = true;

          log('➡️ [External Login] Navigating to home page (cached session)');
          if (mounted) {
            context.go('/home');
          }
          return;
        }
      }

      // ============================================
      // 🎫 แบบที่ 1: Login ผ่าน Web-Admin (External Token)
      // ============================================
      final tempToken = uri.queryParameters['token'];
      final userIdFromUrl = uri.queryParameters['userId'];

      if (tempToken != null && tempToken.isNotEmpty) {
        log('🎫 [External Login] Token received from web-admin');
        log('🎫 Token: ${tempToken.substring(0, 10)}...');

        if (!mounted) return;
        setState(() {
          log('กำลังตรวจสอบ token จาก web-admin...');
          _status = 'กำลังตรวจข้อมูล';
        });

        // ตรวจสอบและบันทึก token
        final isValid = await authService.setExternalToken(
          tempToken,
          userIdFromUrl,
        );

        if (!isValid) {
          log('❌ [External Login] Invalid token');
          if (!mounted) return;
          setState(
            () => _status = 'Token ไม่ถูกต้อง กำลังเปลี่ยนไปใช้ LINE Login...',
          );
          await Future.delayed(const Duration(seconds: 2));

          // ลบ external token ที่ไม่ถูกต้องออก
          await authService.logout();

          // ไม่ return ให้ทำงานต่อไปที่ LIFF login
          log(
            '➡️ [External Login] Token invalid, falling through to LIFF login',
          );
        } else {
          // Token ถูกต้อง ไปหน้า home
          log('✅ [External Login] Token validated successfully');

          if (!mounted) return;
          setState(() => _status = 'เข้าสู่ระบบสำเร็จ');
          await Future.delayed(const Duration(milliseconds: 500));

          if (!mounted || _isNavigating) return;
          _isNavigating = true;

          log('➡️ [External Login] Navigating to home page');
          if (mounted) {
            // นำไปหน้า home (GoRouter จะลบ query parameters อัตโนมัติ)
            context.go('/home');
          }
          return;
        }
      }

      // ============================================
      // 🟢 แบบที่ 2: Login ผ่าน LINE LIFF
      // ============================================
      if (!mounted) return;
      setState(() => _status = 'กำลังเชื่อมต่อกับ LINE...');

      log('🟢 [LIFF Login] Starting LIFF authentication...');

      if (!mounted) return;
      setState(() => _status = 'กำลังเชื่อมต่อ LIFF...');

      try {
        await LiffService.init();
        log('✅ LIFF initialized');
      } catch (e) {
        log('⚠️ LIFF not available: $e');

        if (!mounted) return;
        setState(() => _status = 'เริ่มต้นแอปพลิเคชัน...');
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted || _isNavigating) return;
        _isNavigating = true;

        log('➡️ Navigating to home page (no LIFF)');
        if (mounted) {
          context.go('/home');
        }
        return;
      }

      // ⭐ เช็คว่ามี code parameter ไหม (หลัง login redirect กลับมา)
      final hasLoginCallback = uri.queryParameters.containsKey('code');

      if (hasLoginCallback) {
        log('🔄 Login callback detected: ${uri.queryParameters}');
        if (!mounted) return;
        setState(() => _status = 'กำลังประมวลผลการเข้าสู่ระบบ...');
      }

      // ⭐ ใช้ polling loop เพื่อรอ LIFF ประมวลผล login callback ให้เสร็จ
      // LIFF SDK อาจใช้เวลาหลายวินาทีในการแลก code เป็น access token
      bool isLoggedIn = LiffService.isLoggedIn();

      if (!isLoggedIn && hasLoginCallback) {
        log('🔍 Waiting for LIFF to process login callback...');
        const maxRetries = 10;
        const retryInterval = Duration(milliseconds: 500);

        for (int attempt = 1; attempt <= maxRetries; attempt++) {
          await Future.delayed(retryInterval);
          if (!mounted) return;

          // เช็คทั้ง isLoggedIn และ accessToken เป็น fallback
          isLoggedIn = LiffService.isLoggedIn();
          final hasToken = LiffService.getAccessToken() != null;

          log(
            '🔍 Login check attempt $attempt/$maxRetries: '
            'isLoggedIn=$isLoggedIn, hasToken=$hasToken',
          );

          if (isLoggedIn || hasToken) {
            isLoggedIn = true;
            log('✅ Login confirmed on attempt $attempt');
            break;
          }

          if (!mounted) return;
          setState(() => _status = 'กำลังประมวลผลการเข้าสู่ระบบ... ');
        }
      }

      log('🔐 Is logged in: $isLoggedIn');

      if (isLoggedIn) {
        if (!mounted) return;
        setState(() => _status = 'กำลังดึงข้อมูลผู้ใช้...');

        await authService.initialize();

        if (authService.isAuthenticated) {
          log('✅ User logged in: ${authService.displayName}');
          log('✅ User ID: ${authService.userId}');
        } else {
          log('⚠️ Failed to get user profile');
        }

        if (!mounted) return;
        setState(() => _status = 'เสร็จสิ้น');
        await Future.delayed(const Duration(milliseconds: 300));

        if (!mounted || _isNavigating) return;
        _isNavigating = true;

        log('➡️ Navigating to home page');
        if (mounted) {
          // ลบ query parameters ออกจาก URL ก่อน navigate
          context.go('/home');
        }
      } else if (hasLoginCallback) {
        // Polling หมดแล้วยัง login ไม่ได้
        log('❌ Login failed after all retry attempts');
        if (!mounted) return;
        setState(() => _status = 'ไม่สามารถเข้าสู่ระบบได้ กรุณาลองใหม่');

        await Future.delayed(const Duration(seconds: 2));

        // ให้ login ใหม่
        if (!mounted) return;
        LiffService.login();
      } else {
        // ⭐ ถ้าอยู่ใน LINE app (in-app browser) user ควร login อัตโนมัติหลัง init()
        // ถ้ายังไม่ login แสดงว่า LIFF ยังประมวลผลไม่เสร็จ → รอสักครู่แล้วลองใหม่
        if (LiffService.isInClient()) {
          log('📱 Inside LINE app but not logged in yet, waiting...');
          if (!mounted) return;
          setState(() => _status = 'กำลังเชื่อมต่อกับ LINE...');

          // รอให้ LIFF จัดการ auto-login ภายใน LINE app
          const maxRetries = 10;
          const retryInterval = Duration(milliseconds: 500);
          bool loggedIn = false;

          for (int attempt = 1; attempt <= maxRetries; attempt++) {
            await Future.delayed(retryInterval);
            if (!mounted) return;

            loggedIn = LiffService.isLoggedIn();
            final hasToken = LiffService.getAccessToken() != null;
            log(
              '📱 In-client login check $attempt/$maxRetries: '
              'isLoggedIn=$loggedIn, hasToken=$hasToken',
            );

            if (loggedIn || hasToken) {
              loggedIn = true;
              break;
            }
          }

          if (loggedIn) {
            if (!mounted) return;
            setState(() => _status = 'กำลังดึงข้อมูลผู้ใช้...');
            await authService.initialize();

            if (!mounted) return;
            setState(() => _status = 'เสร็จสิ้น');
            await Future.delayed(const Duration(milliseconds: 300));

            if (!mounted || _isNavigating) return;
            _isNavigating = true;

            log('➡️ Navigating to home page (LINE in-app)');
            if (mounted) {
              context.go('/home');
            }
          } else {
            log('❌ Auto-login failed inside LINE app');
            if (!mounted) return;
            setState(() => _status = 'ไม่สามารถเข้าสู่ระบบได้ กรุณาลองใหม่');
          }
          return;
        }

        log('🔑 Not logged in, triggering login...');
        if (!mounted) return;
        setState(() => _status = 'กำลังเข้าสู่ระบบ...');
        LiffService.login();
        return;
      }
    } catch (e, stackTrace) {
      log('❌ Error initializing app: $e');
      log('Stack trace: $stackTrace');

      if (!mounted) return;
      setState(() => _status = 'เกิดข้อผิดพลาด: $e');
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted || _isNavigating) return;
      _isNavigating = true;

      log('⏭️ Proceeding to home despite error');
      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  void dispose() {
    _isNavigating = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset('assets/images/img_logo.png', width: 300, height: 300),
            const SizedBox(height: 32),

            // Loading indicator
            LoadingWidget(),
            const SizedBox(height: 24),

            // Status text
            Text(_status, style: AppTextStyles.regular.copyWith(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
