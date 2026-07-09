import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/gita_data.dart';

final showSecularProvider = StateProvider<bool>((ref) => false);
final selectedEmotionProvider = StateProvider<EmotionalState>((ref) => EmotionalState.peaceCalm);

class SpiritualPage extends ConsumerWidget {
  const SpiritualPage({super.key});

  static const _secularContent = {
    EmotionalState.fearAnxiety: {
      'title': 'Finding Your Ground',
      'text': 'When fear rises, anchor yourself in the present moment. Your breath is always here, always steady, always available. You have survived everything life has thrown at you so far — and you will survive this too.',
      'practice': 'Try this: Place your hand on your chest. Feel your heartbeat. Say to yourself: "Right now, in this moment, I am safe."',
    },
    EmotionalState.angerControl: {
      'title': 'The Pause Between',
      'text': 'Anger is a signal, not a command. It tells you something matters — but it doesn\'t get to choose how you respond. Between the trigger and the reaction lies your freedom.',
      'practice': 'Try this: When anger rises, count to 10 before responding. Notice how the intensity shifts with each breath.',
    },
    EmotionalState.lowMotivation: {
      'title': 'Starting Small',
      'text': 'Energy follows action, not the other way around. You don\'t need to wait for motivation — just move one finger, take one step, write one word. Momentum builds from the smallest beginning.',
      'practice': 'Try this: Commit to just 2 minutes of any task. After 2 minutes, you\'re free to stop. Most times, you\'ll keep going.',
    },
    EmotionalState.griefSadness: {
      'title': 'Holding Space',
      'text': 'Grief is not something to fix — it\'s something to honour. Your sadness is proof that you loved, that you cared, that you are human. Give yourself permission to feel without judgment.',
      'practice': 'Try this: Set a timer for 5 minutes. Allow yourself to feel whatever comes — cry, write, sit in silence. You are safe to feel.',
    },
    EmotionalState.confusionDoubt: {
      'title': 'Trusting the Unknown',
      'text': 'Clarity rarely comes from more thinking. It comes from space — stepping back, breathing, and allowing answers to surface naturally. You don\'t need to have it all figured out today.',
      'practice': 'Try this: Write down your question. Then put it aside for 24 hours. Let your subconscious work while you rest.',
    },
    EmotionalState.peaceCalm: {
      'title': 'Resting in Stillness',
      'text': 'Peace is not somewhere you arrive — it\'s something you remember. Beneath the noise of daily life, a quiet center always exists within you. You can return to it anytime.',
      'practice': 'Try this: Close your eyes and imagine a still lake. Each breath smooths the surface until there\'s only calm reflection.',
    },
    EmotionalState.selfWorth: {
      'title': 'Your Inherent Value',
      'text': 'Your worth is not something you earn or lose. It\'s not based on your productivity, your appearance, or what others think. You are valuable simply because you exist. That never changes.',
      'practice': 'Try this: Look in a mirror and say: "I am enough, exactly as I am." Notice how it feels. Try again tomorrow.',
    },
    EmotionalState.detachment: {
      'title': 'The Art of Letting Go',
      'text': 'Holding on tightly creates tension — in your hands, your mind, your heart. Letting go doesn\'t mean you don\'t care. It means you trust that things can unfold without you forcing them.',
      'practice': 'Try this: Hold your fist tight for 10 seconds. Then slowly open it. Notice the relief. Now imagine doing that with a worry you\'re holding onto.',
    },
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showSecular = ref.watch(showSecularProvider);
    final selectedEmotion = ref.watch(selectedEmotionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
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
                        const Icon(Icons.self_improvement, color: Colors.white, size: 36),
                        const SizedBox(height: 8),
                        const Text(
                          'Wisdom & Reflection',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          showSecular ? 'Mindfulness practices for every state of mind' : 'Ancient wisdom for modern well-being',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        showSecular ? 'Secular' : 'Sacred',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 6),
                      Switch(
                        value: showSecular,
                        onChanged: (v) => ref.read(showSecularProvider.notifier).state = v,
                        activeTrackColor: Colors.white30,
                        thumbColor: WidgetStateProperty.resolveWith((_) => Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildEmotionChips(context, ref, selectedEmotion, isDark),
                const SizedBox(height: 24),
                if (showSecular) _buildSecularContent(context, selectedEmotion, isDark)
                else _buildGitaContent(context, selectedEmotion, isDark),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionChips(BuildContext context, WidgetRef ref, EmotionalState selected, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How are you feeling right now?', style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        )),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EmotionalState.values.map((state) {
            final isSelected = selected == state;
            return GestureDetector(
              onTap: () => ref.read(selectedEmotionProvider.notifier).state = state,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.7)],
                        )
                      : null,
                  color: isSelected ? null : (isDark ? AppTheme.darkCard : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      state.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGitaContent(BuildContext context, EmotionalState state, bool isDark) {
    final slokas = getSlokasForEmotion(state);
    if (slokas.isEmpty) {
      return const Center(child: Text('No verses available for this state yet.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: slokas.map((sloka) {
        final index = slokas.indexOf(sloka);
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6C63FF).withValues(alpha: 0.1),
                const Color(0xFF3F51B5).withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${sloka.chapter} · Verse ${sloka.verse}',
                      style: const TextStyle(
                        color: Color(0xFF6C63FF), fontSize: 11, fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (sloka.audioUrl != null)
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 20, color: Color(0xFF6C63FF)),
                      onPressed: () {},
                    ),
                ],
              ),
              const SizedBox(height: 20),
              // Sanskrit
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    sloka.sanskrit.split('\n').last,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFFFD700) : const Color(0xFF6C63FF),
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Transliteration
              Text(
                sloka.transliteration,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              // Meaning
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFF6C63FF).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meaning', style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white60 : const Color(0xFF6C63FF),
                    )),
                    const SizedBox(height: 6),
                    Text(
                      sloka.meaning,
                      style: TextStyle(
                        fontSize: 14, color: isDark ? Colors.white : Colors.black87, height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (sloka.context != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB547).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Color(0xFFFFB547), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          sloka.context!,
                          style: TextStyle(
                            fontSize: 13, color: isDark ? Colors.white70 : Colors.black87, height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Lesson
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00BFA5).withValues(alpha: 0.1),
                      const Color(0xFF00BFA5).withValues(alpha: 0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.spa, color: Color(0xFF00BFA5), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        sloka.lesson,
                        style: TextStyle(
                          fontSize: 14, color: isDark ? Colors.white : Colors.black87, height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: (index * 150).ms).slideY(begin: 0.1, end: 0);
      }).toList(),
    );
  }

  Widget _buildSecularContent(BuildContext context, EmotionalState state, bool isDark) {
    final content = _secularContent[state];
    if (content == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryColor.withValues(alpha: 0.1),
            AppTheme.secondaryColor.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(state.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  content['title']!,
                  style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            content['text']!,
            style: TextStyle(
              fontSize: 16, color: isDark ? Colors.white70 : Colors.black87,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.self_improvement, color: Color(0xFF00BFA5), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('A Practice for You', style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppTheme.secondaryColor,
                      )),
                      const SizedBox(height: 6),
                      Text(
                        content['practice']!,
                        style: TextStyle(
                          fontSize: 14, color: isDark ? Colors.white : Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08, end: 0);
  }
}
