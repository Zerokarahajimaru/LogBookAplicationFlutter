class CounterController {
  int _counter = 0;
  int _step = 1;

  int get value => _counter;
  int get step => _step;

  void increment() => _counter += _step;

  void setStep(int newStep) => _step = newStep;

  void decrement() {
    if (_counter > 0) _counter -= _step;
  }

  void reset() {
    _counter = 0;
    _step = 1;
  }
}
