import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/login_view.dart';
import 'package:flutter_application_1/features/onboarding/onboarding_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final OnboardingController _controller = OnboardingController();

  void handleNext() async {
    if (_controller.step > 2) {
      // Tandai bahwa onboarding telah selesai
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);

      // Navigasi ke halaman login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
        );
      }
    } else {
      setState(() {
        _controller.increment();
      });
    }
  }

  void handleBack() {
    if (_controller.step > 1) {
      setState(() {
        _controller.decrement();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text("Step ${_controller.step} of 3"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _buildBodyContent(_controller.step),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_controller.step > 1)
                    TextButton(
                      onPressed: handleBack,
                      child: const Text("Back"),
                    ),
                  if (_controller.step > 1) const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    onPressed: handleNext,
                    child: Text(_controller.step > 2 ? "Get Started" : "Next"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent(int step) {
    return switch (step) {
      1 =>
        const StepView(
            text: "Selamat Datang!",
            imagePath: "assets/images/f1.png"),
      2 =>
        const StepView(
            text: "Keamanan Terjamin",
            imagePath: "assets/images/f2.png"),
      3 =>
        const StepView(
            text: "Mulai Sekarang",
            imagePath: "assets/images/f3.png"),
      _ => const SizedBox(),
    };
  }
}

class StepView extends StatelessWidget {
  final String text;
  final String imagePath;
  const StepView({super.key, required this.text, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(imagePath, height: 300), // Sesuaikan ukuran gambar
        const SizedBox(height: 30),
        Text(text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}