import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mental_mantra/core/config/app_config.dart';
import 'package:mental_mantra/services/sync/sync_queue_service.dart';
import 'package:mental_mantra/core/utils/connectivity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncQueueService Unit Tests', () {
    late SyncQueueNotifier notifier;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      ConnectivityUtil.overrideHasInternet = true;
      // Re-initialize AppConfig to fetch the mocked SharedPreferences
      await AppConfig.init();
      notifier = SyncQueueNotifier();
    });

    test('initial state has correct default values', () {
      expect(notifier.state.pendingCount, 0);
      expect(notifier.state.isSyncing, isFalse);
      expect(notifier.state.lastSyncTime, isNull);
      expect(notifier.state.syncLog, isEmpty);
    });

    test('addToQueue adds new items and increases pendingCount', () async {
      await notifier.addToQueue(
        collection: 'journals',
        docId: 'doc_123',
        action: 'SET',
        data: {'title': 'Feeling Grounded', 'content': 'Meditation helped.'},
      );

      expect(notifier.state.pendingCount, 1);
      expect(
          notifier.state.statusMessage, contains('1 changes pending backup'));
    });

    test(
        'addToQueue overwrites previous pending item for same collection/docId',
        () async {
      await notifier.addToQueue(
        collection: 'journals',
        docId: 'doc_123',
        action: 'SET',
        data: {'title': 'First Draft'},
      );
      await notifier.addToQueue(
        collection: 'journals',
        docId: 'doc_123',
        action: 'UPDATE',
        data: {'title': 'Final Version'},
      );

      expect(notifier.state.pendingCount, 1);
    });

    test('processQueue simulates backup and clears queue', () async {
      await notifier.addToQueue(
        collection: 'moods',
        docId: 'mood_today',
        action: 'SET',
        data: {'mood': 5},
      );

      expect(notifier.state.pendingCount, 1);

      // Process the queue
      await notifier.processQueue();

      expect(notifier.state.pendingCount, 0);
      expect(notifier.state.isSyncing, isFalse);
      expect(notifier.state.lastSyncTime, isNotNull);
      expect(notifier.state.syncLog, isNotEmpty);
      expect(notifier.state.syncLog.first, contains('Successfully backed up'));
    });

    test('clearLogs clears sync activity log history', () async {
      await notifier.addToQueue(
        collection: 'habits',
        docId: 'habit_today',
        action: 'UPDATE',
        data: {'completed': true},
      );
      await notifier.processQueue();

      expect(notifier.state.syncLog, isNotEmpty);

      await notifier.clearLogs();
      expect(notifier.state.syncLog, isEmpty);
    });
  });
}
