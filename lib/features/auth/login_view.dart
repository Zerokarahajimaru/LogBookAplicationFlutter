// login_view.dart
import 'package:flutter/material.dart';
// Import Controller milik sendiri (masih satu folder)
import 'package:flutter_application_1/features/auth/login_controller.dart';
// Import View dari fitur lain (Logbook) untuk navigasi
import 'package:flutter_application_1/features/logbook/counter_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Inisialisasi Otak dan Controller Input
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _isPasswordVisible = false; // State untuk visibilitas password

  Future<void> _handleLogin() async { // Ubah menjadi async
    String user = _userController.text;
    String pass = _passController.text;

    // Panggil fungsi login yang sudah diupdate
    String loginResult = await _controller.login(user, pass);

    setState(() {
      // Memastikan UI diperbarui, terutama untuk status lockout
    });

    if (loginResult == "success") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // Di sini kita kirimkan variabel 'user' ke parameter 'username' di CounterView
          builder: (context) => CounterView(username: user),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loginResult)), // Tampilkan pesan dari controller
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Gatekeeper")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passController,
              obscureText: !_isPasswordVisible, // Kontrol visibilitas
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _controller.isLockedOut ? null : _handleLogin, // Nonaktifkan jika lockout
              child: const Text("Masuk"),
            ),
          ],
        ),
      ),
    );
  }
}
