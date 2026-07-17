import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/recovery_provider.dart';
import '../../data/models/recovery_models.dart';

class DetoxTimerPage extends ConsumerStatefulWidget {
  const DetoxTimerPage({super.key});

  @override
  ConsumerState<DetoxTimerPage> createState() => _DetoxTimerPageState();
}

class _DetoxTimerPageState extends ConsumerState<DetoxTimerPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  DetoxSessionType _selectedType = DetoxSessionType.digitalDetox;
  int _selectedMinutes = 25;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isCompleted = false;
  String? _sessionId;
  late AnimationController _pulseController;
  DateTime? _startTime;
  int _totalDurationSeconds = 0;

  final List<Map<String, dynamic>> _presets = [
    {'label': '5 min', 'minutes': 5},
    {'label': '15 min', 'minutes': 15},
    {'label': '25 min', 'minutes': 25},
    {'label': '45 min', 'minutes': 45},
    {'label': '60 min', 'minutes': 60},
  ];

  final List<Map<String, dynamic>> _sessionTypes = [
    {
      'type': DetoxSessionType.focus,
      'label': 'Deep Focus',
      'icon': Icons.track_changes,
      'color': AppTheme.primaryColor
    },
    {
      'type': DetoxSessionType.gamingBreak,
      'label': 'Gaming Break',
      'icon': Icons.sports_esports,
      'color': const Color(0xFFFFB547)
    },
    {
      'type': DetoxSessionType.socialMediaFree,
      'label': 'No Social Media',
      'icon': Icons.person_off,
      'color': AppTheme.successColor
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isRunning) {
      _recalculateTime();
    }
  }

  void _recalculateTime() {
    if (!_isRunning || _startTime == null) return;
    final elapsed = DateTime.now().difference(_startTime!).inSeconds;
    setState(() {
      _remainingSeconds = _totalDurationSeconds - elapsed;
    });
    if (_remainingSeconds <= 0) {
      _completeTimer();
    }
  }

  void _startTimer() {
    if (_isRunning) return;
    _startTime = DateTime.now();
    _totalDurationSeconds = _selectedMinutes * 60;
    _remainingSeconds = _totalDurationSeconds;
    _isRunning = true;
    _isCompleted = false;
    _pulseController.repeat(reverse: true);

    final session = DetoxSession(
      sessionType: _selectedType,
      durationMin: _selectedMinutes,
      startedAt: DateTime.now(),
    );
    ref
        .read(recoveryProvider.notifier)
        .startDetoxSession(session)
        .then((docId) {
      if (!mounted) return;
      if (docId != null) {
        _sessionId = docId;
      }
      setState(() {});
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _recalculateTime();
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    _pulseController.stop();
    setState(() {});
  }

  void _completeTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isCompleted = true;
    _pulseController.stop();
    if (_sessionId != null && _startTime != null) {
      final completedSession = DetoxSession(
        sessionType: _selectedType,
        durationMin: _selectedMinutes,
        completedMinutes: _selectedMinutes,
        completed: true,
        startedAt: _startTime!,
        completedAt: DateTime.now(),
      );
      ref
          .read(recoveryProvider.notifier)
          .completeDetoxSession(_sessionId!, completedSession);
    }
    setState(() {});
  }

  void _resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isCompleted = false;
    _remainingSeconds = 0;
    _sessionId = null;
    _startTime = null;
    _pulseController.reset();
    setState(() {});
  }

  String get _formattedTime {
    final displaySeconds = _remainingSeconds < 0 ? 0 : _remainingSeconds;
    final min = (displaySeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (displaySeconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detox Timer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!_isRunning && !_isCompleted) ...[
              Text('Choose your detox type',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ..._sessionTypes.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _SessionTypeCard(
                      label: s['label'] as String,
                      icon: s['icon'] as IconData,
                      color: s['color'] as Color,
                      isSelected: _selectedType == s['type'],
                      onTap: () => setState(
                          () => _selectedType = s['type'] as DetoxSessionType),
                    ),
                  )),
              const SizedBox(height: 24),
              Text('Duration',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presets
                    .map((p) => ChoiceChip(
                          label: Text(p['label'] as String),
                          selected: _selectedMinutes == p['minutes'],
                          onSelected: (_) => setState(
                              () => _selectedMinutes = p['minutes'] as int),
                          selectedColor:
                              AppTheme.primaryColor.withValues(alpha: 0.2),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _startTimer,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Detox'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
            if (_isRunning) ...[
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) => Transform.scale(
                  scale: 1 + (_pulseController.value * 0.05),
                  child: child,
                ),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [AppTheme.primaryColor, Color(0xFF4A42CC)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_formattedTime,
                            style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(_selectedType.name,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pauseTimer,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.warningColor,
                      side: const BorderSide(color: AppTheme.warningColor),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                  ),
                ],
              ),
            ],
            if (_isCompleted) ...[
              const SizedBox(height: 40),
              const Icon(Icons.check_circle,
                  size: 80, color: AppTheme.successColor),
              const SizedBox(height: 16),
              const Text('Session Complete!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                  'You completed $_selectedMinutes minutes of ${_selectedType.name.replaceAll('_', ' ')}',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Done', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  _resetTimer();
                  _startTimer();
                },
                child: const Text('Start Another Session'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SessionTypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  const _SessionTypeCard(
      {required this.label,
      required this.icon,
      required this.color,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? color.withValues(alpha: 0.15)
          : (Theme.of(context).brightness == Brightness.dark
              ? AppTheme.darkCard
              : AppTheme.lightCard),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? Border.all(color: color, width: 2) : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : null)),
              const Spacer(),
              if (isSelected) Icon(Icons.check_circle, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
