class OnboardingController {
  int _step = 1;

  // Getter untuk mengambil nilai private
  int get step => _step;

  void increment() {
    if (_step <= 3) {
      _step += 1;
    }
  }

  void decrement() {
    if (_step > 1) {
      _step -= 1;
    }
  }

  // Cek apakah sudah harus login
  bool shouldNavigateToLogin() => _step > 3;
}