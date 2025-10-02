import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rodzendai_form/app.dart';
import 'package:rodzendai_form/core/services/google_map_service.dart';
import 'package:rodzendai_form/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize date formatting for Thai locale
  await initializeDateFormatting('th_TH', null);


  await GoogleMapService.initialize();
  runApp(const MyApp());
}
