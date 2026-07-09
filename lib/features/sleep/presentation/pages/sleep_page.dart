// lib/features/sleep/presentation/pages/sleep_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> with SingleTickerProviderStateMixin {
  late TabController _tab;
  TimeOfDay _bedtime = const TimeOfDay(hour: 22, minute: 30);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 30);
  bool _sleepMode = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
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
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.bedtime, color: Color(0xFF9C27B0), size: 36),
                        SizedBox(height: 8),
                        Text('Sleep Tracker', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tab,
              indicatorColor: const Color(0xFF9C27B0),
              labelColor: const Color(0xFF9C27B0),
              unselectedLabelColor: Colors.grey,
              tabs: const [Tab(text: 'Tonight'), Tab(text: 'Tracker'), Tab(text: 'Sounds')],
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tab,
              children: [
                _buildTonightTab(isDark),
                _buildTrackerTab(isDark),
                _buildSoundsTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTonightTab(bool isDark) {
    final sleepHours = _wakeTime.hour - _bedtime.hour + (_wakeTime.minute - _bedtime.minute) / 60;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Sleep schedule
          Row(
            children: [
              Expanded(child: _TimeCard(
                label: 'Bedtime',
                time: _bedtime,
                icon: Icons.bedtime_outlined,
                color: const Color(0xFF9C27B0),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: _bedtime);
                  if (picked != null) setState(() => _bedtime = picked);
                },
              )),
              const SizedBox(width: 16),
              Expanded(child: _TimeCard(
                label: 'Wake Up',
                time: _wakeTime,
                icon: Icons.wb_sunny_outlined,
                color: const Color(0xFFFFB547),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: _wakeTime);
                  if (picked != null) setState(() => _wakeTime = picked);
                },
              )),
            ],
          ),
          const SizedBox(height: 20),

          // Duration
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hourglass_empty, color: Color(0xFF9C27B0)),
                const SizedBox(width: 10),
                Text(
                  '${sleepHours.toStringAsFixed(1)} hours of sleep',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sleepHours >= 7 ? AppTheme.successColor.withValues(alpha: 0.1) : AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sleepHours >= 7 ? 'Optimal' : 'Low',
                    style: TextStyle(
                      color: sleepHours >= 7 ? AppTheme.successColor : AppTheme.errorColor,
                      fontSize: 12, fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sleep mode toggle
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: _sleepMode
                  ? const LinearGradient(colors: [Color(0xFF1a1a2e), Color(0xFF0f3460)])
                  : const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF6A0080)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(_sleepMode ? Icons.bedtime : Icons.wb_sunny, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_sleepMode ? 'Sleep Mode Active' : 'Start Sleep Mode', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      const Text('DND, dark screen, sleep sounds', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                  value: _sleepMode,
                  onChanged: (v) => setState(() => _sleepMode = v),
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.white30,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tips
          const Text('Sleep Tips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...['Avoid screens 1 hour before bed', 'Keep room temperature cool (16-18°C)', 'Try deep breathing before sleep', 'Consistent schedule on weekends too']
              .map((tip) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tips_and_updates_outlined, color: Color(0xFF9C27B0), size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(tip, style: const TextStyle(fontSize: 14))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTrackerTab(bool isDark) {
    final sleepData = [7.5, 6.0, 8.0, 7.0, 8.5, 6.5, 7.5];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Sleep', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: BarChart(
              BarChartData(
                maxY: 10,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (v) => FlLine(color: isDark ? Colors.white10 : Colors.black12, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final i = v.toInt();
                        return i >= 0 && i < days.length ? Text(days[i], style: const TextStyle(fontSize: 11, color: Colors.grey)) : const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}h', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      reservedSize: 28,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: sleepData.asMap().entries.map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [BarChartRodData(
                    toY: e.value,
                    gradient: e.value >= 7
                        ? const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF6A0080)], begin: Alignment.bottomCenter, end: Alignment.topCenter)
                        : const LinearGradient(colors: [Color(0xFFFF5252), Color(0xFFFF7043)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                    width: 28,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  )],
                )).toList(),
                // Add 7-hour target line
                extraLinesData: ExtraLinesData(
                  horizontalLines: [HorizontalLine(y: 7, color: Colors.greenAccent, strokeWidth: 1, dashArray: [5, 5])],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Stats row
          const Row(
            children: [
              _StatCard(label: 'Avg Sleep', value: '7.2h', icon: Icons.access_time, color: Color(0xFF9C27B0)),
              SizedBox(width: 12),
              _StatCard(label: 'Best Night', value: '8.5h', icon: Icons.star, color: AppTheme.warningColor),
              SizedBox(width: 12),
              _StatCard(label: 'Streak', value: '5 days', icon: Icons.bolt, color: AppTheme.successColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSoundsTab(bool isDark) {
    final sounds = [
      {'icon': '🌧', 'title': 'Rain', 'desc': 'Gentle rain shower'},
      {'icon': '🌊', 'title': 'Ocean', 'desc': 'Waves on the shore'},
      {'icon': '🌲', 'title': 'Forest', 'desc': 'Birds & rustling leaves'},
      {'icon': '🔥', 'title': 'Campfire', 'desc': 'Crackling fire'},
      {'icon': '🎵', 'title': '432 Hz', 'desc': 'Healing frequency'},
      {'icon': '🧘', 'title': 'Tibetan Bowls', 'desc': 'Deep resonance'},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 1.2, mainAxisSpacing: 12, crossAxisSpacing: 12,
      ),
      itemCount: sounds.length,
      itemBuilder: (ctx, i) {
        final sound = sounds[i];
        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Playing ${sound['title']}...'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(sound['icon'] as String, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(sound['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Text(sound['desc'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                const Icon(Icons.play_circle_outline, color: Color(0xFF9C27B0), size: 28),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimeCard extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _TimeCard({required this.label, required this.time, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
