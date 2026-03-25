import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/logbook/models/log_model.dart';
import 'package:flutter_application_1/features/onboarding/onboarding_view.dart';
import 'package:flutter_application_1/features/auth/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables and initialize date formatting
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('id_ID', null);

  // Hive Initialization
  await Hive.initFlutter();
  Hive.registerAdapter(LogModelAdapter());
  await Hive.openBox<LogModel>('offline_logs');


  final prefs = await SharedPreferences.getInstance();
  
  // HAPUS BARIS INI UNTUK PRODUKSI
  // await prefs.setBool('onboarding_completed', false);

  final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(
    MaterialApp(
      home: onboardingCompleted ? const LoginView() : const OnboardingPage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}