import 'dart:async';
import 'package:flutter_application_1/features/auth/user_data.dart'; // Import the new user data file

class LoginController {
  // The hardcoded user map has been moved to user_data.dart

  int _loginAttempts = 0;
  bool _isLockedOut = false;

  // Getter untuk View bisa tahu status lockout
  bool get isLockedOut => _isLockedOut;

  // Fungsi pengecekan (Logic-Only)
  // Menggunakan Future<String> untuk memberikan pesan hasil yang lebih deskriptif
  Future<String> login(String username, String password) async {
    if (_isLockedOut) {
      return "Anda telah salah 3 kali. Coba lagi nanti.";
    }

    if (username.isEmpty || password.isEmpty) {
      return "Username dan Password tidak boleh kosong.";
    }

    // Use the imported map
    if (hardcodedUsers.containsKey(username) && hardcodedUsers[username] == password) {
      _loginAttempts = 0; // Reset jika berhasil
      return "success";
    } else {
      _loginAttempts++;
      if (_loginAttempts >= 3) {
        _isLockedOut = true;
        // Setelah 10 detik, reset status lockout dan percobaan
        Timer(const Duration(seconds: 10), () {
          _isLockedOut = false;
          _loginAttempts = 0;
          // Di aplikasi nyata, Anda butuh state management untuk memberitahu UI
          // agar aktif kembali secara otomatis.
        });
        return "Anda telah salah 3 kali. Tombol dinonaktifkan selama 10 detik.";
      }
      return "Username atau Password salah.";
    }
  }
}

