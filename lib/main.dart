import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/onboarding/onboarding_view.dart';
import 'package:flutter_application_1/features/auth/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Pastikan binding Flutter sudah siap sebelum menggunakan SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  
  // Dapatkan instance SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // HAPUS BARIS INI UNTUK PRODUKSI
  // Baris ini akan selalu menampilkan onboarding page untuk keperluan development
  await prefs.setBool('onboarding_completed', false);

  // Cek apakah onboarding sudah pernah selesai
  // Jika 'onboarding_completed' tidak ada, kembalikan false
  final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(
    MaterialApp(
      // Jika onboarding sudah selesai, langsung ke LoginView
      // Jika belum, tampilkan OnboardingPage
      home: onboardingCompleted ? const LoginView() : const OnboardingPage(),
      debugShowCheckedModeBanner: false, // Opsional: menghilangkan banner debug
    ),
  );
}