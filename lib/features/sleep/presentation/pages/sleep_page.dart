// lib/features/sleep/presentation/pages/sleep_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_bounce_interaction.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage>
    with SingleTickerProviderStateMixin {
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
            backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightBg,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient:
                      isDark ? AppTheme.nightGradient : AppTheme.calmGradient,
                ),
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.bedtime, color: Colors.white, size: 36),
                        SizedBox(height: 8),
                        Text(
                          'Sleep Tracker',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: isDark ? AppTheme.darkSurface : AppTheme.lightBg,
                child: TabBar(
                  controller: _tab,
                  indicatorColor: AppTheme.primaryColor,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor:
                      isDark ? Colors.white38 : Colors.grey.shade500,
                  labelStyle: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Tonight'),
                    Tab(text: 'Tracker'),
                    Tab(text: 'Sounds')
                  ],
                ),
              ),
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
    final sleepHours = _wakeTime.hour -
        _bedtime.hour +
        (_wakeTime.minute - _bedtime.minute) / 60;
    final displayHours = sleepHours < 0 ? sleepHours + 24 : sleepHours;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: _TimeCard(
                label: 'Bedtime',
                time: _bedtime,
                icon: Icons.bedtime_outlined,
                color: AppTheme.primaryColor,
                onTap: () async {
                  final picked = await showTimePicker(
                      context: context, initialTime: _bedtime);
                  if (picked != null) setState(() => _bedtime = picked);
                },
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: _TimeCard(
                label: 'Wake Up',
                time: _wakeTime,
                icon: Icons.wb_sunny_outlined,
                color: AppTheme.warningColor,
                onTap: () async {
                  final picked = await showTimePicker(
                      context: context, initialTime: _wakeTime);
                  if (picked != null) setState(() => _wakeTime = picked);
                },
              )),
            ],
          ),
          const SizedBox(height: 20),
          _buildAiSleepRecommendation(isDark, displayHours),
          const SizedBox(height: 20),

          // Duration Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
              boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hourglass_empty, color: AppTheme.primaryColor),
                const SizedBox(width: 10),
                Text(
                  '${displayHours.toStringAsFixed(1)} hours of sleep',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: displayHours >= 7
                        ? AppTheme.successColor.withValues(alpha: 0.12)
                        : AppTheme.errorColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: displayHours >= 7
                          ? AppTheme.successColor.withValues(alpha: 0.3)
                          : AppTheme.errorColor.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    displayHours >= 7 ? 'Optimal' : 'Low',
                    style: TextStyle(
                      color: displayHours >= 7
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
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
                  ? AppTheme.nightGradient
                  : AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor
                      .withValues(alpha: _sleepMode ? 0.3 : 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(_sleepMode ? Icons.bedtime : Icons.wb_sunny,
                    color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sleepMode ? 'Sleep Mode Active' : 'Start Sleep Mode',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'DND, dark screen, sleep sounds',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
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
          const SizedBox(height: 24),

          // Tips
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Sleep Tips',
              style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          ...[
            'Avoid screens 1 hour before bed',
            'Keep room temperature cool (16-18°C)',
            'Try deep breathing before sleep',
            'Consistent schedule on weekends too'
          ].map((tip) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tips_and_updates_outlined,
                        color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(
                      tip,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    )),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAiSleepRecommendation(bool isDark, double sleepHours) {
    String recommendation;
    if (sleepHours < 6) {
      recommendation =
          "You're planning less than 6 hours of sleep. Consider trying the '4-7-8 Breathing' routine tonight to maximize your rest quality.";
    } else if (sleepHours > 9) {
      recommendation =
          "You're aiming for a lot of sleep! Ensure your room is dark and cool to prevent waking up groggy.";
    } else {
      recommendation =
          "Your sleep schedule looks optimal. A 10-minute wind-down meditation could help you fall asleep faster.";
    }

    final cardBgColor = isDark ? AppTheme.darkCard : Colors.white;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology,
                  color: AppTheme.primaryColor, size: 22),
              const SizedBox(width: 8),
              Text(
                'AI Sleep Insight',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: isDark ? Colors.white : AppTheme.primaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            recommendation,
            style: TextStyle(
              fontFamily: 'Outfit',
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerTab(bool isDark) {
    final sleepData = [7.5, 6.0, 8.0, 7.0, 8.5, 6.5, 7.5];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Weekly Sleep Trend',
              style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 220,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
              boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
            ),
            child: BarChart(
              BarChartData(
                maxY: 10,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (v) => FlLine(
                      color: isDark ? Colors.white10 : Colors.black12,
                      strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final i = v.toInt();
                        return i >= 0 && i < days.length
                            ? Text(days[i],
                                style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 11,
                                    color: Colors.grey))
                            : const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}h',
                          style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 10,
                              color: Colors.grey)),
                      reservedSize: 28,
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: sleepData
                    .asMap()
                    .entries
                    .map((e) => BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value,
                              gradient: e.value >= 7
                                  ? const LinearGradient(
                                      colors: [
                                          AppTheme.primaryColor,
                                          AppTheme.primaryDark
                                        ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter)
                                  : const LinearGradient(
                                      colors: [
                                          AppTheme.errorColor,
                                          AppTheme.warningColor
                                        ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter),
                              width: 24,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8)),
                            )
                          ],
                        ))
                    .toList(),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                        y: 7,
                        color: Colors.greenAccent,
                        strokeWidth: 1.5,
                        dashArray: [5, 5])
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Stats row
          const Row(
            children: [
              _StatCard(
                  label: 'Avg Sleep',
                  value: '7.2h',
                  icon: Icons.access_time,
                  color: AppTheme.primaryColor),
              SizedBox(width: 12),
              _StatCard(
                  label: 'Best Night',
                  value: '8.5h',
                  icon: Icons.star_outline_rounded,
                  color: AppTheme.warningColor),
              SizedBox(width: 12),
              _StatCard(
                  label: 'Streak',
                  value: '5 days',
                  icon: Icons.local_fire_department_outlined,
                  color: AppTheme.successColor),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.15,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: sounds.length,
      itemBuilder: (ctx, i) {
        final sound = sounds[i];
        return PremiumBounceInteraction(
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
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
              boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(sound['icon'] as String,
                    style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(sound['title'] as String,
                    style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(sound['desc'] as String,
                    style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.grey,
                        fontSize: 11)),
                const SizedBox(height: 12),
                const Icon(Icons.play_circle_outline,
                    color: AppTheme.primaryColor, size: 24),
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
  const _TimeCard(
      {required this.label,
      required this.time,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumBounceInteraction(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
          boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Outfit',
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color),
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
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
          boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  fontFamily: 'Outfit', fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
