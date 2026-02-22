import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Untuk encode/decode JSON

class HistoryLog {
  final String message;
  final String time; // Mengubah dari TimeOfDay menjadi String untuk serialisasi
  final Color color;

  HistoryLog({required this.message, required this.time, required this.color});

  // Factory constructor untuk membuat objek HistoryLog dari JSON
  factory HistoryLog.fromJson(Map<String, dynamic> json) {
    return HistoryLog(
      message: json['message'] as String,
      time: json['time'] as String,
      color: Color(json['color'] as int), // Menyimpan warna sebagai int
    );
  }

  // Metode untuk mengubah objek HistoryLog menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'time': time,
      'color': color.value, // Menyimpan nilai integer dari Color
    };
  }
}

class CounterController {
  late SharedPreferences _prefs;
  String? _username; // Tambahkan username untuk identifikasi
  int _counter = 0;
  int _step = 1;
  final List<HistoryLog> _history = [];

  int get value => _counter;
  int get step => _step;
  List<HistoryLog> get history => _history;

  // Inisialisasi controller dan muat data berdasarkan username
  Future<void> init(String? username) async {
    _username = username ?? 'default_user'; // Gunakan username atau fallback
    _prefs = await SharedPreferences.getInstance();
    await _loadLastValue();
    await _loadHistory();
  }

  // Kunci SharedPreferences yang dinamis berdasarkan username
  String get _counterKey => 'last_counter_$_username';
  String get _historyKey => 'history_log_$_username';

  // Metode untuk memuat nilai counter terakhir
  Future<void> _loadLastValue() async {
    _counter = _prefs.getInt(_counterKey) ?? 0;
  }

  // Metode untuk menyimpan nilai counter saat ini
  Future<void> _saveLastValue() async {
    await _prefs.setInt(_counterKey, _counter);
  }

  // Metode untuk memuat riwayat aktivitas
  Future<void> _loadHistory() async {
    final List<String>? historyJsonList = _prefs.getStringList(_historyKey);
    if (historyJsonList != null) {
      _history.clear();
      for (String jsonString in historyJsonList) {
        _history.add(HistoryLog.fromJson(json.decode(jsonString)));
      }
    }
  }

  // Metode untuk menyimpan riwayat aktivitas
  Future<void> _saveHistory() async {
    final List<String> historyJsonList =
        _history.map((log) => json.encode(log.toJson())).toList();
    await _prefs.setStringList(_historyKey, historyJsonList);
  }

  void increment() {
    _counter += _step;
    _saveLastValue();
    String formattedTime = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    addHistory("User $_username menambah +$_step pada jam $formattedTime");
  }

  void decrement() {
    if (_counter >= _step) {
      _counter -= _step;
    } else {
      _counter = 0;
    }
    _saveLastValue();
    String formattedTime = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    addHistory("User $_username mengurangi -$_step pada jam $formattedTime");
  }

  void setStep(int newStep) {
    _step = newStep;
    addHistory("User $_username menggeser slider ke $newStep");
  }

  void reset() {
    _counter = 0;
    _step = 1;
    _saveLastValue();
    _history.clear(); // Hapus juga riwayat di memori
    _saveHistory(); // Simpan riwayat yang sudah kosong
    String formattedTime = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    addHistory("User $_username mereset counter pada jam $formattedTime");
  }

  void addHistory(String message) {
    if (_history.length >= 10) {
      _history.removeAt(0);
    }

    Color logColor = Colors.black87;
    if (message.contains('menambah')) {
      logColor = Colors.green[700] ?? Colors.green;
    } else if (message.contains('mengurangi') || message.contains('mereset')) {
      logColor = Colors.red[700] ?? Colors.red;
    }
    String formattedTime = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    _history.add(
      HistoryLog(
        message: message,
        time: formattedTime,
        color: logColor,
      ),
    );
    _saveHistory();
  }
}