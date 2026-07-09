import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/analytics_provider.dart';

class AnalyticsDashboardPage extends ConsumerStatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  ConsumerState<AnalyticsDashboardPage> createState() => _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState extends ConsumerState<AnalyticsDashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analyticsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final streak = user?.streakDays ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text('Analytics', style: GoogleFonts.playfairDisplay(fontSize: 20))),
      body: state.isLoading
          ? ListView(
              padding: const EdgeInsets.all(20),
              children: List.generate(4, (_) => const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: SkeletonCardLoader(),
              )),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                _buildStreakHeader(streak, isDark),
                const SizedBox(height: 20),
                _buildStatCards(state, isDark),
                const SizedBox(height: 24),
                if (state.showCharts) ...[
                  _buildSectionTitle('Wellness Trend', Icons.trending_up_rounded, isDark),
                  const SizedBox(height: 12),
                  _buildWellnessTrendChart(state, isDark),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Category Breakdown', Icons.pie_chart_rounded, isDark),
                  const SizedBox(height: 12),
                  _buildCategoryChart(state, isDark),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Tasks Completed', Icons.checklist_rounded, isDark),
                  const SizedBox(height: 12),
                  _buildTasksChart(state, isDark),
                  const SizedBox(height: 28),
                  _buildInsightCard(isDark),
                ],
              ],
            ),
    );
  }

  Widget _buildStreakHeader(int streak, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.primaryDark, AppTheme.primaryColor]
              : [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Journey', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text('Wellness Analytics', style: GoogleFonts.playfairDisplay(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 18),
                    const SizedBox(width: 4),
                    Text('$streak day streak', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(AnalyticsState state, bool isDark) {
    return Row(
      children: [
        Expanded(child: _statCard('Avg Wellness', '${state.data.avgWellness}/100', Icons.favorite_rounded, AppTheme.primaryColor, isDark)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Check-ins', '${state.data.totalCheckins}', Icons.assignment_rounded, AppTheme.secondaryColor, isDark)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Tasks Done', '${state.data.totalTasksDone}', Icons.task_alt_rounded, AppTheme.successColor, isDark)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, bool isDark) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOutBack,
      builder: (_, scale, __) => Transform.scale(
        scale: scale,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppTheme.primaryDark)),
              const SizedBox(height: 4),
              Text(label, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppTheme.primaryDark)),
      ],
    );
  }

  Color _colorForCategory(String name) {
    const colors = {
      'Mood': Color(0xFF42C8B7),
      'Energy': Color(0xFF00BFA5),
      'Sleep': Color(0xFF1E6C64),
      'Focus': Color(0xFF00BCD4),
      'Calm': Color(0xFFE0F7F6),
    };
    return colors[name] ?? AppTheme.primaryColor;
  }

  Widget _buildWellnessTrendChart(AnalyticsState state, bool isDark) {
    final trend = state.data.wellnessTrend;
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) => FlLine(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: 40,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: trend.map((p) => FlSpot(p.day.toDouble(), p.value)).toList(),
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 3,
                  color: AppTheme.primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withValues(alpha: 0.12),
                cutOffY: 40,
                applyCutOffY: true,
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                '${s.y.toInt()}/100',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              )).toList(),
            ),
          ),
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ),
    );
  }

  Widget _buildCategoryChart(AnalyticsState state, bool isDark) {
    final categories = state.data.categoryTrends;
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) => FlLine(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: 30,
          maxY: 100,
          lineBarsData: categories.map((cat) => LineChartBarData(
            spots: List.generate(cat.values.length, (i) => FlSpot(i.toDouble(), cat.values[i])),
            isCurved: true,
            color: cat.color,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
          )).toList(),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipMargin: 8,
              getTooltipItems: (spots) => spots.asMap().entries.map((e) => LineTooltipItem(
                '${categories[e.key].name}: ${e.value.y.toInt()}',
                TextStyle(color: categories[e.key].color, fontWeight: FontWeight.w600, fontSize: 12),
              )).toList(),
            ),
          ),
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ),
    );
  }

  Widget _buildTasksChart(AnalyticsState state, bool isDark) {
    final tasksData = state.data.tasksCompleted;
    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: BarChart(
        BarChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) => FlLine(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: 10,
          barGroups: List.generate(tasksData.length, (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: tasksData[i].toDouble(),
                color: _barColor(i),
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 10,
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
                ),
              ),
            ],
          )),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                '${rod.toY.toInt()} tasks',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ),
    );
  }

  Color _barColor(int index) {
    const colors = [0xFF42C8B7, 0xFF00BFA5, 0xFF1E6C64, 0xFF00BCD4, 0xFF42C8B7, 0xFF00BFA5, 0xFF1E6C64];
    return Color(colors[index % colors.length]);
  }

  Widget _buildInsightCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.primaryDark.withValues(alpha: 0.5), AppTheme.darkCard]
              : [AppTheme.lavender.withValues(alpha: 0.5), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Insight', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.primaryDark)),
                const SizedBox(height: 4),
                Text('Your wellness scores are trending upward. Keep up the great work!',
                  style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
