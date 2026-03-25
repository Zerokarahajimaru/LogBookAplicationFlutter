import 'dart:developer' as dev;
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LogHelper {
  static Future<void> writeLog(
    String message, {
    String source = "Unknown",
    int level = 2,
  }) async {
    // 1. Filter Konfigurasi (ENV)
    final int configLevel = int.tryParse(dotenv.env['LOG_LEVEL'] ?? '2') ?? 2;
    final String muteList = dotenv.env['LOG_MUTE'] ?? '';

    if (level > configLevel) return;
    if (muteList.split(',').contains(source)) return;

    try {
      // 2. Format Waktu dan Label
      final now = DateTime.now();
      String timestamp = DateFormat('HH:mm:ss').format(now);
      String label = _getLabel(level);
      
      // 3. Output ke VS Code Debug Console
      dev.log(message, name: source, time: now, level: level * 100);

      // 4. Output ke Terminal
      String color = _getColor(level);
      print('$color[$timestamp][$label][$source] -> $message\x1B[0m');

      // 5. Output ke File (HOTS Requirement)
      _logToFile(now, label, source, message);

    } catch (e) {
      dev.log("Logging failed: $e", name: "SYSTEM", level: 1000);
    }
  }

  static Future<void> _logToFile(DateTime now, String label, String source, String message) async {
    try {
      final logDir = Directory(p.join(Directory.current.path, 'logs'));
      if (!await logDir.exists()) {
        await logDir.create();
      }

      final fileName = DateFormat('dd-MM-yyyy').format(now) + '.log';
      final logFile = File(p.join(logDir.path, fileName));
      
      final logString = '[${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}] [$label] [$source] -> $message\n';

      await logFile.writeAsString(logString, mode: FileMode.append);

    } catch (e) {
      // If file logging fails, print an error to the console but don't crash.
      print('\x1B[31m[ERROR][LogHelper] -> Failed to write to log file: $e\x1B[0m');
    }
  }

  static String _getLabel(int level) {
    switch (level) {
      case 1:
        return "ERROR";
      case 2:
        return "INFO";
      case 3:
        return "VERBOSE";
      default:
        return "LOG";
    }
  }

  static String _getColor(int level) {
    switch (level) {
      case 1:
        return '\x1B[31m'; // Merah
      case 2:
        return '\x1B[32m'; // Hijau
      case 3:
        return '\x1B[34m'; // Biru
      default:
        return '\x1B[0m';
    }
  }
}
