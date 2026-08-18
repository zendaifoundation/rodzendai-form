// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:rodzendai_form/core/constants/app_colors.dart';
// import 'package:rodzendai_form/core/constants/app_text_styles.dart';
// import 'package:rodzendai_form/core/services/auth_service.dart';
// import 'package:rodzendai_form/core/services/liff_service.dart';
// import 'package:rodzendai_form/core/services/service_locator.dart';
// import 'package:rodzendai_form/widgets/loading_widget.dart';

// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});

//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage> {
//   String _status = 'กำลังเชื่อมต่อ...';
//   bool _isNavigating = false; // ป้องกัน navigation หลายครั้ง

//   @override
//   void initState() {
//     super.initState();
//     // ใช้ WidgetsBinding เพื่อรอให้ widget build เสร็จก่อน
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         _initializeApp();
//       }
//     });
//   }

//   Future<void> _initializeApp() async {
//     if (_isNavigating) return; // ป้องกัน double navigation

//     try {
//       final authService = locator<AuthService>();
//       final uri = Uri.base;

//       log('🔄 Starting app initialization...');
//       log('🔍 URL: ${uri.toString()}');

//       // ⭐ เช็คว่ามี session เดิมอยู่หรือไม่ (กรณี refresh หน้า)
//       await authService.initialize();

//       if (authService.isAuthenticated && authService.loginType == 'external') {
//         // เช็คว่า token หมดอายุหรือยัง
//         if (authService.isTokenExpired()) {
//           log('⏰ [External Login] Token expired, need to re-authenticate');

//           if (!mounted) return;
//           setState(
//             () => _status = 'Token หมดอายุ กำลังเปลี่ยนไปใช้ LINE Login...',
//           );
//           await Future.delayed(const Duration(seconds: 2));

//           // ลบ session เดิม
//           await authService.logout();

//           // ไปที่ LIFF login (ไม่ return ให้ทำงานต่อ)
//           log(
//             '➡️ [External Login] Token expired, falling through to LIFF login',
//           );
//         } else {
//           // Token ยังไม่หมดอายุ ไปหน้า home
//           log('✅ [External Login] Found existing external session (valid)');

//           if (!mounted) return;
//           setState(() => _status = 'พบข้อมูลการเข้าสู่ระบบ');
//           await Future.delayed(const Duration(milliseconds: 300));

//           if (!mounted || _isNavigating) return;
//           _isNavigating = true;

//           log('➡️ [External Login] Navigating to home page (cached session)');
//           if (mounted) {
//             context.go('/home');
//           }
//           return;
//         }
//       }

//       // ============================================
//       // 🎫 แบบที่ 1: Login ผ่าน Web-Admin (External Token)
//       // ============================================
//       final tempToken = uri.queryParameters['token'];
//       final userIdFromUrl = uri.queryParameters['userId'];

//       if (tempToken != null && tempToken.isNotEmpty) {
//         log('🎫 [External Login] Token received from web-admin');
//         log('🎫 Token: ${tempToken.substring(0, 10)}...');

//         if (!mounted) return;
//         setState(() {
//           log('กำลังตรวจสอบ token จาก web-admin...');
//           _status = 'กำลังตรวจข้อมูล';
//         });

//         // ตรวจสอบและบันทึก token
//         final isValid = await authService.setExternalToken(
//           tempToken,
//           userIdFromUrl,
//         );

//         if (!isValid) {
//           log('❌ [External Login] Invalid token');
//           if (!mounted) return;
//           setState(
//             () => _status = 'Token ไม่ถูกต้อง กำลังเปลี่ยนไปใช้ LINE Login...',
//           );
//           await Future.delayed(const Duration(seconds: 2));

//           // ลบ external token ที่ไม่ถูกต้องออก
//           await authService.logout();

//           // ไม่ return ให้ทำงานต่อไปที่ LIFF login
//           log(
//             '➡️ [External Login] Token invalid, falling through to LIFF login',
//           );
//         } else {
//           // Token ถูกต้อง ไปหน้า home
//           log('✅ [External Login] Token validated successfully');

//           if (!mounted) return;
//           setState(() => _status = 'เข้าสู่ระบบสำเร็จ');
//           await Future.delayed(const Duration(milliseconds: 500));

//           if (!mounted || _isNavigating) return;
//           _isNavigating = true;

//           log('➡️ [External Login] Navigating to home page');
//           if (mounted) {
//             // นำไปหน้า home (GoRouter จะลบ query parameters อัตโนมัติ)
//             context.go('/home');
//           }
//           return;
//         }
//       }

//       // ============================================
//       // 🟢 แบบที่ 2: Login ผ่าน LINE LIFF
//       // ============================================
//       if (!mounted) return;
//       setState(() => _status = 'กำลังเชื่อมต่อกับ LINE...');

//       log('🟢 [LIFF Login] Starting LIFF authentication...');

//       // Check if LIFF is running in mock/development mode
//       const liffId = String.fromEnvironment('LIFF_ID', defaultValue: '');
//       final isMockMode = LiffService.isMockMode;

