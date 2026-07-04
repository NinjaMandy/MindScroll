import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/storage/state_manager.dart';
import '../../../core/storage/history_provider.dart';
import '../../../core/models/daily_stats.dart';
import '../../../core/theme/app_theme.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  bool _showMonthly = false;

  String _getDayName(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      switch (date.weekday) {
        case 1: return 'M';
        case 2: return 'T';
        case 3: return 'W';
        case 4: return 'T';
        case 5: return 'F';
        case 6: return 'S';
        case 7: return 'S';
      }
    } catch (_) {}
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);
    final state = ref.watch(stateManagerProvider);
    final goal = state.dailyGoal;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ChoiceChip(
              label: Text(_showMonthly ? 'Monthly' : 'Weekly'),
              selected: true,
              onSelected: (_) {
                setState(() {
                  _showMonthly = !_showMonthly;
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.15),
              labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: historyAsync.when(
        data: (stats) {
          final dataList = _showMonthly ? stats.monthlyHistory : stats.weeklyHistory;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Statistics Summary Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Daily Average', '${stats.dailyAverage.toStringAsFixed(1)} vids'),
                        Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
                        _buildStatItem('Streak Record', '${stats.longestStreak} days'),
                        Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
                        _buildStatItem('Emergency Unlocks', '${stats.totalEmergencyUnlocks} times'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Chart Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _showMonthly ? 'Last 30 Days' : 'Last 7 Days',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The horizontal line represents your goal of $goal videos.',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 220,
                          child: dataList.isEmpty
                              ? const Center(child: Text('No historical data recorded yet.'))
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: _getMaxY(dataList, goal.toDouble()),
                                    barTouchData: BarTouchData(
                                      touchTooltipData: BarTouchTooltipData(
                                        tooltipBgColor: isDark ? AppColors.surfaceDark : Colors.white,
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          final date = dataList[groupIndex].date;
                                          return BarTooltipItem(
                                            '$date\n${rod.toY.round()} videos',
                                            TextStyle(
                                              color: isDark ? Colors.white : Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final index = value.toInt();
                                            if (index < 0 || index >= dataList.length) return const SizedBox();
                                            final label = _showMonthly
                                                ? dataList[index].date.substring(8) // Day number
                                                : _getDayName(dataList[index].date);
                                            return SideTitleWidget(
                                              axisSide: meta.axisSide,
                                              child: Text(
                                                label,
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: _showMonthly ? 10 : 12,
                                                ),
                                              ),
                                            );
                                          },
                                          reservedSize: 24,
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 28,
                                          getTitlesWidget: (value, meta) {
                                            if (value % 20 != 0) return const SizedBox();
                                            return Text(
                                              value.toInt().toString(),
                                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                                            );
                                          },
                                        ),
                                      ),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    gridData: const FlGridData(show: false),
                                    borderData: FlBorderData(show: false),
                                    extraLinesData: ExtraLinesData(
                                      horizontalLines: [
                                        HorizontalLine(
                                          y: goal.toDouble(),
                                          color: AppColors.primary.withOpacity(0.5),
                                          strokeWidth: 2,
                                          dashArray: [5, 5],
                                          label: HorizontalLineLabel(
                                            show: true,
                                            alignment: Alignment.topRight,
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            labelResolver: (_) => 'Goal',
                                          ),
                                        ),
                                      ],
                                    ),
                                    barGroups: List.generate(dataList.length, (index) {
                                      final stats = dataList[index];
                                      final isOver = stats.totalCount > goal;
                                      return BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            toY: stats.totalCount.toDouble(),
                                            color: isOver ? AppColors.danger : AppColors.success,
                                            width: _showMonthly ? 6 : 14,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(4),
                                              topRight: Radius.circular(4),
                                            ),
                                          )
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Platform Summary details
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Historical Breakdown',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        _buildPlatformStatsRow('YouTube Shorts', _getPlatformTotal(dataList, 'youtube')),
                        const Divider(),
                        _buildPlatformStatsRow('Instagram Reels', _getPlatformTotal(dataList, 'instagram')),
                        const Divider(),
                        _buildPlatformStatsRow('Facebook Reels', _getPlatformTotal(dataList, 'facebook')),
                        const Divider(),
                        _buildPlatformStatsRow('TikTok', _getPlatformTotal(dataList, 'tiktok')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading history: $err')),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildPlatformStatsRow(String label, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          Text('$total videos', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  double _getMaxY(List<DailyStats> list, double goal) {
    double max = goal;
    for (var s in list) {
      if (s.totalCount > max) max = s.totalCount.toDouble();
    }
    return max * 1.15; // Provide padding above the max value
  }

  int _getPlatformTotal(List<DailyStats> list, String platform) {
    int sum = 0;
    for (var s in list) {
      switch (platform) {
        case 'youtube': sum += s.youtubeCount; break;
        case 'instagram': sum += s.instagramCount; break;
        case 'facebook': sum += s.facebookCount; break;
        case 'tiktok': sum += s.tiktokCount; break;
      }
    }
    return sum;
  }
}
