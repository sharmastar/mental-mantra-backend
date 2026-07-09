import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';

enum GameType {
  memory('Memory Match', 'Sharpen your focus', Icons.psychology_outlined, Color(0xFF6C63FF)),
  focus('Focus Grid', 'Train your attention', Icons.center_focus_strong_outlined, Color(0xFF00BCD4)),
  breathing('Breathing Bubble', 'Calm your mind', Icons.air_outlined, Color(0xFF00BFA5)),
  pattern('Pattern Recall', 'Boost concentration', Icons.grid_view_outlined, Color(0xFFFF6B9D)),
  zen('Zen Garden', 'Grow your mindfulness plant', Icons.local_florist_outlined, Color(0xFF4CAF50)),
  wheel('Wellness Wheel', 'Spin for daily mindfulness', Icons.color_lens_outlined, Color(0xFFFF9800));

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  const GameType(this.label, this.subtitle, this.icon, this.color);
}

class BrainGame {
  final GameType type;
  final int points;
  final int durationSeconds;

  const BrainGame({
    required this.type,
    this.points = 10,
    this.durationSeconds = 60,
  });
}

final brainGames = [
  const BrainGame(type: GameType.memory, points: 10, durationSeconds: 45),
  const BrainGame(type: GameType.focus, points: 15, durationSeconds: 60),
  const BrainGame(type: GameType.breathing, points: 5, durationSeconds: 120),
  const BrainGame(type: GameType.pattern, points: 20, durationSeconds: 30),
];

class BrainGamesPage extends StatefulWidget {
  const BrainGamesPage({super.key});

  @override
  State<BrainGamesPage> createState() => _BrainGamesPageState();
}

class _BrainGamesPageState extends State<BrainGamesPage> {
  GameType? _activeGame;
  int _score = 0;
  int _streak = 0;

  // Memory game state
  List<int> _memoryCards = [];
  List<bool> _memoryRevealed = [];
  int? _firstPick;
  bool _isChecking = false;

  // Focus grid state
  List<int> _focusGrid = [];
  int? _focusTarget;
  int _focusHits = 0;
  int _focusMisses = 0;

  // Breathing state
  double _breathPhase = 0;

  // Pattern state
  List<int> _patternSequence = [];
  List<int> _playerSequence = [];
  int _patternRound = 1;
  bool _patternShowing = false;
  int _patternShowIndex = 0;

  // Zen Garden state
  int _waterDrops = 3;
  int _plantStage = 0; // 0: Seed, 1: Sprout, 2: Sapling, 3: Bud, 4: Bloom
  double _plantGrowth = 0.0; // 0.0 to 1.0
  String _selectedPlant = 'Lotus';
  final List<String> _plants = ['Lotus', 'Lavender', 'Sunflower', 'Banyan Tree'];
  bool _isWatering = false;

  // Wellness Wheel state
  DateTime? _lastSpinTime;
  bool _isSpinning = false;
  double _wheelTurns = 0.0;
  int _lastWinningIndex = 0;
  final List<Map<String, dynamic>> _wheelRewards = [
    {'label': '+3 Water', 'type': 'water', 'value': 3, 'color': const Color(0xFF4CAF50)},
    {'label': '+10 XP', 'type': 'xp', 'value': 10, 'color': const Color(0xFF2196F3)},
    {'label': 'Zen Quote', 'type': 'quote', 'value': 0, 'color': const Color(0xFF9C27B0)},
    {'label': '+1 Water', 'type': 'water', 'value': 1, 'color': const Color(0xFF8BC34A)},
    {'label': '+20 XP', 'type': 'xp', 'value': 20, 'color': const Color(0xFFFF9800)},
    {'label': 'Deep Breath', 'type': 'task', 'value': 0, 'color': const Color(0xFF00BCD4)},
    {'label': '+2 Water', 'type': 'water', 'value': 2, 'color': const Color(0xFFE91E63)},
    {'label': '+5 XP', 'type': 'xp', 'value': 5, 'color': const Color(0xFFFFC107)},
  ];

