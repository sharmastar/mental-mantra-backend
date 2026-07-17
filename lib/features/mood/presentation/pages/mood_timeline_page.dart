// lib/features/mood/presentation/pages/mood_timeline_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mental_mantra/core/storage/hive_storage.dart';
import 'package:mental_mantra/core/theme/app_theme.dart';

class MoodTimelinePage extends ConsumerStatefulWidget {
  const MoodTimelinePage({super.key});

  @override
  ConsumerState<MoodTimelinePage> createState() => _MoodTimelinePageState();
}

class _MoodTimelinePageState extends ConsumerState<MoodTimelinePage> {
  List<Map<String, dynamic>> _moods = [];
  bool _isLoading = true;
  int _selectedDays = 30;

  @override
  void initState() {
    super.initState();
    _loadMoods();
  }

  Future<void> _loadMoods() async {
    setState(() => _isLoading = true);
    try {
      final data = await HiveStorage.getRecentMoods(days: _selectedDays);
      setState(() {
        _moods = data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Mood Timeline'),
        actions: [
          PopupMenuButton<int>(
            initialValue: _selectedDays,
            onSelected: (v) {
              setState(() => _selectedDays = v);
              _loadMoods();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 7, child: Text('Last 7 days')),
              PopupMenuItem(value: 14, child: Text('Last 14 days')),
              PopupMenuItem(value: 30, child: Text('Last 30 days')),
              PopupMenuItem(value: 90, child: Text('Last 90 days')),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Text('Filter'),
                SizedBox(width: 4),
                Icon(Icons.arrow_drop_down),
              ]),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _moods.isEmpty
              ? _buildEmptyState(isDark)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChartCard(isDark),
                      const SizedBox(height: 20),
                      _buildHeatmapSection(isDark),
                      const SizedBox(height: 20),
                      _buildTimelineList(isDark),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📊', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'No mood data yet',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start logging your mood daily\nto see your emotional timeline here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(bool isDark) {
    final spots = _moods.asMap().entries.map((e) {
      final val = (e.value['mood'] as num?)?.toDouble() ??
          (e.value['value'] as num?)?.toDouble() ??
          3.0;
      return FlSpot(e.key.toDouble(), val);
    }).toList();

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
          Row(
            children: [
              const Text('📈', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Mood Over Time',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              const Spacer(),
              Text(
                'Last $_selectedDays days',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: (isDark ? Colors.white : Colors.grey).withAlpha(30),
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        final labels = {
                          1: '😢',
                          2: '😞',
                          3: '😐',
                          4: '🙂',
                          5: '😄'
                        };
                        return Text(labels[v.toInt()] ?? '',
                            style: const TextStyle(fontSize: 12));
                      },
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0.5,
                maxY: 5.5,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots.isEmpty ? [const FlSpot(0, 3)] : spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: spots.length <= 14,
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                        radius: 4,
                        color: AppTheme.primaryColor,
                        strokeColor: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withAlpha(80),
                          AppTheme.primaryColor.withAlpha(10),
                        ],
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
    ).animate().fadeIn().slideY(begin: 0.03);
  }

  Widget _buildHeatmapSection(bool isDark) {
    // Group moods by week for a simple heatmap-style display
    final today = DateTime.now();
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
          Row(
            children: [
              const Text('🗓️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Emotional Heatmap',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Build a 7-column grid for the last 28 days
          _buildHeatmapGrid(today, isDark),
          const SizedBox(height: 12),
          _buildHeatmapLegend(),
        ],
      ),
    );
  }

  Widget _buildHeatmapGrid(DateTime today, bool isDark) {
    // Map dates to mood values
    final moodMap = <String, double>{};
    for (final m in _moods) {
      final dateStr = m['date'] as String? ?? m['timestamp'] as String? ?? '';
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        final key =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        moodMap[key] = (m['mood'] as num?)?.toDouble() ??
            (m['value'] as num?)?.toDouble() ??
            3.0;
      }
    }

    final days =
        List.generate(28, (i) => today.subtract(Duration(days: 27 - i)));
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      children: [
        Row(
          children: dayLabels
              .map((d) => Expanded(
                    child: Center(
                        child: Text(d,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey))),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: days.length,
          itemBuilder: (context, i) {
            final day = days[i];
            final key =
                '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
            final mood = moodMap[key];
            final color = mood == null
                ? (isDark ? Colors.white12 : Colors.grey.withAlpha(40))
                : _moodColor(mood);
            return Tooltip(
              message: mood == null
                  ? 'No entry'
                  : '${day.month}/${day.day}: ${mood.toStringAsFixed(1)}/5',
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeatmapLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Low', style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(width: 8),
        ...List.generate(
            5,
            (i) => Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _moodColor((i + 1).toDouble()),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
        const SizedBox(width: 8),
        const Text('High', style: TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Color _moodColor(double mood) {
    if (mood >= 4.5) return const Color(0xFF1B5E20);
    if (mood >= 3.5) return const Color(0xFF4CAF50);
    if (mood >= 2.5) return const Color(0xFFFFB547);
    if (mood >= 1.5) return const Color(0xFFFF7043);
    return const Color(0xFFE53935);
  }

  Widget _buildTimelineList(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('📋', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'Recent Entries',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._moods
            .take(10)
            .toList()
            .asMap()
            .entries
            .map((e) => _buildTimelineEntry(e.value, e.key, isDark)),
      ],
    );
  }

  Widget _buildTimelineEntry(
      Map<String, dynamic> mood, int index, bool isDark) {
    final moodValue = (mood['mood'] as num?)?.toDouble() ??
        (mood['value'] as num?)?.toDouble() ??
        3.0;
    final dateStr =
        mood['date'] as String? ?? mood['timestamp'] as String? ?? '';
    final date = DateTime.tryParse(dateStr) ?? DateTime.now();
    final note = mood['note'] as String? ?? mood['notes'] as String? ?? '';
    final emojis = ['', '😢', '😞', '😐', '🙂', '😄'];
    final emoji = emojis[moodValue.round().clamp(1, 5)];
    final color = _moodColor(moodValue);

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
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_monthName(date.month)} ${date.day}, ${date.year}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(note,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(20)),
            child: Text('${moodValue.toStringAsFixed(1)}/5',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn()
        .slideX(begin: 0.05);
  }

  String _monthName(int month) {
    const m = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return m[month.clamp(1, 12)];
  }
}
