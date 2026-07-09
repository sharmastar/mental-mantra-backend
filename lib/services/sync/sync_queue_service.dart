import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_mantra/core/config/app_config.dart';
import 'package:mental_mantra/core/utils/connectivity.dart';

class SyncQueueItem {
  final String id;
  final String collection;
  final String docId;
  final String action;
  final Map<String, dynamic>? data;
  final String timestamp;

  SyncQueueItem({
    required this.id,
    required this.collection,
    required this.docId,
    required this.action,
    this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'collection': collection,
        'docId': docId,
        'action': action,
        if (data != null) 'data': data,
        'timestamp': timestamp,
      };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) => SyncQueueItem(
        id: json['id'] as String,
        collection: json['collection'] as String,
        docId: json['docId'] as String,
        action: json['action'] as String,
        data: json['data'] != null ? Map<String, dynamic>.from(json['data'] as Map) : null,
        timestamp: json['timestamp'] as String,
      );
}

class SyncState {
  final int pendingCount;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final String statusMessage;
  final List<String> syncLog;

  const SyncState({
    this.pendingCount = 0,
    this.isSyncing = false,
    this.lastSyncTime,
    this.statusMessage = 'Cloud Backup is up to date.',
    this.syncLog = const [],
  });

  SyncState copyWith({
    int? pendingCount,
    bool? isSyncing,
    DateTime? lastSyncTime,
    String? statusMessage,
    List<String>? syncLog,
  }) {
    return SyncState(
      pendingCount: pendingCount ?? this.pendingCount,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      statusMessage: statusMessage ?? this.statusMessage,
      syncLog: syncLog ?? this.syncLog,
    );
  }
}

class SyncQueueNotifier extends StateNotifier<SyncState> {
  static const String _queueKey = 'sys_sync_queue';
  static const String _lastSyncKey = 'sys_last_sync_time';
  static const String _logKey = 'sys_sync_log';

  SyncQueueNotifier() : super(const SyncState()) {
    _loadState();
  }

  void _loadState() {
    try {
      final prefs = AppConfig.prefs;
      final queueStrings = prefs.getStringList(_queueKey) ?? [];
      final lastSyncMs = prefs.getInt(_lastSyncKey);
      final logStrings = prefs.getStringList(_logKey) ?? [];

      state = SyncState(
        pendingCount: queueStrings.length,
        isSyncing: false,
        lastSyncTime: lastSyncMs != null ? DateTime.fromMillisecondsSinceEpoch(lastSyncMs) : null,
        statusMessage: queueStrings.isEmpty
            ? 'Cloud Backup is up to date.'
            : 'You have ${queueStrings.length} changes pending backup.',
        syncLog: logStrings,
      );
    } catch (e) {
      debugPrint('[SyncService] Failed to load sync state: $e');
    }
  }

  List<SyncQueueItem> _getQueueItems() {
    final prefs = AppConfig.prefs;
    final queueStrings = prefs.getStringList(_queueKey) ?? [];
    return queueStrings.map((s) => SyncQueueItem.fromJson(jsonDecode(s) as Map<String, dynamic>)).toList();
  }

  Future<void> _saveQueueItems(List<SyncQueueItem> items) async {
    final prefs = AppConfig.prefs;
    final strings = items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_queueKey, strings);
  }

  Future<void> addToQueue({
    required String collection,
    required String docId,
    required String action,
    Map<String, dynamic>? data,
  }) async {
    try {
      final items = _getQueueItems();
      final newItem = SyncQueueItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        collection: collection,
        docId: docId,
        action: action,
        data: data,
        timestamp: DateTime.now().toIso8601String(),
      );

      // Check if we already have a pending update for this doc to merge or overwrite
      items.removeWhere((item) => item.collection == collection && item.docId == docId);
      items.add(newItem);

      await _saveQueueItems(items);
      state = state.copyWith(
        pendingCount: items.length,
        statusMessage: 'You have ${items.length} changes pending backup.',
      );
      debugPrint('[SyncService] Queued sync action: $action on $collection/$docId');
    } catch (e) {
      debugPrint('[SyncService] Error adding to sync queue: $e');
    }
  }

  Future<void> processQueue() async {
    if (state.isSyncing) return;

    state = state.copyWith(
      isSyncing: true,
      statusMessage: 'Connecting to Cloud Backup Service...',
    );

    // Simulate network delay and check connectivity
    await Future.delayed(const Duration(milliseconds: 1200));
    final isOnline = await ConnectivityUtil.hasInternet();

    if (!isOnline) {
      state = state.copyWith(
        isSyncing: false,
        statusMessage: 'Backup failed: No internet connection.',
      );
      _logEvent('Backup failed: Device is offline.');
      return;
    }

    try {
      final items = _getQueueItems();
      if (items.isEmpty) {
        state = state.copyWith(
          isSyncing: false,
          lastSyncTime: DateTime.now(),
          statusMessage: 'Cloud Backup is up to date.',
        );
        return;
      }

      // Simulate uploading each item to Cloud Firestore
      for (final item in items) {
        debugPrint('[SyncService] Uploading ${item.action} of ${item.collection}/${item.docId} to Firestore...');
        await Future.delayed(const Duration(milliseconds: 150));
      }

      final prefs = AppConfig.prefs;
      final completedCount = items.length;

      // Clear the queue
      await prefs.setStringList(_queueKey, []);
      final now = DateTime.now();
      await prefs.setInt(_lastSyncKey, now.millisecondsSinceEpoch);

      _logEvent('Successfully backed up $completedCount pending record(s) to Firestore.');

      state = state.copyWith(
        pendingCount: 0,
        isSyncing: false,
        lastSyncTime: now,
        statusMessage: 'Backup completed successfully.',
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        statusMessage: 'Backup failed: $e',
      );
      _logEvent('Backup error: $e');
    }
  }

  Future<void> clearLogs() async {
    final prefs = AppConfig.prefs;
    await prefs.setStringList(_logKey, []);
    state = state.copyWith(syncLog: []);
  }

  void _logEvent(String event) {
    try {
      final prefs = AppConfig.prefs;
      final logs = prefs.getStringList(_logKey) ?? [];
      final timestamp = DateTime.now().toLocal().toString().substring(0, 19);
      logs.insert(0, '[$timestamp] $event');

      // Keep only last 100 entries
      if (logs.length > 100) {
        logs.removeRange(100, logs.length);
      }

      prefs.setStringList(_logKey, logs);
      state = state.copyWith(syncLog: logs);
    } catch (e) {
      debugPrint('[SyncService] Failed to log sync event: $e');
    }
  }
}

final syncQueueProvider = StateNotifierProvider<SyncQueueNotifier, SyncState>((ref) {
  return SyncQueueNotifier();
});
