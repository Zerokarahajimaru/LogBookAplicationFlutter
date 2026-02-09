class CounterController {
  int _counter = 0;
  int _step = 1;
  List<String> _history = [];
  List<DateTime> _time_history = [];

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

  void history(Object input){
    _history.add(input.toString());
    _time_history.add(DateTime.now());
  }
}
