import 'dart:async';
import 'package:flutter_application_1/services/mongo_service.dart';

class LoginController {
  final MongoService _mongoService = MongoService();
  int _loginAttempts = 0;
  bool _isLockedOut = false;
  Timer? _lockoutTimer;

  bool get isLockedOut => _isLockedOut;
  String? errorMessage;

  Future<Map<String, dynamic>?> login(String username, String password) async {
    if (_isLockedOut) {
      errorMessage = "Anda telah salah 3 kali. Coba lagi nanti.";
      return null;
    }

    if (username.isEmpty || password.isEmpty) {
      errorMessage = "Username dan Password tidak boleh kosong.";
      return null;
    }

    try {
      final bool isPasswordCorrect = await _mongoService.verifyPassword(username, password);

      if (isPasswordCorrect) {
        _loginAttempts = 0;
        errorMessage = null;

        final user = await _mongoService.getUserByUid(username);
        if (user != null) {
          // Transform UserModel to the Map structure expected by the UI
          return {
            'uid': user.uid,
            'username': user.uid, // Assuming uid is the username
            'role': user.role,
            'teamId': user.teamId,
          };
        } else {
          // This case is unlikely if verifyPassword passed, but good to handle
          errorMessage = "Gagal mengambil data pengguna setelah login.";
          return null;
        }
      } else {
        _handleFailedLoginAttempt();
        return null;
      }
    } catch (e) {
      errorMessage = "Terjadi kesalahan: $e";
      return null;
    }
  }

  void _handleFailedLoginAttempt() {
    _loginAttempts++;
    if (_loginAttempts >= 3) {
      _isLockedOut = true;
      _lockoutTimer?.cancel(); // Cancel any existing timer
      _lockoutTimer = Timer(const Duration(seconds: 10), () {
        _isLockedOut = false;
        _loginAttempts = 0;
      });
      errorMessage = "Anda telah salah 3 kali. Tombol dinonaktifkan selama 10 detik.";
    } else {
      errorMessage = "Username atau Password salah. (${3 - _loginAttempts}x percobaan tersisa)";
    }
  }

  void dispose() {
    _lockoutTimer?.cancel();
  }
}

