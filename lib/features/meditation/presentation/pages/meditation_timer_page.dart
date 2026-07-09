import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/sound_haptic_provider.dart';
import '../../../../core/widgets/premium_bounce_interaction.dart';
import '../../../../core/utils/meditation_utils.dart';

class MeditationTimerPage extends ConsumerStatefulWidget {
  const MeditationTimerPage({super.key});

  @override
  ConsumerState<MeditationTimerPage> createState() => _MeditationTimerPageState();
}

class _MeditationTimerPageState extends ConsumerState<MeditationTimerPage>
    with SingleTickerProviderStateMixin {
  int _seconds = 0;
  int _totalSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  late AnimationController _animController;
  late Animation<double> _pulseAnim;

  final List<int> _presetDurations = [60, 180, 300, 600, 900, 1200];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic),
    );
    _setDuration(300);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  bool get _hapticsEnabled => ref.read(soundHapticProvider);

  void _setDuration(int seconds) {
    setState(() {
      _totalSeconds = seconds;
      _seconds = seconds;
      _isRunning = false;
      _timer?.cancel();
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      _animController.stop();
      setState(() => _isRunning = false);
      triggerHaptic(HapticType.medium, enabled: _hapticsEnabled);
    } else {
      _startTimer();
      triggerHaptic(HapticType.light, enabled: _hapticsEnabled);
    }
  }

  void _startTimer() {
    _animController.repeat(reverse: true);
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds <= 1) {
        _timer?.cancel();
        _animController.stop();
        _onComplete();
        return;
      }
      setState(() => _seconds--);
    });
  }

  void _onComplete() {
    setState(() => _isRunning = false);
    triggerHaptic(HapticType.medium, enabled: _hapticsEnabled);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkCard
            : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Row(
          children: [
            Icon(Icons.self_improvement, color: AppTheme.primaryColor, size: 28),
            SizedBox(width: 12),
            Text(
              'Session Complete',
              style: TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Well done. Take a deep breath and notice how you feel right now.',
          style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Finish',
              style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _resetTimer() {
    _timer?.cancel();
    _animController.stop();
    setState(() {
      _seconds = _totalSeconds;
      _isRunning = false;
    });
    triggerHaptic(HapticType.selection, enabled: _hapticsEnabled);
  }

  void _addMinute() {
    setState(() {
      _seconds += 60;
      _totalSeconds += 60;
    });
    triggerHaptic(HapticType.light, enabled: _hapticsEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _totalSeconds > 0 ? _seconds / _totalSeconds : 0.0;
    final minutesStr = (_seconds ~/ 60).toString().padLeft(2, '0');
    final secondsStr = (_seconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: const Text(
          'Silent Timer',
          style: TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: PremiumBounceInteraction(
                onTap: _toggleTimer,
                child: AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isRunning ? _pulseAnim.value : 1.0,
                      child: Container(
                        width: 270,
                        height: 270,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isDark ? AppTheme.nightGradient : AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(alpha: _isRunning ? 0.35 : 0.15),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 240,
                              height: 240,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 3.5,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$minutesStr:$secondsStr',
                                  style: const TextStyle(
                                    fontFamily: 'Playfair Display',
                                    fontSize: 52,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isRunning ? 'Tap to pause' : 'Tap to start',
                                  style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (!_isRunning) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _presetDurations.length,
                      itemBuilder: (ctx, i) {
                        final secs = _presetDurations[i];
                        final mins = secs ~/ 60;
                        final isSelected = _totalSeconds == secs;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(
                              '$mins min',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : (isDark ? Colors.white70 : Colors.black87),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) => _setDuration(secs),
                            selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                            backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            child: Row(
              children: [
                Expanded(
                  child: PremiumBounceInteraction(
                    onTap: _resetTimer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 18,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Reset',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: PremiumBounceInteraction(
                    onTap: _toggleTimer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isRunning ? 'Pause' : 'Start',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PremiumBounceInteraction(
                    onTap: _addMinute,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            size: 18,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '+1m',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum HapticFeedbackType { light, medium, selection }
