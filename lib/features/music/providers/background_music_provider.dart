import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'audio_player_provider.dart';

class BackgroundMusicNotifier extends StateNotifier<bool> with WidgetsBindingObserver {
  final AudioPlayer _bgPlayer = AudioPlayer();
  final Ref _ref;
  bool _initialized = false;
  bool _disposed = false;

  // Start as false — will flip to true after successfully loading audio
  BackgroundMusicNotifier(this._ref) : super(false) {
    _init();
    WidgetsBinding.instance.addObserver(this);
    _ref.listen<AudioPlayerState>(audioPlayerProvider, (previous, next) {
      if (!_disposed && state) {
        if (next.isPlaying) {
          _bgPlayer.pause();
        } else if (!_bgPlayer.playing) {
          _bgPlayer.play();
        }
      }
    });
  }

  Future<void> _init() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (_) {}

    final mainPlaying = _ref.read(audioPlayerProvider).isPlaying;
    bool loaded = false;

    // Try primary background track first
    try {
      await _bgPlayer.setAsset('assets/audio/background.mp3');
      await _bgPlayer.setVolume(0.65);
      await _bgPlayer.setLoopMode(LoopMode.all);
      loaded = true;
    } catch (e) {
      debugPrint('[BGMusic] primary load failed: $e');
    }

    // Fallback to solfeggio track
    if (!loaded) {
      try {
        await _bgPlayer.setAsset('assets/audio/solfeggio/963hz_short_3min.mp3');
        await _bgPlayer.setVolume(0.65);
        await _bgPlayer.setLoopMode(LoopMode.one);
        loaded = true;
      } catch (e) {
        debugPrint('[BGMusic] fallback load failed: $e');
      }
    }

    if (loaded) {
      _initialized = true;
      // Only auto-play if main player isn't already playing
      if (!mainPlaying && !_disposed) {
        state = true;
        try {
          await _bgPlayer.play();
        } catch (_) {
          if (!_disposed) state = false;
        }
      }
    }
  }

  Future<void> toggle() async {
    if (state) {
      await _bgPlayer.pause();
      state = false;
    } else {
      final mainPlaying = _ref.read(audioPlayerProvider).isPlaying;
      if (!_initialized) {
        await _init();
      } else if (!mainPlaying) {
        try {
          await _bgPlayer.play();
          state = true;
        } catch (_) {}
      } else {
        // Main player is playing, just mark as enabled for when it stops
        state = true;
      }
    }
  }

  Future<void> setVolume(double volume) async {
    await _bgPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed) return;
    switch (state) {
      case AppLifecycleState.paused:
        if (_bgPlayer.playing) {
          _bgPlayer.pause();
        }
        break;
      case AppLifecycleState.resumed:
        final mainPlaying = _ref.read(audioPlayerProvider).isPlaying;
        if (this.state && !mainPlaying && !_bgPlayer.playing) {
          _bgPlayer.play();
        }
        break;
      case AppLifecycleState.detached:
        _bgPlayer.stop();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposed = true;
    _bgPlayer.dispose();
    super.dispose();
  }
}

final backgroundMusicProvider =
    StateNotifierProvider<BackgroundMusicNotifier, bool>((ref) {
  return BackgroundMusicNotifier(ref);
});
