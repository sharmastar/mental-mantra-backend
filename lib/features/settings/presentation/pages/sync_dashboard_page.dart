import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/sync/sync_queue_service.dart';

class SyncDashboardPage extends ConsumerWidget {
  const SyncDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncQueueProvider);
    final syncNotifier = ref.read(syncQueueProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : Colors.black87, size: 18),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.cloud_done_outlined,
                            color: Colors.white, size: 36),
                        const SizedBox(height: 8),
                        const Text(
                          'Cloud Backup',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Keep your mental wellness plan synced safely',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSyncStatusCard(context, syncState, isDark),
                const SizedBox(height: 20),
                _buildActionsCard(context, syncState, syncNotifier, isDark),
                const SizedBox(height: 20),
                _buildConflictResolutionInfo(context, isDark),
                const SizedBox(height: 20),
                _buildBackupLogsCard(context, syncState, syncNotifier, isDark),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatusCard(
      BuildContext context, SyncState state, bool isDark) {
    final hasPending = state.pendingCount > 0;
    final lastSyncText = state.lastSyncTime != null
        ? 'Last synced: ${state.lastSyncTime!.toLocal().toString().substring(0, 16)}'
        : 'Never synced with cloud yet';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulse Animation Ring
                if (state.isSyncing)
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                          width: 3),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.4, 1.4),
                        curve: Curves.easeOut,
                        duration: 1200.ms,
                      )
                      .fadeOut(duration: 1200.ms)
                else
                  const SizedBox(width: 90, height: 90),

                // Main Status Icon
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state.isSyncing
                        ? AppTheme.secondaryColor.withValues(alpha: 0.1)
                        : (hasPending
                            ? AppTheme.warningColor.withValues(alpha: 0.1)
                            : AppTheme.primaryColor.withValues(alpha: 0.1)),
                  ),
                  child: Icon(
                    state.isSyncing
                        ? Icons.sync
                        : (hasPending ? Icons.sync_problem : Icons.cloud_done),
                    color: state.isSyncing
                        ? AppTheme.secondaryColor
                        : (hasPending
                            ? AppTheme.warningColor
                            : AppTheme.primaryColor),
                    size: 36,
                  ),
                )
                    .animate(
                      target: state.isSyncing ? 1 : 0,
                      onPlay: (c) => state.isSyncing ? c.repeat() : c.stop(),
                    )
                    .rotate(duration: 2000.ms, curve: Curves.linear),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            state.isSyncing
                ? 'Backing up to Firestore...'
                : (hasPending ? 'Pending Sync Tasks' : 'All Data Backed Up'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            state.statusMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time_rounded,
                  size: 14, color: isDark ? Colors.white38 : Colors.black38),
              const SizedBox(width: 6),
              Text(
                lastSyncText,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, SyncState state,
      SyncQueueNotifier notifier, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed:
                      state.isSyncing ? null : () => notifier.processQueue(),
                  icon: state.isSyncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.backup_outlined),
                  label: Text(state.isSyncing ? 'Syncing...' : 'Backup Now'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
          if (state.pendingCount > 0) ...[
            const SizedBox(height: 12),
            Text(
              'Perform a manual backup to push your local modifications straight to your Firestore account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConflictResolutionInfo(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.secondaryColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppTheme.secondaryColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conflict Resolution: Last-Write-Wins',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mental Mantra uses timestamp-based conflict resolution. If you modify a journal or mood log on multiple devices while offline, the newest timestamp always wins automatically when synced.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupLogsCard(BuildContext context, SyncState state,
      SyncQueueNotifier notifier, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Backup Activity Logs',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.primaryDark,
                ),
              ),
              if (state.syncLog.isNotEmpty)
                TextButton(
                  onPressed: () => notifier.clearLogs(),
                  child: const Text('Clear',
                      style:
                          TextStyle(color: AppTheme.errorColor, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.syncLog.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No recent sync activity.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.syncLog.length,
              separatorBuilder: (_, __) => const Divider(height: 12),
              itemBuilder: (ctx, i) {
                final log = state.syncLog[i];
                return Text(
                  log,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Consolas',
                    color: isDark ? Colors.white54 : Colors.black87,
                    height: 1.3,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
