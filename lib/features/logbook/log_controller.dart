import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/mongo_service.dart';
import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import 'models/log_model.dart';

class LogController {
  final Box<LogModel> _logBox = Hive.box<LogModel>('offline_logs');
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  final ValueNotifier<List<LogModel>> filteredLogsNotifier = ValueNotifier([]);
  final ValueNotifier<String> selectedCategoryNotifier = ValueNotifier('Semua');
  String _currentQuery = '';

  final MongoService _mongoService = MongoService();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  LogController() {
    // Listen for connectivity changes to trigger auto-sync
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      final bool isOnline = result != ConnectivityResult.none;
      if (isOnline) {
        // ignore: avoid_print
        print("Device is online, attempting to sync unsynced logs...");
        syncUnsyncedLogs();
      }
    });
  }

  void setCategoryFilter(String category) {
    selectedCategoryNotifier.value = category;
    _updateFilteredLogs();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Syncs all local-only logs to the cloud.
  Future<void> syncUnsyncedLogs() async {
    final unsyncedLogs = _logBox.values.where((log) => !log.isSynced).toList();
    if (unsyncedLogs.isEmpty) {
      // ignore: avoid_print
      print("No unsynced logs to sync.");
      return;
    }
    // ignore: avoid_print
    print("Found ${unsyncedLogs.length} unsynced logs. Syncing now...");

    // For background sync, we might not have the user context.
    // A robust solution would involve secure session storage.
    // For now, we use a system-level user with elevated privileges for syncing.
    final systemUser = {'role': 'ketua', 'uid': 'system_sync', 'teamId': ''};

    for (var log in unsyncedLogs) {
      try {
        await _mongoService.upsertLog(log, currentUser: systemUser);
        final updatedLog = LogModel(
            id: log.id, title: log.title, description: log.description,
            date: log.date, authorId: log.authorId, teamId: log.teamId,
            isPublic: log.isPublic, category: log.category, isSynced: true);
        
        final key = _logBox.keyAt(_logBox.values.toList().indexOf(log));
        await _logBox.put(key, updatedLog);
      } catch (e) {
        // ignore: avoid_print
        print("Syncing log ${log.title} failed: $e");
      }
    }
    // Refresh the UI after syncing
    if (logsNotifier.value.isNotEmpty) {
      _updateNotifiers(logsNotifier.value.first.teamId);
    }
  }

  /// Initial load strategy: fast load from Hive, then sync with Cloud.
  Future<void> loadLogs(String teamId) async {
    // 1. Instant load from local Hive cache
    logsNotifier.value = _logBox.values.where((log) => log.teamId == teamId).toList();
    _updateFilteredLogs();

    // 2. Background sync from Cloud
    try {
      final cloudLogsMap = await _mongoService.getLogs(teamId);
      final cloudLogs = cloudLogsMap.map((map) => LogModel.fromMap(map)).toList();
      
      // A simple sync strategy: clear local and replace with cloud data
      await _logBox.clear();
      await _logBox.addAll(cloudLogs);

      // Update UI with fresh data from cloud
      logsNotifier.value = _logBox.values.where((log) => log.teamId == teamId).toList();
      _updateFilteredLogs();
    } catch (e) {
      // ignore: avoid_print
      print("Could not sync from cloud, using local data. Error: $e");
    }
  }

  void searchLog(String query) {
    _currentQuery = query;
    _updateFilteredLogs();
  }

void _updateFilteredLogs() {
    final allLogs = logsNotifier.value;
    final category = selectedCategoryNotifier.value;

    filteredLogsNotifier.value = allLogs.where((log) {
      final matchesSearch = log.title.toLowerCase().contains(_currentQuery.toLowerCase()) ||
                            log.description.toLowerCase().contains(_currentQuery.toLowerCase());
      
      final matchesCategory = (category == 'Semua') || (log.category == category);

      return matchesSearch && matchesCategory;
    }).toList();
  }

  /// Offline-First Add: Save to Hive instantly, then try to sync.
  Future<void> addLog({ required String title, required String desc, required String authorId, required String teamId, required String category, required Map<String, dynamic> currentUser }) async {
    final newLog = LogModel(
      id: ObjectId().oid, title: title, description: desc,
      date: DateTime.now().toIso8601String(), authorId: authorId,
      teamId: teamId, category: category, isPublic: false, isSynced: false
    );

    await _logBox.add(newLog);
    _updateNotifiers(teamId);

    // Try to sync in the background
    try {
      await _mongoService.upsertLog(newLog, currentUser: currentUser);
      final syncedLog = LogModel(
          id: newLog.id, title: title, description: desc, date: newLog.date,
          authorId: authorId, teamId: teamId, category: category,
          isPublic: newLog.isPublic, isSynced: true);
      
      final key = _logBox.keyAt(_logBox.values.toList().indexOf(newLog));
      await _logBox.put(key, syncedLog);
      _updateNotifiers(teamId);
    } catch (e) {
      // ignore: avoid_print
      print("Add log sync failed, will retry later. Error: $e");
    }
  }

  Future<void> updateLog({ required int index, required String title, required String desc, required String category, required String teamId, required Map<String, dynamic> currentUser }) async {
    final logToUpdate = filteredLogsNotifier.value[index];
    final updatedLog = LogModel(
        id: logToUpdate.id, title: title, description: desc,
        date: logToUpdate.date, authorId: logToUpdate.authorId,
        teamId: logToUpdate.teamId, category: category,
        isPublic: logToUpdate.isPublic, isSynced: false);

    final key = _logBox.keyAt(_logBox.values.toList().indexOf(logToUpdate));
    await _logBox.put(key, updatedLog);
    _updateNotifiers(teamId);

    try {
      await _mongoService.upsertLog(updatedLog, currentUser: currentUser);
      final syncedLog = LogModel(
          id: updatedLog.id, title: title, description: desc,
          date: updatedLog.date, authorId: updatedLog.authorId,
          teamId: teamId, category: category,
          isPublic: updatedLog.isPublic, isSynced: true);
      await _logBox.put(key, syncedLog);
      _updateNotifiers(teamId);
    } catch (e) {
      // ignore: avoid_print
      print("Update log sync failed, will retry later. Error: $e");
      rethrow;
    }
  }

  Future<void> removeLog({required int index, required String teamId, required Map<String, dynamic> currentUser}) async {
    final logToRemove = filteredLogsNotifier.value[index];
    
    try {
      // First, try to delete from the remote database
      await _mongoService.deleteLog(logToRemove, currentUser: currentUser);
      
      // If remote deletion is successful, delete from the local cache
      final key = _logBox.keyAt(_logBox.values.toList().indexOf(logToRemove));
      await _logBox.delete(key);
      _updateNotifiers(teamId);

    } catch (e) {
      // ignore: avoid_print
      print("Delete log sync failed. Error: $e");
      // Re-throw the error to be caught by the UI and displayed in the SnackBar
      rethrow;
    }
  }
  
  void _updateNotifiers(String teamId) {
     logsNotifier.value = _logBox.values.where((log) => log.teamId == teamId).toList();
     _updateFilteredLogs();
  }
}