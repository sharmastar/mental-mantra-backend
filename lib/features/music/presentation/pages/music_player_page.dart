// lib/features/music/presentation/pages/music_player_page.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class MusicPlayerPage extends StatefulWidget {
  final Map<String, dynamic> args;
  const MusicPlayerPage({super.key, required this.args});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotateController;
  bool _isPlaying = false;
  double _progress = 0.0;
  bool _isLooping = false;

  String get _title => widget.args['title'] as String? ?? 'Track';
  String get _artist => widget.args['artist'] as String? ?? 'Artist';

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _rotateController.forward();
    } else {
      _rotateController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text('Now Playing', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
                  ],
                ),
              ),

              const Spacer(),

              // Album Art
              RotationTransition(
                turns: _rotateController,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 10),
                    ],
                  ),
                  child: const Icon(Icons.music_note, color: Colors.white, size: 80),
                ),
              ),

              const Spacer(),

              // Track info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(_artist, style: const TextStyle(color: Colors.white60, fontSize: 15)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.white70, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    SliderTheme(
                      data: const SliderThemeData(
                        trackHeight: 3,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: Colors.white,
                      ),
                      child: Slider(value: _progress, onChanged: (v) => setState(() => _progress = v)),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0:00', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text('60:00', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.repeat, color: _isLooping ? AppTheme.primaryColor : Colors.white54, size: 26),
                      onPressed: () => setState(() => _isLooping = !_isLooping),
                    ),
                    IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40), onPressed: () {}),
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        width: 68, height: 68,
                        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient, shape: BoxShape.circle),
                        child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 40),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.skip_next, color: Colors.white, size: 40), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.shuffle, color: Colors.white54, size: 26), onPressed: () {}),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Volume
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    const Icon(Icons.volume_down, color: Colors.white54, size: 20),
                    Expanded(
                      child: Slider(
                        value: 0.7,
                        onChanged: (v) {},
                        activeColor: Colors.white70,
                        inactiveColor: Colors.white24,
                      ),
                    ),
                    const Icon(Icons.volume_up, color: Colors.white54, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
