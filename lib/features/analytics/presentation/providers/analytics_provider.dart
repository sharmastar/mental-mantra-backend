import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/analytics_data.dart';

class AnalyticsState {
  final AnalyticsData data;
  final bool isLoading;
  final bool showCharts;

  const AnalyticsState({
    this.data = const AnalyticsData(),
    this.isLoading = true,
    this.showCharts = false,
  });

  AnalyticsState copyWith({AnalyticsData? data, bool? isLoading, bool? showCharts}) {
    return AnalyticsState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      showCharts: showCharts ?? this.showCharts,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(const AnalyticsState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(
      data: const AnalyticsData(
        wellnessTrend: wellnessTrendData,
        categoryTrends: categoryTrendData,
        tasksCompleted: tasksCompletedData,
      ),
      isLoading: false,
    );
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(showCharts: true);
  }
}

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier();
});
