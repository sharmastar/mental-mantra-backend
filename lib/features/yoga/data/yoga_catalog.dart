import 'models/yoga_class.dart';

class YogaCatalog {
  YogaCatalog._();

  static final List<YogaClass> classes = _generateClasses();

  static List<YogaClass> _generateClasses() {
    final basePoses = [
      const YogaPose(
        id: 'pose_1',
        name: 'Child\'s Pose',
        sanskritName: 'Balasana',
        description:
            'A resting posture that gently stretches the hips, thighs, and ankles while calming the mind.',
        difficultyRating: 1,
        benefits: ['Restores energy', 'Calms the brain', 'Stretches hips'],
        durationSeconds: 60,
      ),
      const YogaPose(
        id: 'pose_2',
        name: 'Downward Facing Dog',
        sanskritName: 'Adho Mukha Svanasana',
        description:
            'A foundational pose that energizes the body, stretches the spine, and strengthens the arms and legs.',
        difficultyRating: 2,
        benefits: [
          'Strengthens arms',
          'Stretches calves',
          'Decompresses spine'
        ],
        durationSeconds: 45,
      ),
      const YogaPose(
        id: 'pose_3',
        name: 'Warrior I',
        sanskritName: 'Virabhadrasana I',
        description:
            'A powerful standing pose that builds focus, balance, and whole-body stamina.',
        difficultyRating: 2,
        benefits: [
          'Improves balance',
          'Strengthens shoulders',
          'Stretches hips'
        ],
        durationSeconds: 45,
      ),
      const YogaPose(
        id: 'pose_4',
        name: 'Warrior II',
        sanskritName: 'Virabhadrasana II',
        description:
            'A standing pose that opens the chest and hips while developing focus and willpower.',
        difficultyRating: 2,
        benefits: ['Builds endurance', 'Opens hips', 'Stretches chest'],
        durationSeconds: 45,
      ),
      const YogaPose(
        id: 'pose_5',
        name: 'Tree Pose',
        sanskritName: 'Vrksasana',
        description:
            'A balance pose that improves focus, concentration, and builds ankle strength.',
        difficultyRating: 2,
        benefits: ['Improves focus', 'Strengthens legs', 'Aligns hips'],
        durationSeconds: 30,
      ),
      const YogaPose(
        id: 'pose_6',
        name: 'Cobra Pose',
        sanskritName: 'Bhujangasana',
        description:
            'A gentle backbend that opens the chest and increases spine flexibility.',
        difficultyRating: 1,
        benefits: ['Opens chest', 'Strengthens spine', 'Relieves fatigue'],
        durationSeconds: 30,
      ),
      const YogaPose(
        id: 'pose_7',
        name: 'Bridge Pose',
        sanskritName: 'Setu Bandha Sarvangasana',
        description:
            'A backbend that opens the chest, throat, and spine while calming the central nervous system.',
        difficultyRating: 2,
        benefits: [
          'Stretches chest',
          'Calms nervous system',
          'Improves digestion'
        ],
        durationSeconds: 60,
      ),
      const YogaPose(
        id: 'pose_8',
        name: 'Cat-Cow Pose',
        sanskritName: 'Marjaryasana-Bitilasana',
        description:
            'A gentle warm-up sequence that coordinates breath with spine flexion and extension.',
        difficultyRating: 1,
        benefits: ['Warms up spine', 'Coordinates breath', 'Relieves tension'],
        durationSeconds: 60,
      ),
      const YogaPose(
        id: 'pose_9',
        name: 'Corpse Pose',
        sanskritName: 'Savasana',
        description:
            'A state of conscious rest and deep relaxation that integrates the benefits of the practice.',
        difficultyRating: 1,
        benefits: [
          'Deep relaxation',
          'Reduces fatigue',
          'Lowers blood pressure'
        ],
        durationSeconds: 120,
      ),
      const YogaPose(
        id: 'pose_10',
        name: 'Seated Forward Bend',
        sanskritName: 'Paschimottanasana',
        description:
            'A deep forward fold that stretches the hamstrings, lower back, and calms the brain.',
        difficultyRating: 2,
        benefits: ['Stretches hamstrings', 'Calms mind', 'Relieves headache'],
        durationSeconds: 60,
      ),
    ];

    final styleDetails = [
      {
        'style': YogaStyle.restorative,
        'level': YogaLevel.beginner,
        'title': 'Deep Rest & Unwind',
        'desc':
            'A slow-paced, relaxing sequence with long-held poses to calm your mind and prepare for rest.',
      },
      {
        'style': YogaStyle.vinyasa,
        'level': YogaLevel.intermediate,
        'title': 'Morning Solar Flow',
        'desc':
            'An energetic, breath-linked flow to wake up the body, build heat, and set positive intentions.',
      },
      {
        'style': YogaStyle.hatha,
        'level': YogaLevel.beginner,
        'title': 'Foundational Alignment',
        'desc':
            'Focus on alignment, steady breathing, and holding foundational postures to build strength.',
      },
      {
        'style': YogaStyle.yin,
        'level': YogaLevel.intermediate,
        'title': 'Joint & Connective Tissue Release',
        'desc':
            'Deep passive holds targeting the hips, lower back, and connective tissues for physical flexibility.',
      },
      {
        'style': YogaStyle.ashtanga,
        'level': YogaLevel.advanced,
        'title': 'Dynamic Strength & Focus',
        'desc':
            'A disciplined, demanding sequence of linked poses to build deep strength, heat, and focus.',
      },
      {
        'style': YogaStyle.kundalini,
        'level': YogaLevel.intermediate,
        'title': 'Energy Activation Kriya',
        'desc':
            'Repetitive movements, breathwork, and chanting to activate your energy and calm the nerves.',
      }
    ];

    final list = <YogaClass>[];

    // Generate exactly 50 classes programmatically
    for (int i = 0; i < 50; i++) {
      final sd = styleDetails[i % styleDetails.length];
      final style = sd['style'] as YogaStyle;
      final level = sd['level'] as YogaLevel;
      final baseTitle = sd['title'] as String;
      final baseDesc = sd['desc'] as String;

      final title = '$baseTitle (Session ${i ~/ styleDetails.length + 1})';
      final desc =
          '$baseDesc Ideal for daily stress relief, mindfulness, and somatic body awareness.';
      final duration = 15 + (i * 5) % 45; // 15 to 55 minutes

      // select 4-7 poses for this class
      final poseCount = 4 + (i % 4);
      final poses = <YogaPose>[];
      for (int p = 0; p < poseCount; p++) {
        final basePose = basePoses[(i + p) % basePoses.length];
        poses.add(
          YogaPose(
            id: 'pose_${i}_$p',
            name: basePose.name,
            sanskritName: basePose.sanskritName,
            description: basePose.description,
            difficultyRating: basePose.difficultyRating,
            benefits: basePose.benefits,
            durationSeconds: basePose.durationSeconds + (p * 10) % 60,
          ),
        );
      }

      list.add(
        YogaClass(
          id: 'yoga_class_$i',
          title: title,
          description: desc,
          imageUrl: 'assets/wellness_hero.png',
          videoUrl:
              'https://www.w3schools.com/html/mov_bbb.mp4', // sample video URL
          level: level,
          style: style,
          durationMinutes: duration,
          poses: poses,
          instructor: [
            'Aditi Shah',
            'Elena Brower',
            'Jason Crandell',
            'Tara Stiles'
          ][i % 4],
        ),
      );
    }

    return list;
  }
}