//       if (isMockMode) {
//         final liffIdLabel = liffId.isEmpty ? 'empty' : 'configured';
//         log('⚠️ LIFF mock mode active (LIFF_ID: $liffIdLabel)');
//         log('ℹ️ Running without real LINE login');

//         if (!mounted) return;
//         setState(() => _status = 'เริ่มต้นแอปพลิเคชัน (โหมดพัฒนา/ไม่มี LIFF)');

//         await authService.initialize();

//         if (!mounted) return;
//         setState(() => _status = 'เสร็จสิ้น');
//         await Future.delayed(const Duration(milliseconds: 300));

//         if (!mounted || _isNavigating) return;
//         _isNavigating = true;

//         log('➡️ Navigating to home page (mock LIFF)');
//         if (mounted) {
//           context.go('/home');
//         }
//         return;
//       }

//       if (!mounted) return;
//       setState(() => _status = 'กำลังเชื่อมต่อ LIFF...');

//       final initialized = await LiffService.init();
//       log('✅ LIFF initialized: $initialized');

//       if (!initialized) {
//         log('⚠️ LIFF not available, proceeding without login');

//         if (!mounted) return;
//         setState(() => _status = 'เริ่มต้นแอปพลิเคชัน...');
//         await Future.delayed(const Duration(milliseconds: 500));

//         if (!mounted || _isNavigating) return;
//         _isNavigating = true;

//         log('➡️ Navigating to home page (no LIFF)');
//         if (mounted) {
//           context.go('/home');
//         }
//         return;
//       }

//       // ⭐ เช็คว่ามี code parameter ไหม (หลัง login redirect กลับมา)
//       final hasLoginCallback = uri.queryParameters.containsKey('code');

//       if (hasLoginCallback) {
//         log('🔄 Login callback detected: ${uri.queryParameters}');
//         if (!mounted) return;
//         setState(() => _status = 'กำลังประมวลผลการเข้าสู่ระบบ...');

//         // ให้เวลา LIFF process callback และ set token
//         await Future.delayed(const Duration(milliseconds: 1500));

//         // บังคับ re-check login status
//         log('🔍 Re-checking login status after callback...');
//       }

//       final isLoggedIn = LiffService.isLoggedIn();
//       log('🔐 Is logged in: $isLoggedIn');

//       if (isLoggedIn) {
//         if (!mounted) return;
//         setState(() => _status = 'กำลังดึงข้อมูลผู้ใช้...');

//         await authService.initialize();

//         if (authService.isAuthenticated) {
//           log('✅ User logged in: ${authService.displayName}');
//           log('✅ User ID: ${authService.userId}');
//         } else {
//           log('⚠️ Failed to get user profile');
//         }

//         if (!mounted) return;
//         setState(() => _status = 'เสร็จสิ้น');
//         await Future.delayed(const Duration(milliseconds: 300));

//         if (!mounted || _isNavigating) return;
//         _isNavigating = true;

//         log('➡️ Navigating to home page');
//         if (mounted) {
//           // ลบ query parameters ออกจาก URL ก่อน navigate
//           context.go('/home');
//         }
//       } else if (hasLoginCallback) {
//         // มี callback แต่ยัง not logged in = LIFF ยังไม่เสร็จ
//         log('⚠️ Has callback but not logged in yet, waiting...');
//         if (!mounted) return;
//         setState(() => _status = 'กำลังเชื่อมต่อ...');

//         // รอเพิ่มอีกครั้ง
//         await Future.delayed(const Duration(seconds: 1));

//         // ลองเช็คอีกครั้ง
//         if (LiffService.isLoggedIn()) {
//           log('✅ Login successful after retry');
//           await authService.initialize();

//           if (!mounted || _isNavigating) return;
//           _isNavigating = true;

//           if (mounted) {
//             context.go('/home');
//           }
//         } else {
//           log('❌ Login failed after callback');
//           if (!mounted) return;
//           setState(() => _status = 'ไม่สามารถเข้าสู่ระบบได้ กรุณาลองใหม่');

//           await Future.delayed(const Duration(seconds: 1));

//           // ให้ login ใหม่
//           await LiffService.login();
//         }
//       } else {
//         log('🔑 Not logged in, triggering login...');
//         if (!mounted) return;
//         setState(() => _status = 'กำลังเข้าสู่ระบบ...');
//         await LiffService.login();
//         return;
//       }
//     } catch (e, stackTrace) {
//       log('❌ Error initializing app: $e');
//       log('Stack trace: $stackTrace');

//       if (!mounted) return;
//       setState(() => _status = 'เกิดข้อผิดพลาด: $e');
//       await Future.delayed(const Duration(seconds: 1));

//       if (!mounted || _isNavigating) return;
//       _isNavigating = true;

//       log('⏭️ Proceeding to home despite error');
//       if (mounted) {
//         context.go('/home');
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _isNavigating = false;
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Logo
//             Image.asset('assets/images/img_logo.png', width: 300, height: 300),
//             const SizedBox(height: 32),

//             // Loading indicator
//             LoadingWidget(),
//             const SizedBox(height: 24),

//             // Status text
//             Text(_status, style: AppTextStyles.regular.copyWith(fontSize: 16)),
//           ],
//         ),
//       ),
//     );
//   }
// }
