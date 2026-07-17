import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_mantra/core/config/app_config.dart';
import 'package:mental_mantra/core/utils/connectivity.dart';
import 'package:mental_mantra/core/network/api_client.dart';
import 'package:mental_mantra/core/errors/app_exceptions.dart';


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
        data: json['data'] != null
            ? Map<String, dynamic>.from(json['data'] as Map)
            : null,
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
        lastSyncTime: lastSyncMs != null
            ? DateTime.fromMillisecondsSinceEpoch(lastSyncMs)
            : null,
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
    return queueStrings
        .map((s) =>
            SyncQueueItem.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
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
      items.removeWhere(
          (item) => item.collection == collection && item.docId == docId);
      items.add(newItem);

      await _saveQueueItems(items);
      state = state.copyWith(
        pendingCount: items.length,
        statusMessage: 'You have ${items.length} changes pending backup.',
      );
      debugPrint(
          '[SyncService] Queued sync action: $action on $collection/$docId');
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

      final List<SyncQueueItem> succeededItems = [];
      for (final item in items) {
        debugPrint(
            '[SyncService] Syncing ${item.action} of ${item.collection}/${item.docId}...');
        
        try {
          if (item.collection == 'journals') {
            if (item.action == 'SET') {
              await ApiClient.post('/journal', data: item.data);
            } else if (item.action == 'UPDATE') {
              await ApiClient.put('/journal/${item.docId}', data: item.data);
            } else if (item.action == 'DELETE') {
              await ApiClient.delete('/journal/${item.docId}');
            }
          } else if (item.collection == 'moods') {
            if (item.action == 'SET') {
              await ApiClient.post('/mood', data: item.data);
            }
          } else if (item.collection == 'habits') {
            if (item.action == 'SET') {
              await ApiClient.post('/habits', data: item.data);
            } else if (item.action == 'LOG') {
              await ApiClient.post('/habits/${item.docId}/log');
            } else if (item.action == 'DELETE') {
              await ApiClient.delete('/habits/${item.docId}');
            }
          } else if (item.collection == 'goals') {
            if (item.action == 'SET') {
              await ApiClient.post('/goals', data: item.data);
            } else if (item.action == 'UPDATE') {
              await ApiClient.put('/goals/${item.docId}', data: item.data);
            } else if (item.action == 'DELETE') {
              await ApiClient.delete('/goals/${item.docId}');
            }
          } else if (item.collection == 'sleep') {
            if (item.action == 'SET') {
              await ApiClient.post('/sleep', data: item.data);
            } else if (item.action == 'DELETE') {
              await ApiClient.delete('/sleep/${item.docId}');
            }
          } else if (item.collection == 'fitness') {
            if (item.action == 'SET') {
              await ApiClient.post('/fitness', data: item.data);
            }
          } else if (item.collection == 'yoga') {
            if (item.action == 'SET') {
              await ApiClient.post('/yoga', data: item.data);
            }
          }
          
          succeededItems.add(item);
        } on AppException catch (ae) {
          // Conflict resolution: if it's a client validation error (4xx),
          // it cannot be resolved by retrying. Log it, discard item, and continue.
          if (ae.statusCode != null && ae.statusCode! >= 400 && ae.statusCode! < 500) {
            debugPrint('[SyncService] Discarding conflicting client request: $ae');
            succeededItems.add(item); // Treat as completed to clear from queue
            _logEvent('Conflict discarded: ${item.action} ${item.collection}/${item.docId} - ${ae.message}');
          } else {
            // Server error or connection issue - stop queue processing to retry later
            rethrow;
          }
        } catch (e) {
          // Other unexpected errors - stop queue processing
          rethrow;
        }
      }

      // Remove successfully completed items from the queue
      final remainingItems = items.where((i) => !succeededItems.contains(i)).toList();
      await _saveQueueItems(remainingItems);
      
      final prefs = AppConfig.prefs;
      final completedCount = succeededItems.length;
      final now = DateTime.now();
      await prefs.setInt(_lastSyncKey, now.millisecondsSinceEpoch);

      if (completedCount > 0) {
        _logEvent(
            'Successfully backed up $completedCount pending record(s) to server.');
      }

      state = state.copyWith(
        pendingCount: remainingItems.length,
        isSyncing: false,
        lastSyncTime: now,
        statusMessage: remainingItems.isEmpty
            ? 'Backup completed successfully.'
            : 'Backup partially completed. ${remainingItems.length} changes remaining.',
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

final syncQueueProvider =
    StateNotifierProvider<SyncQueueNotifier, SyncState>((ref) {
  return SyncQueueNotifier();
});
