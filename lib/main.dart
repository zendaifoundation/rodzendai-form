import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rodzendai_form/app.dart';
import 'package:rodzendai_form/core/services/google_map_service.dart';
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

  // Initialize Google Maps
  final mapsStart = DateTime.now();
  await GoogleMapService.initialize();
  final mapsDuration = DateTime.now().difference(mapsStart);
  log('✅ Google Maps initialized in ${mapsDuration.inMilliseconds}ms');

  final totalDuration = DateTime.now().difference(startTime);
  log('🎉 Total initialization time: ${totalDuration.inMilliseconds}ms');

  runApp(const MyApp());
  log('🏃 App runningenvironment  -> ${EnvHelper.environment}');
  log('🏃 App running!');
}
