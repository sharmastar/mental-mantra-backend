import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/admin_provider.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final state = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.date_range), onPressed: () {}),
          IconButton(icon: const Icon(Icons.download), onPressed: () {}),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPeriodSelector(isDark),
                const SizedBox(height: 20),
                _buildChartCard(
                    isDark,
                    theme,
                    'Daily Active Users',
                    '${state.stats.activeUsers}',
                    state.dailyUserSpots,
                    Colors.blue,
                    '+12%'),
                const SizedBox(height: 16),
                _buildChartCard(
                    isDark,
                    theme,
                    'Sessions Completed',
                    '${state.stats.totalContentItems * 100}',
                    state.sessionsCompletedSpots,
                    AppTheme.primaryColor,
                    '+8%'),
                const SizedBox(height: 16),
                _buildDistributionCard(isDark, theme),
                const SizedBox(height: 16),
                _buildStatsGrid(isDark, theme, state.stats),
                const SizedBox(height: 80),
              ],
            ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Row(
        children: ['7D', '30D', '90D', '1Y'].map((p) {
          final selected = p == '30D';
          return Expanded(
            child: GestureDetector(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(p,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: selected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black54),
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartCard(bool isDark, ThemeData theme, String title,
      String total, List<FlSpot> spots, Color color, String change) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(title,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(change,
                style: const TextStyle(
                    color: Colors.green,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 8),
          Text(total,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                      color: isDark ? Colors.white10 : Colors.black12,
                      strokeWidth: 1),
                ),
                titlesData: const FlTitlesData(
                  bottomTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.2),
                            color.withValues(alpha: 0)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionCard(bool isDark, ThemeData theme) {
    final features = [
      {'label': 'Meditation', 'value': 38, 'color': AppTheme.primaryColor},
      {'label': 'Music Therapy', 'value': 22, 'color': AppTheme.secondaryColor},
      {'label': 'Journal', 'value': 18, 'color': AppTheme.accentColor},
      {'label': 'Yoga', 'value': 12, 'color': AppTheme.warningColor},
      {'label': 'AI Chat', 'value': 10, 'color': AppTheme.errorColor},
    ];
    final total = features.fold(0, (s, f) => s + (f['value'] as int));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Feature Distribution',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...features.map((f) {
            final pct = (f['value'] as int) / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(f['label'] as String,
                            style: const TextStyle(fontSize: 13))),
                    Text('${f['value']}%',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: f['color'] as Color)),
                  ]),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor:
                          (f['color'] as Color).withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(f['color'] as Color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isDark, ThemeData theme, dynamic stats) {
    final items = [
      {
        'label': 'Total Users',
        'value': '${stats.totalUsers}',
        'icon': Icons.people
      },
      {
        'label': 'Active Users',
        'value': '${stats.activeUsers}',
        'icon': Icons.person_pin
      },
      {
        'label': 'New (30d)',
        'value': '${stats.newUsersThisMonth}',
        'icon': Icons.person_add
      },
      {
        'label': 'Content Items',
        'value': '${stats.totalContentItems}',
        'icon': Icons.library_books
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final item = items[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
          ),
          child: Row(children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(item['icon'] as IconData,
                    color: AppTheme.primaryColor, size: 20)),
            const SizedBox(width: 12),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item['value'] as String,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(item['label'] as String,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ]),
          ]),
        );
      },
    );
  }
}
