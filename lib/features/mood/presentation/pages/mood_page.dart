import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/mood_provider.dart';
import '../../data/models/mood_entry.dart';

class MoodPage extends ConsumerStatefulWidget {
  const MoodPage({super.key});

  @override
  ConsumerState<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends ConsumerState<MoodPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMood = -1;
  double _stressLevel = 5;
  double _energyLevel = 5;
  double _anxietyLevel = 5;
  int _sleepHours = 7;
  final Set<String> _selectedTags = {};
  final _noteCtrl = TextEditingController();

  final _moods = [
    {'emoji': '😄', 'label': 'Great', 'value': 5, 'color': const Color(0xFF4CAF50)},
    {'emoji': '🙂', 'label': 'Good', 'value': 4, 'color': const Color(0xFF8BC34A)},
    {'emoji': '😐', 'label': 'Okay', 'value': 3, 'color': const Color(0xFFFFB547)},
    {'emoji': '😞', 'label': 'Low', 'value': 2, 'color': const Color(0xFFFF7043)},
    {'emoji': '😢', 'label': 'Sad', 'value': 1, 'color': const Color(0xFFE53935)},
  ];

  final _tags = ['Work', 'Relationships', 'Health', 'Sleep', 'Exercise', 'Food', 'Social', 'Weather', 'Money', 'Family'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: 'Log Mood'), Tab(text: 'History')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLogTab(isDark),
          _buildHistoryTab(isDark),
        ],
      ),
    );
  }

  Widget _buildLogTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How are you feeling right now?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            _formatDate(),
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _moods.asMap().entries.map((entry) {
              final mood = entry.value;
              final isSelected = _selectedMood == entry.key;
              final color = mood['color'] as Color;
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected ? Border.all(color: color, width: 2.5) : null,
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 12, spreadRadius: 2)]
                        : null,
                  ),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: isSelected ? 1.0 : 0.9, end: 1.0),
                        duration: 300.ms,
                        builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                        child: Text(mood['emoji'] as String, style: TextStyle(fontSize: isSelected ? 38 : 30)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mood['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? color : Colors.grey,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 28),
          _buildVitalsSliders(isDark),
          const SizedBox(height: 28),
          const Text('What\'s affecting your mood?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _tags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (v) => setState(() => v ? _selectedTags.add(tag) : _selectedTags.remove(tag)),
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryColor,
                labelStyle: TextStyle(fontSize: 13, color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.white70 : Colors.black87)),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryColor : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                ),
              );
            }).toList(),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 24),
          const Text('Add a note (optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'What\'s on your mind?',
              hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true,
              fillColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
            ),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: _selectedMood >= 0 ? AppTheme.primaryGradient : LinearGradient(colors: [Colors.grey.withValues(alpha: 0.3), Colors.grey.withValues(alpha: 0.3)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: _selectedMood >= 0
                    ? () {
                        final mood = _moods[_selectedMood];
                        final entry = MoodEntry(
                          moodValue: mood['value'] as int,
                          moodLabel: mood['label'] as String,
                          moodEmoji: mood['emoji'] as String,
                          stressLevel: _stressLevel.round(),
                          energyLevel: _energyLevel.round(),
                          anxietyLevel: _anxietyLevel.round(),
                          sleepHours: _sleepHours,
                          tags: _selectedTags.toList(),
                          note: _noteCtrl.text,
                          createdAt: DateTime.now(),
                        );
                        ref.read(moodListProvider.notifier).addEntry(entry);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Mood saved: ${mood['label']}'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        setState(() {
                          _selectedMood = -1;
                          _stressLevel = 5;
                          _energyLevel = 5;
                          _anxietyLevel = 5;
                          _sleepHours = 7;
                        });
                        _selectedTags.clear();
                        _noteCtrl.clear();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Mood', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}';
  }

  Widget _buildEmptyHistory(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.mood_outlined, size: 40, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Mood Data Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              'Start logging your moods to see patterns and trends over time.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(bool isDark) {
    final entries = ref.watch(moodListProvider);
    final last7 = entries.take(7).toList().reversed.toList();
    if (last7.isEmpty) {
      return _buildEmptyHistory(isDark);
    }
    final weekData = List.generate(last7.length, (i) => FlSpot(i.toDouble(), last7[i].moodValue.toDouble()));
    final avg = weekData.fold(0.0, (sum, s) => sum + s.y) / weekData.length;

    final moodColors = {
      'Great': const Color(0xFF4CAF50),
      'Good': const Color(0xFF8BC34A),
      'Okay': const Color(0xFFFFB547),
      'Low': const Color(0xFFFF7043),
      'Sad': const Color(0xFFE53935),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    const Text('7-Day Mood Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text(
                      'Avg: ${avg.toStringAsFixed(1)}/5',
                      style: const TextStyle(color: AppTheme.primaryColor, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      minY: 1, maxY: 5,
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: isDark ? Colors.white10 : Colors.black12,
                          strokeWidth: 1,
                        ),
                        drawVerticalLine: false,
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, meta) {
                              const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                              final i = v.toInt();
                              if (i < 0 || i >= days.length) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(days[i], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: weekData,
                          isCurved: true,
                          gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.accentColor]),
                          barWidth: 3,
                          dotData: FlDotData(
                            getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                              radius: 5,
                              color: AppTheme.primaryColor,
                              strokeColor: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryColor.withValues(alpha: 0.2), Colors.transparent],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),
          const Text('Recent Entries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...entries.take(10).toList().asMap().entries.map((entry) {
            final e = entry.value;
            final color = moodColors[e.moodLabel] ?? Colors.grey;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              ),
              child: Row(
                children: [
                  Text(e.moodEmoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.moodLabel,
                          style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          e.note.isNotEmpty ? e.note : 'No note',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Text(_timeAgo(e.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms, delay: (entry.key * 80).ms).slideX(begin: 0.1, end: 0);
          }),
        ],
      ),
    );
  }

  Widget _buildVitalsSliders(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vitals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _buildSliderRow(
            icon: Icons.whatshot,
            label: 'Stress',
            value: _stressLevel,
            color: const Color(0xFFFF7043),
            displayValue: _stressLevel.toInt().toString(),
            onChanged: (v) => setState(() => _stressLevel = v),
          ),
          const SizedBox(height: 16),
          _buildSliderRow(
            icon: Icons.bolt,
            label: 'Energy',
            value: _energyLevel,
            color: const Color(0xFFFDD835),
            displayValue: _energyLevel.toInt().toString(),
            onChanged: (v) => setState(() => _energyLevel = v),
          ),
          const SizedBox(height: 16),
          _buildSliderRow(
            icon: Icons.psychology,
            label: 'Anxiety',
            value: _anxietyLevel,
            color: const Color(0xFF7C4DFF),
            displayValue: _anxietyLevel.toInt().toString(),
            onChanged: (v) => setState(() => _anxietyLevel = v),
          ),
          const SizedBox(height: 16),
          _buildSliderRow(
            icon: Icons.bedtime,
            label: 'Sleep',
            value: _sleepHours.toDouble(),
            color: const Color(0xFF448AFF),
            displayValue: '${_sleepHours}h',
            min: 0,
            max: 12,
            divisions: 12,
            onChanged: (v) => setState(() => _sleepHours = v.round()),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 50.ms);
  }

  Widget _buildSliderRow({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
    required String displayValue,
    double min = 1,
    double max = 10,
    int divisions = 9,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 52,
          child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.15),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.1),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(
            displayValue,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  String _formatDate() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}
