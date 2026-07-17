// lib/features/mood/presentation/pages/mood_report_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_mantra/core/theme/app_theme.dart';
import 'package:mental_mantra/services/ai/mood_intelligence_engine.dart';
import '../providers/mood_intelligence_provider.dart';

class MoodReportPage extends ConsumerStatefulWidget {
  const MoodReportPage({super.key});

  @override
  ConsumerState<MoodReportPage> createState() => _MoodReportPageState();
}

class _MoodReportPageState extends ConsumerState<MoodReportPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(moodIntelligenceProvider.notifier).loadReports();
      ref.read(weeklySummaryProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final intelligenceState = ref.watch(moodIntelligenceProvider);
    final summaryState = ref.watch(weeklySummaryProvider);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Mood Intelligence'),
        actions: [
          _PeriodSelector(
            selected: intelligenceState.selectedPeriodDays,
            onChanged: (days) =>
                ref.read(moodIntelligenceProvider.notifier).selectPeriod(days),
          ),
        ],
      ),
      body: intelligenceState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : intelligenceState.error != null
              ? _buildError(intelligenceState.error!, isDark)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (intelligenceState.currentReport != null) ...[
                        _buildSummaryCard(
                            intelligenceState.currentReport!, isDark),
                        const SizedBox(height: 16),
                        _buildScoreRow(
                            intelligenceState.currentReport!, isDark),
                        const SizedBox(height: 16),
                        if (intelligenceState
                            .currentReport!.detectedPatterns.isNotEmpty) ...[
                          _buildSectionTitle('Detected Patterns', '🔍', isDark),
                          const SizedBox(height: 8),
                          ...intelligenceState.currentReport!.detectedPatterns
                              .asMap()
                              .entries
                              .map((e) => _buildPatternCard(e.value, isDark)
                                  .animate(
                                      delay:
                                          Duration(milliseconds: e.key * 100))
                                  .fadeIn()
                                  .slideX()),
                          const SizedBox(height: 16),
                        ],
                        if (intelligenceState
                            .currentReport!.triggers.isNotEmpty) ...[
                          _buildSectionTitle('Stress Triggers', '⚡', isDark),
                          const SizedBox(height: 8),
                          ...intelligenceState.currentReport!.triggers
                              .map((t) => _buildTriggerChip(t, isDark)),
                          const SizedBox(height: 16),
                        ],
                        _buildSectionTitle('AI Suggestions', '💡', isDark),
                        const SizedBox(height: 8),
                        ...intelligenceState.currentReport!.aiSuggestions
                            .asMap()
                            .entries
                            .map((e) =>
                                _buildSuggestionCard(e.value, e.key, isDark)),
                        const SizedBox(height: 16),
                      ],
                      // Weekly summary section
                      if (summaryState.current != null) ...[
                        _buildSectionTitle(
                            'This Week\'s Summary', '📋', isDark),
                        const SizedBox(height: 8),
                        _buildWeeklySummaryCard(summaryState.current!, isDark),
                        const SizedBox(height: 80),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildError(String error, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  ref.read(moodIntelligenceProvider.notifier).loadReports(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(MoodIntelligenceReport report, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withAlpha(180)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primaryColor.withAlpha(80),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧠', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.periodLabel,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const Text(
                      'Mood Intelligence Report',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            report.summary,
            style:
                const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.05);
  }

  Widget _buildScoreRow(MoodIntelligenceReport report, bool isDark) {
    return Row(
      children: [
        Expanded(
            child: _buildScoreTile(
                'Avg Mood',
                '${report.averageMood.toStringAsFixed(1)}/5',
                '😊',
                const Color(0xFF4CAF50),
                isDark)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildScoreTile(
                'Stress Index',
                '${report.stressIndex.toStringAsFixed(1)}/10',
                '😓',
                const Color(0xFFFF7043),
                isDark)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildScoreTile(
                'Stability',
                '${report.stabilityScore.toStringAsFixed(0)}%',
                '⚖️',
                const Color(0xFF42A5F5),
                isDark)),
      ],
    );
  }

  Widget _buildScoreTile(
      String label, String value, String icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8)
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildSectionTitle(String title, String icon, bool isDark) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black87,
            )),
      ],
    );
  }

  Widget _buildPatternCard(MoodPattern pattern, bool isDark) {
    final severityColor = pattern.severity == 'high'
        ? const Color(0xFFE53935)
        : pattern.severity == 'moderate'
            ? const Color(0xFFFF9800)
            : const Color(0xFF4CAF50);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: severityColor.withAlpha(100), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: severityColor.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(pattern.icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(pattern.label,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: severityColor.withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pattern.severity.toUpperCase(),
                        style: TextStyle(
                            color: severityColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(pattern.description,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.grey, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerChip(EmotionTrigger trigger, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 6)
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFFF7043)),
          const SizedBox(width: 6),
          Text(trigger.trigger,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(width: 6),
          Text('(${trigger.frequency}×)',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String suggestion, int index, bool isDark) {
    final colors = [
      const Color(0xFF7C4DFF),
      const Color(0xFF00BCD4),
      const Color(0xFF4CAF50),
      const Color(0xFFFF7043)
    ];
    final color = colors[index % colors.length];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline,
              size: 18, color: Color(0xFFFFB547)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(suggestion,
                  style: const TextStyle(fontSize: 13, height: 1.5))),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn()
        .slideX(begin: 0.05);
  }

  Widget _buildWeeklySummaryCard(dynamic summary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(summary.weekLabel as String,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(summary.overallAssessment as String,
              style: const TextStyle(
                  fontSize: 14, color: Colors.grey, height: 1.5)),
          const Divider(height: 24),
          _statRow('🧘', 'Meditations', '${summary.meditationSessions}'),
          _statRow('📔', 'Journal Entries', '${summary.journalEntries}'),
          _statRow('💭', 'Mood Check-ins', '${summary.moodCheckIns}'),
          _statRow('😊', 'Avg Mood',
              '${(summary.avgMoodScore as double).toStringAsFixed(1)}/5'),
        ],
      ),
    );
  }

  Widget _statRow(String icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _PeriodSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 7, label: Text('7D')),
          ButtonSegment(value: 30, label: Text('30D')),
        ],
        selected: {selected},
        onSelectionChanged: (s) => onChanged(s.first),
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 8)),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
