import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rodzendai_form/core/services/auth_service.dart';
import 'package:rodzendai_form/core/services/liff_service.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/models/create_appointment_response_model.dart';
import 'package:rodzendai_form/presentation/home_page/pages/home_page.dart';
import 'package:rodzendai_form/presentation/register/pages/register_page.dart';
import 'package:rodzendai_form/presentation/register/pages/register_success_page.dart';
import 'package:rodzendai_form/presentation/register_status/pages/register_status_page.dart';
import 'package:rodzendai_form/presentation/edit_address/pages/edit_address_page.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/pages/register_to_claim_your_rights_page.dart';
//import 'package:rodzendai_form/presentation/splash/pages/splash_page.dart';
import 'package:rodzendai_form/presentation/splash/pages/splash_page_v2.dart';

class AppRouterV2 {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  late final GoRouter router;

  AppRouterV2() {
    router = _createRouter();
  }

  GoRouter _createRouter() {
    // ดึง authService จาก service locator
    final authService = locator<AuthService>();

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: kDebugMode,
      refreshListenable: authService, // รับฟังการเปลี่ยนแปลงของ auth state
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          pageBuilder: (context, state) =>
              //NoTransitionPage(key: state.pageKey, child: const SplashPage()),
              NoTransitionPage(key: state.pageKey, child: const SplashPageV2()),
        ),

        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) =>
              MaterialPage(key: state.pageKey, child: const HomePage()),
        ),

        GoRoute(
          path: '/register',
          name: 'register',
          pageBuilder: (context, state) =>
              MaterialPage(key: state.pageKey, child: const RegisterPage()),
        ),

        GoRoute(
          path: '/register-success',
          name: 'registerSuccess',
          pageBuilder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;

            String? patientIdCard = args?['patientIdCard'];
            String? appointmentDate = args?['appointmentDate'];
            List<AppointmentDateModel>? appointmentDates =
                args?['appointmentDates'];
            return MaterialPage(
              key: state.pageKey,
              child: RegisterSuccessPage(
                patientIdCard: patientIdCard,
                appointmentDate: appointmentDate,
                appointmentDates: appointmentDates,
              ),
            );
          },
        ),

        GoRoute(
          path: '/register-status',
          name: 'registerStatus',
          pageBuilder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            String? nationalId = args?['nationalId'];
            String? date = args?['date'];
            return MaterialPage(
              key: state.pageKey,
              child: RegisterStatusPage(date: date, nationalId: nationalId),
            );
          },
        ),

        GoRoute(
          path: '/register-to-claim-your-rights',
          name: 'registerToClaimYourRights',
          pageBuilder: (context, state) {
            return MaterialPage(
              key: state.pageKey,
              child: RegisterToClaimYourRightsPage(),
            );
          },
        ),

        GoRoute(
          path: '/edit-address',
          name: 'editAddress',
          pageBuilder: (context, state) {
            return MaterialPage(
              key: state.pageKey,
              child: const EditAddressPage(),
            );
          },
        ),
      ],

      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found: ${state.matchedLocation}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go to Splash'),
              ),
            ],
          ),
        ),
      ),

      redirect: (context, state) {
        final authService = locator<AuthService>();
        final isAuthenticated = authService.isAuthenticated;
        final currentPath = state.matchedLocation;

        // Check if running in development mode without LIFF
        const liffId = String.fromEnvironment('LIFF_ID', defaultValue: '');
        const bool devFlag = bool.fromEnvironment(
          'DEV_MODE',
          defaultValue: false,
        );
        final bool isDevelopmentMode =
            devFlag || LiffService.isMockMode || liffId.isEmpty;

        // Routes that require authentication
        final protectedRoutes = [
          '/home',
          '/register',
          '/register-success',
          '/register-status',
          '/register-to-claim-your-rights',
          '/edit-address',
        ];

        // ถ้าอยู่ใน development mode ไม่ต้องเช็ค auth
        if (isDevelopmentMode) {
          log(
            '🔓 Development mode routing: bypassing auth (DEV_MODE=$devFlag, LIFF_ID=${liffId.isEmpty ? 'empty' : 'configured'})',
          );
          return null;
        }

        // ถ้า authenticated และยังอยู่ที่ splash ให้ไป home
        if (isAuthenticated && currentPath == '/') {
          log('✅ Already authenticated, redirecting to home');
          return '/home';
        }

        // ถ้าไม่ได้ login และพยายามเข้า protected routes ให้ redirect ไปที่ splash
        if (!isAuthenticated && protectedRoutes.contains(currentPath)) {
          log('🔒 Redirecting to splash: not authenticated');
          return '/';
        }
        // ปล่อยให้ SplashPage จัดการ navigation เอง ไม่ต้อง redirect จาก router
        return null;
      },
    );
  }
}
