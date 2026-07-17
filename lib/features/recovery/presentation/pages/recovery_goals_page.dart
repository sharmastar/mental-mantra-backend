import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/recovery_provider.dart';
import '../../data/models/recovery_models.dart';

class RecoveryGoalsPage extends ConsumerStatefulWidget {
  const RecoveryGoalsPage({super.key});

  @override
  ConsumerState<RecoveryGoalsPage> createState() => _RecoveryGoalsPageState();
}

class _RecoveryGoalsPageState extends ConsumerState<RecoveryGoalsPage> {
  RecoveryTargetType _selectedTarget = RecoveryTargetType.abstinenceDays;
  int _targetValue = 7;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _goalTypes = [
    {
      'type': RecoveryTargetType.abstinenceDays,
      'label': 'Stay Clean',
      'subtitle': 'Days without the habit',
      'icon': Icons.calendar_today,
      'color': AppTheme.successColor,
      'unit': 'days',
      'presets': [3, 7, 14, 21, 30, 60, 90]
    },
    {
      'type': RecoveryTargetType.screenTime,
      'label': 'Screen Time Limit',
      'subtitle': 'Max screen time per day',
      'icon': Icons.phone_android,
      'color': const Color(0xFFFF6B9D),
      'unit': 'min',
      'presets': [30, 60, 90, 120, 180]
    },
    {
      'type': RecoveryTargetType.gamingHours,
      'label': 'Gaming Limit',
      'subtitle': 'Max gaming hours per day',
      'icon': Icons.sports_esports,
      'color': const Color(0xFFFFB547),
      'unit': 'hrs',
      'presets': [1, 2, 3, 4]
    },
    {
      'type': RecoveryTargetType.appUsage,
      'label': 'Reduce App Usage',
      'subtitle': 'Reduce non-essential app time',
      'icon': Icons.apps,
      'color': const Color(0xFF4FC3F7),
      'unit': 'min',
      'presets': [15, 30, 45, 60]
    },
    {
      'type': RecoveryTargetType.detoxSessions,
      'label': 'Detox Sessions',
      'subtitle': 'Complete detox sessions per week',
      'icon': Icons.timer,
      'color': AppTheme.primaryColor,
      'unit': 'sessions',
      'presets': [3, 5, 7, 10, 14]
    },
  ];

  Map<String, dynamic> get _currentGoalType =>
      _goalTypes.firstWhere((g) => g['type'] == _selectedTarget);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Recovery Goals')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What do you want to achieve?',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._goalTypes.map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: _selectedTarget == g['type']
                        ? (g['color'] as Color).withValues(alpha: 0.1)
                        : (isDark ? AppTheme.darkCard : AppTheme.lightCard),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() {
                        _selectedTarget = g['type'] as RecoveryTargetType;
                        _targetValue = (g['presets'] as List<int>).first;
                      }),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: _selectedTarget == g['type']
                              ? Border.all(color: g['color'] as Color, width: 2)
                              : null,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(g['icon'] as IconData,
                                color: g['color'] as Color, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(g['label'] as String,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  Text(g['subtitle'] as String,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            if (_selectedTarget == g['type'])
                              Icon(Icons.check_circle,
                                  color: g['color'] as Color),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 24),
            Text('Set your target',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (_currentGoalType['presets'] as List<int>)
                  .map((v) => ChoiceChip(
                        label: Text('$v ${_currentGoalType['unit']}'),
                        selected: _targetValue == v,
                        onSelected: (_) => setState(() => _targetValue = v),
                        selectedColor: (_currentGoalType['color'] as Color)
                            .withValues(alpha: 0.2),
                      ))
                  .toList(),
            ),
            if (_selectedTarget == RecoveryTargetType.abstinenceDays) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('$_targetValue days',
                          style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.successColor)),
                      const SizedBox(height: 4),
                      const Text('without the habit',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveGoal,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.flag),
                label: Text(_isSaving ? 'Saving...' : 'Set Goal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentGoalType['color'] as Color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveGoal() async {
    setState(() => _isSaving = true);
    final goal = RecoveryGoal(
      targetType: _selectedTarget,
      targetValue: _targetValue,
      startDate: DateTime.now(),
    );
    final success = await ref.read(recoveryProvider.notifier).setGoal(goal);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Goal set: ${_currentGoalType['label']} $_targetValue ${_currentGoalType['unit']}'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      context.pop();
    }
  }
}
