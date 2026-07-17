import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../data/music_catalog.dart';

class AudioPlayerState {
  final MusicTrack? currentTrack;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double volume;
  final bool isShuffled;
  final bool isLooping;
  final List<MusicTrack> queue;
  final int queueIndex;

  const AudioPlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.isShuffled = false,
    this.isLooping = false,
    this.queue = const [],
    this.queueIndex = -1,
  });

  AudioPlayerState copyWith({
    MusicTrack? currentTrack,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isShuffled,
    bool? isLooping,
    List<MusicTrack>? queue,
    int? queueIndex,
    bool clearTrack = false,
  }) {
    return AudioPlayerState(
      currentTrack: clearTrack ? null : (currentTrack ?? this.currentTrack),
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isShuffled: isShuffled ?? this.isShuffled,
      isLooping: isLooping ?? this.isLooping,
      queue: queue ?? this.queue,
      queueIndex: queueIndex ?? this.queueIndex,
    );
  }
}

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState>
    with WidgetsBindingObserver {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _stateSub;

  AudioPlayerNotifier() : super(const AudioPlayerState()) {
    _initSession();
    WidgetsBinding.instance.addObserver(this);
    _posSub = _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });
    _durSub = _player.durationStream.listen((dur) {
      if (dur != null) {
        state = state.copyWith(duration: dur);
      }
    });
    _stateSub = _player.playerStateStream.listen((playerState) {
      state = state.copyWith(isPlaying: playerState.playing);
      if (playerState.processingState == ProcessingState.completed) {
        if (state.isLooping) {
          _player.seek(Duration.zero);
          _player.play();
        } else {
          next();
        }
      }
    });
  }

  Future<void> _initSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        _player.stop();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  static const Map<String, String> _streamingUrls = {
    'assets/audio/solfeggio/432hz.mp3':
        'https://archive.org/download/jamendo-633430/01-2318774-Bulbasound-Binaural%20Meditation%20432%20Hz.mp3',
    'assets/audio/solfeggio/528hz.mp3':
        'https://archive.org/download/Decagon-Solfeggio_Arrangement/Decagon-Solfeggio_528Hz_Transformation_And_Miracles.mp3',
    'assets/audio/solfeggio/639hz.mp3':
        'https://archive.org/download/Decagon-Solfeggio_Arrangement/Decagon-Solfeggio_639Hz_Connecting_Relationships.mp3',
    'assets/audio/solfeggio/852hz.mp3':
        'https://archive.org/download/Decagon-Solfeggio_Arrangement/Decagon-Solfeggio_852Hz_Returning_To_Spiritual_Order.mp3',
    'assets/audio/rain.mp3':
        'https://costellopsychology.com/relax/Brainwave%20Nature/Gentle%20Rain.mp3',
    'assets/audio/ocean.mp3':
        'https://costellopsychology.com/relax/Brainwave%20Nature/Sleepy%20Ocean.mp3',
    'assets/audio/forest.mp3':
        'https://costellopsychology.com/relax/Brainwave%20Nature/Rainforest%20Sounds.mp3',
    'assets/audio/stream.mp3':
        'https://costellopsychology.com/relax/Brainwave%20Nature/Forest%20Stream.mp3',
    'assets/audio/delta.mp3':
        'https://archive.org/download/OndesCrbralesTuningMusique/BrainSync-01.relieveJetLagdeltaSleep.mp3',
    'assets/audio/theta.mp3':
        'https://archive.org/download/OndesCrbralesTuningMusique/BrainSync-01.deepLearningmusicThetaFrequencies.mp3',
    'assets/audio/alpha.mp3':
        'https://archive.org/download/OndesCrbralesTuningMusique/BrainSync-02.totalRelaxationambienceAlphaWaves.mp3',
    'assets/audio/gamma.mp3':
        'https://archive.org/download/OndesCrbralesTuningMusique/BrainSync-01.highFocusmusicHighBetaWaves.mp3',
    'assets/audio/focus.mp3':
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    'assets/audio/lofi.mp3':
        'https://archive.org/download/cozy-alone-lofi-chill-out-beats/Cozy%20Alone%20Lofi%20Chill%20Out%20Beats%20Music%20Mix.mp3',
    'assets/audio/piano.mp3':
        'https://archive.org/download/Complete_Chopin_Nocturnes/Chopin_Nocturne_No.04_in_EfM_Op.9_2_SDRodrian.mp3',
    'assets/audio/ambient.mp3':
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    'assets/audio/tranquil.mp3':
        'https://archive.org/download/Complete_Chopin_Nocturnes/Chopin_Nocturne_No.02_in_c_sharp_minor_SDRodrian.mp3',
    'assets/audio/flute.mp3':
        'https://archive.org/download/jamendo-575472/01-2190794-MemoryMusic-Hypnotic%20Asian%20Flute%20-%20Ancient%20Warrior%20Meditation.mp3',
    'assets/audio/harp.mp3':
        'https://archive.org/download/jamendo-615914/01-2281014-Frank%20Schroter-Celtic%20Harp.mp3',
    'assets/audio/cello.mp3':
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
    'assets/audio/sunrise.mp3':
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
    'assets/audio/morning.mp3':
        'https://archive.org/download/Sleep_Music-5629/junior85_-_01_-_Birdsong.mp3',
    'assets/audio/energy.mp3':
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
    'assets/audio/affirmations.mp3':
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
  };

  Future<void> playTrack(MusicTrack track, {List<MusicTrack>? queue}) async {
    String path = track.assetPath;

    // Normalize and fallback checking for existing assets
    const existingAssets = {
      'assets/audio/background.mp3',
      'assets/audio/solfeggio/963hz_meditation.mp3',
      'assets/audio/solfeggio/963hz_for_meditation_3min.mp3',
      'assets/audio/solfeggio/963hz_short_3min.mp3',
    };

    if (path == 'assets/audio/solfeggio/963hz.mp3') {
      path = 'assets/audio/solfeggio/963hz_meditation.mp3';
    }

    String resolvedPath = path;
    bool isNetwork = false;

    if (_streamingUrls.containsKey(path)) {
      resolvedPath = _streamingUrls[path]!;
      isNetwork = true;
    } else if (path.startsWith('http://') || path.startsWith('https://')) {
      isNetwork = true;
    } else if (!existingAssets.contains(path)) {
      // Fallback to local 963hz track if not found
      resolvedPath = 'assets/audio/solfeggio/963hz_meditation.mp3';
      isNetwork = false;
    }

    final playQueue = queue ?? [track];
    final index = playQueue.indexWhere((t) => t.id == track.id);

    state = state.copyWith(
      currentTrack: track,
      isPlaying: true,
      position: Duration.zero,
      duration: track.duration,
      queue: playQueue,
      queueIndex: index != -1 ? index : 0,
    );

    try {
      await _player.stop();
      if (isNetwork) {
        await _player.setUrl(resolvedPath);
      } else {
        await _player.setAsset(resolvedPath);
      }
      await _player.setVolume(state.volume);
      await _player.setLoopMode(state.isLooping ? LoopMode.one : LoopMode.off);
      await _player.play();
    } catch (e) {
      // If network track fails, fall back to local asset
      if (isNetwork) {
        try {
          await _player.stop();
          await _player.setAsset('assets/audio/solfeggio/963hz_meditation.mp3');
          await _player.setVolume(state.volume);
          await _player.play();
        } catch (_) {
          state = state.copyWith(isPlaying: false);
        }
      } else {
        state = state.copyWith(isPlaying: false);
      }
    }
  }

  void playCategory(String categoryName) {
    final cat = MusicCatalog.categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => MusicCatalog.categories.first,
    );
    if (cat.tracks.isNotEmpty) {
      playTrack(cat.tracks.first, queue: cat.tracks);
    }
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      _player.pause();
    } else {
      if (state.currentTrack != null) {
        _player.play();
      }
    }
  }

  void next() {
    if (state.queue.isEmpty) return;
    final nextIndex = (state.queueIndex + 1) % state.queue.length;
    playTrack(state.queue[nextIndex], queue: state.queue);
  }

  void previous() {
    if (state.queue.isEmpty) return;
    final prevIndex =
        state.queueIndex <= 0 ? state.queue.length - 1 : state.queueIndex - 1;
    playTrack(state.queue[prevIndex], queue: state.queue);
  }

  void seek(Duration pos) {
    _player.seek(pos);
  }

  void setVolume(double v) {
    final cleanVol = v.clamp(0.0, 1.0);
    state = state.copyWith(volume: cleanVol);
    _player.setVolume(cleanVol);
  }

  void toggleShuffle() {
    state = state.copyWith(isShuffled: !state.isShuffled);
  }

  void toggleLoop() {
    final newLoop = !state.isLooping;
    state = state.copyWith(isLooping: newLoop);
    _player.setLoopMode(newLoop ? LoopMode.one : LoopMode.off);
  }

  void playIndex(int i) {
    if (i < 0 || i >= state.queue.length) return;
    playTrack(state.queue[i], queue: state.queue);
  }

  void stop() {
    _player.stop();
    state = const AudioPlayerState();
  }
}

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  return AudioPlayerNotifier();
});

final currentTrackProvider = Provider<MusicTrack?>((ref) {
  return ref.watch(audioPlayerProvider).currentTrack;
});

final isPlayingProvider = Provider<bool>((ref) {
  return ref.watch(audioPlayerProvider).isPlaying;
});

final hasActiveTrack = Provider<bool>((ref) {
  return ref.watch(audioPlayerProvider).currentTrack != null;
});
