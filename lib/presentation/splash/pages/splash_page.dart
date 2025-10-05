import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/services/auth_service.dart';
import 'package:rodzendai_form/core/services/liff_service.dart';
import 'package:rodzendai_form/widgets/loading_widget.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _status = 'กำลังเชื่อมต่อ...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authService = context.read<AuthService>();

    try {
      setState(() => _status = 'กำลังเชื่อมต่อกับ LINE...');

      log('🔄 Starting LIFF initialization...');

      // Check if we're in development without LIFF_ID
      //const liffId = String.fromEnvironment('LIFF_ID', defaultValue: '');
      const liffId = ''; // For development without LINE login

      if (liffId.isEmpty || liffId == 'YOUR_LIFF_ID_HERE') {
        log('⚠️ LIFF_ID not configured, skipping LIFF initialization');
        log('ℹ️ Running in development mode without LINE login');
        setState(() => _status = 'เริ่มต้นแอปพลิเคชัน (ไม่มี LINE login)');
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        context.go('/home');
        return;
      }

      final initialized = await LiffService.init();
      log('✅ LIFF initialized: $initialized');

      if (!initialized) {
        log('⚠️ LIFF not available, proceeding without login');
        setState(() => _status = 'เริ่มต้นแอปพลิเคชัน...');
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        context.go('/home');
        return;
      }

      final isLoggedIn = LiffService.isLoggedIn();
      log('🔐 Is logged in: $isLoggedIn');

      if (isLoggedIn) {
        setState(() => _status = 'กำลังดึงข้อมูลผู้ใช้...');
        await authService.initialize();

        if (authService.isAuthenticated) {
          log('✅ User logged in: ${authService.displayName}');
          log('✅ User ID: ${authService.userId}');
        } else {
          log('⚠️ Failed to get user profile');
        }

        setState(() => _status = 'เสร็จสิ้น');
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        context.go('/home');
      } else {
        log('🔑 Not logged in, triggering login...');
        setState(() => _status = 'กำลังเข้าสู่ระบบ...');
        await LiffService.login();
        return;
      }
    } catch (e, stackTrace) {
      log('❌ Error initializing app: $e');
      log('Stack trace: $stackTrace');

      setState(() => _status = 'เกิดข้อผิดพลาด: $e');
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      log('⏭️ Proceeding to home despite error');
      context.go('/home');
    }
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
