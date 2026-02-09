import 'package:flutter/material.dart';

class CounterController {
  int _counter = 0;
  int _step = 1;
  List<String> _history = [];
  List<TimeOfDay> _time_history = [];

  int get value => _counter;
  int get step => _step;
  List<String> get history_private_var => _history;
  List<TimeOfDay> get time_history_private_var => _time_history;

  void increment() => _counter += _step;

  void setStep(int newStep) => _step = newStep;


  void decrement() {
    if (_counter > 0) _counter -= _step;
  }

  void reset() {
    _counter = 0;
    _step = 1;
  }

  void history(String message){

    if(_history.length>=5 && _time_history.length>=5){
      _history.removeAt(0);
      _time_history.removeAt(0);
    }

    _history.add(message);
    _time_history.add(TimeOfDay.now());
  }

}
