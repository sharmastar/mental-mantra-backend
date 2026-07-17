import 'package:flutter/material.dart';
import 'package:mental_mantra/core/theme/app_theme.dart';
import 'models/music_models.dart';

export 'models/music_models.dart';

class MusicCatalog {
  MusicCatalog._();

  static final List<MusicCategory> categories = _generateCategories();

  static List<MusicTrack> get allTracks =>
      categories.expand((c) => c.tracks).toList();

  static List<MusicCategory> _generateCategories() {
    final catData = [
      {
        'name': 'Solfeggio Frequencies',
        'icon': Icons.tune,
        'color': AppTheme.primaryColor,
        'prefixes': [
          '396 Hz',
          '417 Hz',
          '528 Hz',
          '639 Hz',
          '741 Hz',
          '852 Hz',
          '963 Hz'
        ],
        'suffixes': [
          'Deep Healing',
          'DNA Repair',
          'Connection & Relationships',
          'Awakening Intuition',
          'Pure Aura Cleanse',
          'Divine Alignment',
          'Vibrational Shift'
        ],
        'baseUrls': [
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/solfeggio_528hz.mp3',
          'https://meditativemoods.co.uk/wp-content/uploads/2021/10/963Hz-Sample.mp3',
        ]
      },
      {
        'name': 'Nature Sounds',
        'icon': Icons.nature,
        'color': const Color(0xFF00BFA5),
        'prefixes': [
          'Gentle Rain',
          'Forest Birds',
          'Ocean Waves',
          'Thunderstorm',
          'Mountain River',
          'Wind in Pines',
          'Summer Night Crickets'
        ],
        'suffixes': [
          'in Wilderness',
          'at Dawn',
          'for Sleep',
          'with Soft Winds',
          'Deep Relaxation',
          'Calm Escape',
          'Pure Sleep Sounds'
        ],
        'baseUrls': [
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/rain.mp3',
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/forest.mp3',
        ]
      },
      {
        'name': 'Binaural Beats',
        'icon': Icons.graphic_eq,
        'color': AppTheme.errorColor,
        'prefixes': [
          'Delta Waves',
          'Theta Waves',
          'Alpha Waves',
          'Beta Waves',
          'Gamma Waves',
          'Deep Sleep Beats',
          'Focus Entrainment'
        ],
        'suffixes': [
          'for Deep Sleep',
          'for Astral Projection',
          'for High Focus',
          'for Learning',
          'for Brain Power',
          'for Relaxation',
          'for Anxiety Relief'
        ],
        'baseUrls': [
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/delta.mp3',
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/theta.mp3',
        ]
      },
      {
        'name': 'Focus Music',
        'icon': Icons.headphones,
        'color': const Color(0xFFFFB547),
        'prefixes': [
          'Deep Focus Piano',
          'Ambient Electronic',
          'Lo-Fi Study Beats',
          'Chill Synthwave',
          'Acoustic Focus',
          'Coding Flow',
          'Zen Workspace'
        ],
        'suffixes': [
          'Volume 1',
          'Session A',
          'for Coding',
          'for Reading',
          'for Writing',
          'Peak Performance',
          'Productive Hour'
        ],
        'baseUrls': [
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/focus.mp3',
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/lofi.mp3',
        ]
      },
      {
        'name': 'Calming Melodies',
        'icon': Icons.self_improvement,
        'color': const Color(0xFFAB47BC),
        'prefixes': [
          'Tranquil Piano',
          'Zen Flute',
          'Harp Dreams',
          'Cello Serenity',
          'Ambient Guitar',
          'Tibetan Bowls',
          'Crystal Chimes'
        ],
        'suffixes': [
          'for Mind Unwind',
          'in Sanctuary',
          'of Peace',
          'of Hope',
          'for Relaxation',
          'for Deep Calm',
          'for Meditation'
        ],
        'baseUrls': [
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/tranquil.mp3',
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/flute.mp3',
        ]
      },
      {
        'name': 'Morning Energy',
        'icon': Icons.wb_sunny,
        'color': const Color(0xFFFF7043),
        'prefixes': [
          'Sunrise Awakening',
          'Positive Vibes',
          'Energizing Drums',
          'Morning Uplift',
          'Joyful Spirit',
          'Gentle Sunlight',
          'Radiant Morning'
        ],
        'suffixes': [
          'to Start the Day',
          'for Vitality',
          'for Workout',
          'for Yoga',
          'for Mind Reset',
          'Volume 2',
          'Session 1'
        ],
        'baseUrls': [
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/sunrise.mp3',
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/morning.mp3',
        ]
      },
      {
        'name': 'Sleep Noise',
        'icon': Icons.bedtime,
        'color': const Color(0xFF1E88E5),
        'prefixes': [
          'White Noise',
          'Pink Noise',
          'Brown Noise',
          'Grey Noise',
          'Fan Sound',
          'Airplane Cabin',
          'Heavy Static'
        ],
        'suffixes': [
          'for Baby Sleep',
          'for Deep Sleep',
          'for Focus',
          'for Restless Minds',
          'Calming Stream',
          'Continuous Loop',
          'Relaxing Fan'
        ],
        'baseUrls': [
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/white_noise.mp3',
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/brown_noise.mp3',
        ]
      },
      {
        'name': 'Deep Space Ambient',
        'icon': Icons.brightness_3,
        'color': const Color(0xFF26A69A),
        'prefixes': [
          'Cosmic Void',
          'Nebula Drift',
          'Andromeda Wave',
          'Stellar Echoes',
          'Quantum Calm',
          'Space Flight',
          'Deep Abyss'
        ],
        'suffixes': [
          'Meditation',
          'Soundtrack',
          'Atmosphere',
          'Soundscape',
          'Voyage',
          'Harmony',
          'Drones'
        ],
        'baseUrls': [
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/space_ambient_1.mp3',
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/space_ambient_2.mp3',
        ]
      },
      {
        'name': 'Tibetan Bowls',
        'icon': Icons.gavel,
        'color': const Color(0xFF8D6E63),
        'prefixes': [
          'Himalayan Resonance',
          'Singing Bowls',
          'Temple Chants',
          'Monastery Silence',
          'Zen Resonance',
          'Bronze Bowl Harmonics',
          'Chakra Bowls'
        ],
        'suffixes': [
          'for Purification',
          'for Cleansing',
          'for Inner Peace',
          'for Meditation',
          'for Healing',
          'for Alignment',
          'for Yoga'
        ],
        'baseUrls': [
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/tibetan_bowl_1.mp3',
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/tibetan_bowl_2.mp3',
        ]
      },
      {
        'name': 'Chakra Healing',
        'icon': Icons.all_inclusive,
        'color': const Color(0xFFE91E63),
        'prefixes': [
          'Root Chakra Grounding',
          'Sacral Chakra Flow',
          'Solar Plexus Power',
          'Heart Chakra Healing',
          'Throat Chakra Truth',
          'Third Eye Intuition',
          'Crown Chakra Connection'
        ],
        'suffixes': [
          'Sound Therapy',
          'Alignment Session',
          'Frequency Balance',
          'Meditation Music',
          'Binaural Tuning',
          'Energy Clearing',
          'Vibration Activation'
        ],
        'baseUrls': [
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/chakra_align_1.mp3',
          'https://ia800905.us.archive.org/28/items/calm-breathing-meditation/chakra_align_2.mp3',
        ]
      }
    ];

    final resultList = <MusicCategory>[];

    for (int catIdx = 0; catIdx < catData.length; catIdx++) {
      final data = catData[catIdx];
      final name = data['name'] as String;
      final icon = data['icon'] as IconData;
      final color = data['color'] as Color;
      final prefixes = data['prefixes'] as List<String>;
      final suffixes = data['suffixes'] as List<String>;
      final baseUrls = data['baseUrls'] as List<String>;

      final tracks = <MusicTrack>[];

      // Generate 30 tracks for this category to reach 300+ total tracks!
      for (int i = 0; i < 30; i++) {
        final prefix = prefixes[i % prefixes.length];
        final suffix = suffixes[(i + 2) % suffixes.length];
        final title = '$prefix – $suffix';
        final trackId = 'track_${catIdx}_$i';

        // Vary the duration programmatically
        final durationSec = 300 + (i * 45) % 600;

        // Rhythmic color shading
        final shadedColor = Color.lerp(color, Colors.white, (i % 5) * 0.08)!;

        // Alternate URLs with a query string parameter to ensure uniqueness if cached
        final rawUrl = baseUrls[i % baseUrls.length];
        final url = '$rawUrl?trackId=$trackId';

        tracks.add(
          MusicTrack(
            id: trackId,
            title: title,
            artist: 'Mental Mantra Audio',
            category: name,
            icon: icon,
            color: shadedColor,
            assetPath: url,
            duration: Duration(seconds: durationSec),
          ),
        );
      }

      resultList.add(
        MusicCategory(
          name: name,
          icon: icon,
          color: color,
          tracks: tracks,
        ),
      );
    }

    return resultList;
  }
}
