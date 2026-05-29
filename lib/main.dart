import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rodzendai_form/app.dart';
import 'package:rodzendai_form/core/services/auth_service.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
import 'package:rodzendai_form/firebase_options.dart';

Future<void> main() async {
  final startTime = DateTime.now();
  log('🚀 Application starting at ${startTime.toIso8601String()}');

  WidgetsFlutterBinding.ensureInitialized();
  log('✅ WidgetsFlutterBinding initialized');

  //setPathUrlStrategy();
  usePathUrlStrategy();
  log('✅ URL strategy configured');

  // Setup Service Locator
  final locatorStart = DateTime.now();
  await setupServiceLocator();
  final locatorDuration = DateTime.now().difference(locatorStart);
  log('✅ Service Locator initialized in ${locatorDuration.inMilliseconds}ms');

  // Initialize Firebase
  final firebaseStart = DateTime.now();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firebaseDuration = DateTime.now().difference(firebaseStart);
  log('✅ Firebase initialized in ${firebaseDuration.inMilliseconds}ms');

  // Initialize date formatting for Thai locale
  final dateStart = DateTime.now();
  await initializeDateFormatting('th_TH', null);
  final dateDuration = DateTime.now().difference(dateStart);
  log('✅ Date formatting initialized in ${dateDuration.inMilliseconds}ms');

  final totalDuration = DateTime.now().difference(startTime);
  log('🎉 Total initialization time: ${totalDuration.inMilliseconds}ms');

  final authService = locator<AuthService>();
  await authService.initialize();

  runApp(const MyApp());
  log('🏃 App runningenvironment  -> ${EnvHelper.environment}');
  log('🏃 App running!');
}
