import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rodzendai_form/presentation/home_page/pages/home_page.dart';
import 'package:rodzendai_form/presentation/register/pages/register_page.dart';
import 'package:rodzendai_form/presentation/register/pages/register_success_page.dart';
import 'package:rodzendai_form/presentation/register_status/pages/register_status_page.dart';
import 'package:rodzendai_form/presentation/splash/pages/splash_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static AppRouter? _instance;
  late final GoRouter router;

  // Singleton pattern
  AppRouter._internal() {
    router = _createRouter();
  }

  factory AppRouter() {
    _instance ??= AppRouter._internal();
    return _instance!;
  }

  GoRouter _createRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: kDebugMode,
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const SplashPage()),
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
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const RegisterSuccessPage(),
          ),
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
                onPressed: () => context.go('/home'),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),

      // Hot reload support - preserve current location
      redirect: (context, state) {
        // ใน debug mode ให้ preserve current location
        if (kDebugMode) {
          return null; // ไม่ redirect ให้อยู่ที่เดิม
        }
        return null;
      },
    );
  }
}
