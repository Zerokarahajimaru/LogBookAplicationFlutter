import 'package:flutter/material.dart';

class CounterController {
  int _counter = 0;
  int _step = 1;
  final List<String> _history = [];
  final List<TimeOfDay> _time_history = [];
  final List<Color> _color_history = []; 

  int get value => _counter;
  int get step => _step;
  List<String> get history_private_var => _history;
  List<TimeOfDay> get time_history_private_var => _time_history;
  List<Color> get color_history_private_var => _color_history; 

  void increment() => _counter += _step;
  
  void decrement() { 
    if (_counter >= _step) {
      _counter -= _step; 
    } else {
      _counter = 0;
    }
  }

  void setStep(int newStep) => _step = newStep;

  void reset() {
    _counter = 0;
    _step = 1;
  }

  void history(String message) {
    if (_history.length >= 5) {
      _history.removeAt(0);
      _time_history.removeAt(0);
      _color_history.removeAt(0); 
    }

    Color logColor = Colors.black87;

    if (message.contains('+')) {
      logColor = Colors.green[700]!;
    } else if (message.contains('-') || message.contains('reset')) {
      logColor = Colors.red[700]!;
    }

    _history.add(message);
    _time_history.add(TimeOfDay.now());
    _color_history.add(logColor); 
  }
}