  @override
  void initState() {
    super.initState();
    _initMemoryGame();
    _initFocusGrid();
    _initPatternGame();
    _loadGamificationData();
  }

  Future<void> _loadGamificationData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _waterDrops = prefs.getInt('zen_water_drops') ?? 3;
      _plantStage = prefs.getInt('zen_plant_stage') ?? 0;
      _plantGrowth = prefs.getDouble('zen_plant_growth') ?? 0.0;
      _selectedPlant = prefs.getString('zen_selected_plant') ?? 'Lotus';
      final lastSpinMs = prefs.getInt('wheel_last_spin_time');
      if (lastSpinMs != null) {
        _lastSpinTime = DateTime.fromMillisecondsSinceEpoch(lastSpinMs);
      }
    });
  }

  Future<void> _saveGamificationData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('zen_water_drops', _waterDrops);
    await prefs.setInt('zen_plant_stage', _plantStage);
    await prefs.setDouble('zen_plant_growth', _plantGrowth);
    await prefs.setString('zen_selected_plant', _selectedPlant);
    if (_lastSpinTime != null) {
      await prefs.setInt('wheel_last_spin_time', _lastSpinTime!.millisecondsSinceEpoch);
    }
  }

  void _spinWheel() {
    if (_isSpinning) return;
    HapticFeedback.lightImpact();
    setState(() {
      _isSpinning = true;
    });

    final random = Random();
    final winningIndex = random.nextInt(_wheelRewards.length);
    _lastWinningIndex = winningIndex;

    // Calculate turns: add 5 full rotations (5.0) plus the slice rotation difference
    final currentBaseTurns = _wheelTurns.floor();
    final targetOffset = ((8 - winningIndex) % 8) * 0.125;
    setState(() {
      _wheelTurns = currentBaseTurns + 5.0 + targetOffset;
    });
  }

  void _onSpinComplete() {
    setState(() {
      _isSpinning = false;
      _lastSpinTime = DateTime.now();
    });
    _saveGamificationData();

    final reward = _wheelRewards[_lastWinningIndex];
    final String label = reward['label'];
    final String type = reward['type'];
    final int value = reward['value'];

    String message = '';
    if (type == 'water') {
      setState(() {
        _waterDrops += value;
      });
      _saveGamificationData();
      message = 'You won $value Water Drops! Use them to grow your Zen Garden 💧';
    } else if (type == 'xp') {
      setState(() {
        _score += value; // Adds to brain game score
      });
      message = 'You won $value XP points! Keep leveling up 🌟';
    } else if (type == 'quote') {
      final quotes = [
        "Quiet the mind and the soul will speak. 🧘",
        "Adopt the pace of nature: her secret is patience. 🌿",
        "Your mind is a garden. Your thoughts are the seeds. 🌱",
        "Peace comes from within. Do not seek it without. ✨",
      ];
      message = quotes[Random().nextInt(quotes.length)];
    } else if (type == 'task') {
      message = 'Daily Task: Take 5 deep breaths right now to calm your nervous system. 🌬️';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Congratulations! 🎉',
          style: TextStyle(fontWeight: FontWeight.bold, color: reward['color']),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (reward['color'] as Color).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Text(
                type == 'water' ? '💧' : (type == 'xp' ? '🌟' : '🧘'),
                style: const TextStyle(fontSize: 40),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: reward['color'],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  void _waterPlant() {
    if (_waterDrops <= 0 || _isWatering) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isWatering = true;
      _waterDrops--;
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _isWatering = false;
          _plantGrowth += 0.25;
          if (_plantGrowth >= 1.0) {
            if (_plantStage < 4) {
              _plantStage++;
              _plantGrowth = 0.0;
            } else {
              _plantGrowth = 1.0; // Stay at 100% full bloom stage 4
            }
          }
        });
        _saveGamificationData();
      }
    });
  }

  void _harvestPlant() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Plant Harvested! 🌸', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💐', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            Text(
              'Your fully bloomed $_selectedPlant has been harvested!\nYou earned +100 XP points for your achievements.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _score += 100;
                _plantStage = 0;
                _plantGrowth = 0.0;
              });
              _saveGamificationData();
            },
            child: const Text('Start New Seed'),
          ),
        ],
      ),
    );
  }

  void _initMemoryGame() {
    final cards = List.generate(6, (i) => i ~/ 2);
    cards.shuffle(Random());
    _memoryCards = cards;
    _memoryRevealed = List.filled(6, false);
    _firstPick = null;
  }

  void _initFocusGrid() {
    _focusGrid = List.generate(16, (i) => i);
    _focusGrid.shuffle(Random());
    _focusTarget = _focusGrid[0];
    _focusHits = 0;
    _focusMisses = 0;
  }

  void _initPatternGame() {
    _patternRound = 1;
    _playerSequence = [];
    _patternSequence = List.generate(3, (_) => Random().nextInt(4));
    _patternShowing = true;
    _patternShowIndex = 0;
    _showPatternStep();
  }

  void _showPatternStep() {
    if (_patternShowIndex < _patternSequence.length) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _patternShowIndex++;
            if (_patternShowIndex < _patternSequence.length) {
              _showPatternStep();
            } else {
              Future.delayed(const Duration(milliseconds: 400), () {
                if (mounted) setState(() => _patternShowing = false);
              });
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF3F51B5)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.games_outlined, color: Colors.white, size: 36),
                        const SizedBox(height: 8),
                        const Text(
                          'Brain Games',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        Row(
                          children: [
                            Text('Score: $_score', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(width: 16),
                            Text('Streak: $_streak days', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
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
                if (_activeGame == null) _buildGameGrid(isDark) else _buildActiveGame(isDark),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameGrid(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose a game to train your mind', style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        )),
        const SizedBox(height: 16),
        ...GameType.values.map((game) {
          return GestureDetector(
            onTap: () => setState(() => _activeGame = game),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [game.color.withValues(alpha: 0.1), game.color.withValues(alpha: 0.02)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: game.color.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: game.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(game.icon, color: game.color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(game.label, style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: game.color,
                        )),
                        const SizedBox(height: 2),
                        Text(game.subtitle, style: TextStyle(
                          fontSize: 12, color: isDark ? Colors.white60 : Colors.black54,
                        )),
                      ],
                    ),
                  ),
                  Icon(Icons.play_circle_fill_rounded, color: game.color, size: 32),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0),
          );
        }),
      ],
    );
  }

  Widget _buildActiveGame(bool isDark) {
    switch (_activeGame!) {
      case GameType.memory:
        return _buildMemoryGame(isDark);
      case GameType.focus:
        return _buildFocusGrid(isDark);
      case GameType.breathing:
        return _buildBreathingGame(isDark);
      case GameType.pattern:
        return _buildPatternGame(isDark);
      case GameType.zen:
        return _buildZenGarden(isDark);
      case GameType.wheel:
        return _buildWellnessWheel(isDark);
    }
  }

  Widget _buildMemoryGame(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _activeGame = null;
                _initMemoryGame();
              }),
            ),
            const SizedBox(width: 8),
            const Text('Memory Match', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('Tap pairs to match', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
          ],
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10,
          ),
          itemCount: _memoryCards.length,
          itemBuilder: (ctx, i) {
            final revealed = _memoryRevealed[i];
            return GestureDetector(
              onTap: () => _onMemoryTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: revealed ? const Color(0xFF6C63FF).withValues(alpha: 0.15) : const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(16),
                  border: revealed ? Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.4)) : null,
                ),
                child: Center(
                  child: revealed
                      ? Text(
                          _memoryRevealed.where((r) => r).length == _memoryCards.length ? '🎉' : '${_memoryCards[i]}',
                          style: const TextStyle(fontSize: 32),
                        )
                      : const Icon(Icons.help_outline, color: Colors.white, size: 28),
                ),
              ),
            );
          },
        ),
        if (_memoryRevealed.where((r) => r).length == _memoryCards.length) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                const Text('All matched! +10 points', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.successColor)),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _score += 10;
                      _streak += 1;
                      _initMemoryGame();
                    });
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Play Again'),
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.successColor),
                ),
              ],
            ),
          ).animate().scale(duration: 300.ms),
        ],
      ],
    );
  }

  void _onMemoryTap(int index) {
    if (_isChecking || _memoryRevealed[index]) return;
    setState(() => _memoryRevealed[index] = true);

    if (_firstPick == null) {
      _firstPick = index;
    } else {
      _isChecking = true;
      if (_memoryCards[_firstPick!] == _memoryCards[index]) {
        _firstPick = null;
        _isChecking = false;
      } else {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) {
            setState(() {
              _memoryRevealed[_firstPick!] = false;
              _memoryRevealed[index] = false;
              _firstPick = null;
              _isChecking = false;
            });
          }
        });
      }
    }
  }

  Widget _buildFocusGrid(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() { _activeGame = null; _initFocusGrid(); }),
            ),
            const SizedBox(width: 8),
            const Text('Focus Grid', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('Hits: $_focusHits', style: const TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Tap the highlighted number quickly!',
          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8,
          ),
          itemCount: _focusGrid.length,
          itemBuilder: (ctx, i) {
            final isTarget = _focusGrid[i] == _focusTarget;
            return GestureDetector(
              onTap: () {
                if (isTarget) {
                  setState(() {
                    _focusHits++;
                    _focusGrid.shuffle(Random());
                    _focusTarget = _focusGrid[0];
                    if (_focusHits >= 10) {
                      _score += 15;
                      _streak += 1;
                      _showGameComplete('Focus Master! +15 points 🎯');
                    }
                  });
                } else {
                  setState(() => _focusMisses++);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isTarget ? const Color(0xFF00BCD4) : (isDark ? AppTheme.darkCard : AppTheme.lightSurface),
                  borderRadius: BorderRadius.circular(12),
                  border: isTarget ? null : Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                ),
                child: Center(
                  child: Text(
                    '${_focusGrid[i]}',
                    style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: isTarget ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBreathingGame(bool isDark) {
    _breathPhase = (_breathPhase + 0.02) % (2 * pi);
    final bubbleSize = 100 + 60 * sin(_breathPhase);
    final isInhale = sin(_breathPhase) >= 0;

    Future.delayed(const Duration(milliseconds: 30), () {
      if (mounted && _activeGame == GameType.breathing) setState(() {});
    });

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _activeGame = null),
            ),
            const SizedBox(width: 8),
            const Text('Breathing Bubble', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: AppTheme.successColor),
              onPressed: () {
                setState(() {
                  _score += 5;
                  _streak += 1;
                  _activeGame = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Breathing session complete! +5 points 🧘'),
                  behavior: SnackBarBehavior.floating,
                ));
              },
            ),
          ],
        ),
        const SizedBox(height: 32),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: bubbleSize,
            height: bubbleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00BFA5).withValues(alpha: isInhale ? 0.4 : 0.2),
                  const Color(0xFF00BFA5).withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF00BFA5).withValues(alpha: isInhale ? 0.5 : 0.3),
                width: isInhale ? 3 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00BFA5).withValues(alpha: isInhale ? 0.2 : 0.05),
                  blurRadius: isInhale ? 30 : 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                isInhale ? 'Breathe In' : 'Breathe Out',
                style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: isInhale ? const Color(0xFF00BFA5) : Colors.white60,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'Follow the bubble — breathe in as it grows, out as it shrinks',
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
        ),
        const SizedBox(height: 12),
        Text(
          'Complete 5 cycles, then tap ✓ to earn points',
          style: TextStyle(
            fontSize: 12, color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
      ],
    );
  }

  Widget _buildPatternGame(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() { _activeGame = null; _initPatternGame(); }),
            ),
            const SizedBox(width: 8),
            const Text('Pattern Recall', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('Round $_patternRound', style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFFF6B9D),
            )),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _patternShowing ? 'Watch the pattern...' : 'Repeat the pattern!',
          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1,
          ),
          itemCount: 4,
          itemBuilder: (ctx, i) {
            final isHighlighted = _patternShowing && _patternShowIndex > 0 &&
                _patternSequence.length > _patternShowIndex - 1 &&
                _patternSequence[_patternShowIndex - 1] == i;
            final isPlayerStep = !_patternShowing && _playerSequence.contains(i);

            return GestureDetector(
              onTap: _patternShowing ? null : () => _onPatternTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? const Color(0xFFFF6B9D)
                      : (isPlayerStep
                          ? const Color(0xFFFF6B9D).withValues(alpha: 0.2)
                          : (isDark ? AppTheme.darkCard : AppTheme.lightSurface)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isHighlighted
                        ? const Color(0xFFFF6B9D)
                        : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                  ),
                ),
                child: Center(
                  child: Icon(
                    [Icons.circle_outlined, Icons.square_outlined, Icons.star_outline, Icons.diamond_outlined][i],
                    size: 48,
                    color: isHighlighted ? Colors.white : const Color(0xFFFF6B9D).withValues(alpha: 0.5),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _onPatternTap(int index) {
    if (_patternShowing) return;
    setState(() => _playerSequence.add(index));

    if (_playerSequence.last != _patternSequence[_playerSequence.length - 1]) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Wrong pattern! Try again'),
        behavior: SnackBarBehavior.floating,
      ));
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
          _playerSequence = [];
          _patternShowing = true;
          _patternShowIndex = 0;
          _showPatternStep();
        });
        }
      });
    } else if (_playerSequence.length == _patternSequence.length) {
      setState(() {
        _patternRound++;
        _playerSequence = [];
        _patternSequence.add(Random().nextInt(4));
        _patternShowing = true;
        _patternShowIndex = 0;
        _showPatternStep();
      });
      if (_patternRound >= 5) {
        _score += 20 + (_patternRound * 5);
        _streak += 1;
        _showGameComplete('Pattern Genius! +${20 + _patternRound * 5} points 🧠');
      }
    }
  }

  void _showGameComplete(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🧠', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _activeGame = null;
                _initPatternGame();
              });
            },
            child: const Text('Back to Games'),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessWheel(bool isDark) {
    final canSpin = _lastSpinTime == null ||
        DateTime.now().difference(_lastSpinTime!).inHours >= 24;

    String formatCooldown() {
      if (_lastSpinTime == null) return '';
      final nextSpin = _lastSpinTime!.add(const Duration(hours: 24));
      final diff = nextSpin.difference(DateTime.now());
      if (diff.isNegative) return '';
      final h = diff.inHours.toString().padLeft(2, '0');
      final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
      return '$h:$m:$s';
    }

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _activeGame = null),
            ),
            const SizedBox(width: 8),
            const Text('Wellness Wheel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.water_drop, color: Colors.blue, size: 16),
                  const SizedBox(width: 4),
                  Text('$_waterDrops Drops', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          canSpin ? 'Spin the wheel for your daily reward!' : 'Next daily spin available in:',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 16),
        ),
        if (!canSpin) ...[
          const SizedBox(height: 8),
          Text(
            formatCooldown(),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFF9800)),
          ),
        ],
        const SizedBox(height: 32),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating wheel
              AnimatedRotation(
                turns: _wheelTurns,
                duration: const Duration(seconds: 4),
                curve: Curves.easeOutCubic,
                onEnd: _onSpinComplete,
                child: Container(
                  height: 260,
                  width: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _WheelPainter(rewards: _wheelRewards),
                  ),
                ),
              ),
              // Wheel indicator arrow
              Positioned(
                top: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: const Icon(Icons.arrow_downward, color: Colors.red, size: 16),
                ),
              ),
              // Center spin button
              GestureDetector(
                onTap: (canSpin && !_isSpinning) ? _spinWheel : null,
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: (canSpin && !_isSpinning) ? const Color(0xFFFF9800) : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                  ),
                  child: Center(
                    child: Text(
                      _isSpinning ? '...' : 'SPIN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
      ],
    );
  }

  Widget _buildZenGarden(bool isDark) {
    // Current stage labels
    final List<String> stageNames = ['Seed', 'Sprout', 'Young Plant', 'Budding', 'Full Bloom'];
    final List<String> stageEmojis = ['🌱', '🌿', '🪴', '🌸', '💐'];

    final potColors = {
      'Lotus': const Color(0xFFFF80AB),
      'Lavender': const Color(0xFFB39DDB),
      'Sunflower': const Color(0xFFFFD54F),
      'Banyan Tree': const Color(0xFF8D6E63),
    };

    final isFullyGrown = _plantStage == 4 && _plantGrowth >= 1.0;

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _activeGame = null),
            ),
            const SizedBox(width: 8),
            const Text('Zen Garden', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.water_drop, color: Colors.blue, size: 16),
                  const SizedBox(width: 4),
                  Text('$_waterDrops Drops', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Plant Type Selector (only if stage is 0 and progress is 0)
        if (_plantStage == 0 && _plantGrowth == 0.0) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose a seed to plant:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _plants.map((plant) {
                    final isSelected = _selectedPlant == plant;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _selectedPlant = plant;
                          _saveGamificationData();
                        }),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green.withValues(alpha: 0.1) : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? Colors.green : Colors.grey.shade300,
                              width: isSelected ? 1.5 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              plant,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.green : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Pot & Plant Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
            border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
          ),
          child: Column(
            children: [
              Text(
                'Growing: $_selectedPlant',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Stage: ${stageNames[_plantStage]}',
                style: TextStyle(color: potColors[_selectedPlant], fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),

              // Animated plant growth emoji representation
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Growth Stage Graphic
                  Container(
                    height: 130,
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      isFullyGrown ? '💐' : stageEmojis[_plantStage],
                      style: const TextStyle(fontSize: 72),
                    ).animate(target: _isWatering ? 1.0 : 0.0)
                     .scale(duration: 400.ms, curve: Curves.elasticOut)
                     .shimmer(duration: 800.ms, color: Colors.greenAccent),
                  ),
                  
                  // Watering drops animation
                  if (_isWatering)
                    Positioned(
                      top: 10,
                      child: const Icon(Icons.water_drop, color: Colors.blue, size: 24)
                          .animate()
                          .slideY(begin: -0.5, end: 1.5, duration: 600.ms)
                          .fadeOut(duration: 600.ms),
                    ),
                ],
              ),
              
              // Pot
              Container(
                width: 90,
                height: 36,
                decoration: BoxDecoration(
                  color: potColors[_selectedPlant],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: const Center(
                  child: Text('ZEN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2)),
                ),
              ),
              const SizedBox(height: 32),
              
              // Progress Bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _plantGrowth,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(potColors[_selectedPlant] ?? Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${(_plantGrowth * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Action Buttons
        if (isFullyGrown) ...[
          FilledButton.icon(
            onPressed: _harvestPlant,
            icon: const Icon(Icons.star),
            label: const Text('Harvest Plant (+100 XP)'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ).animate().scale(duration: 400.ms),
        ] else ...[
          FilledButton.icon(
            onPressed: (_waterDrops > 0 && !_isWatering) ? _waterPlant : null,
            icon: const Icon(Icons.water_drop),
            label: const Text('Water Plant (Consumes 1 Drop)'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> rewards;
  _WheelPainter({required this.rewards});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()..style = PaintingStyle.fill;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final angleStep = (2 * pi) / rewards.length;

    for (int i = 0; i < rewards.length; i++) {
      paint.color = rewards[i]['color'] as Color;
      // Draw segment slice
      canvas.drawArc(rect, i * angleStep - pi / 2 - angleStep / 2, angleStep, true, paint);

      // Draw text label on the slice
      canvas.save();
      final textAngle = i * angleStep - pi / 2;
      canvas.translate(center.dx, center.dy);
      canvas.rotate(textAngle);
      canvas.translate(0, -radius * 0.65);
      canvas.rotate(pi / 2); // Rotate text to be readable along the radius

      textPainter.text = TextSpan(
        text: rewards[i]['label'] as String,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'Outfit',
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }

    // Draw center pin border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
