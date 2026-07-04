import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/daily_stats.dart';
import '../models/unlock_record.dart';
import 'state_manager.dart';

class HistoryStats {
  final List<DailyStats> weeklyHistory;
  final List<DailyStats> monthlyHistory;
  final double dailyAverage;
  final int longestStreak;
  final int totalEmergencyUnlocks;

  HistoryStats({
    required this.weeklyHistory,
    required this.monthlyHistory,
    required this.dailyAverage,
    required this.longestStreak,
    required this.totalEmergencyUnlocks,
  });

  factory HistoryStats.empty() {
    return HistoryStats(
      weeklyHistory: [],
      monthlyHistory: [],
      dailyAverage: 0.0,
      longestStreak: 0,
      totalEmergencyUnlocks: 0,
    );
  }
}

final historyProvider = FutureProvider<HistoryStats>((ref) async {
  final isar = ref.watch(isarProvider);
  
  // Re-run whenever state manager updates counts
  ref.watch(stateManagerProvider);

  // Fetch all stats sorted by date ascending
  final allStats = await isar.dailyStats.where().sortByDate().findAll();
  final allUnlocks = await isar.unlockRecords.where().findAll();

  if (allStats.isEmpty) {
    return HistoryStats.empty();
  }

  // Get weekly (last 7 days) and monthly (last 30 days) lists
  final weekly = allStats.length > 7 ? allStats.sublist(allStats.length - 7) : allStats;
  final monthly = allStats.length > 30 ? allStats.sublist(allStats.length - 30) : allStats;

  // Calculate daily average
  final totalVideos = allStats.map((e) => e.totalCount).reduce((a, b) => a + b);
  final avg = totalVideos / allStats.length;

  // Calculate longest streak under goal (consecutive days where totalCount <= dailyGoal)
  // We need to fetch the goal limit dynamically. Let's assume we match it against the historical state
  // or a default. Since goals are stored in StateManager, let's read the current goal.
  final currentGoal = ref.read(stateManagerProvider).dailyGoal;
  
  int longestStreak = 0;
  int currentStreak = 0;
  
  for (var stats in allStats) {
    if (stats.totalCount <= currentGoal && stats.totalCount > 0) {
      currentStreak++;
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
    } else if (stats.totalCount > currentGoal) {
      currentStreak = 0;
    }
  }

  return HistoryStats(
    weeklyHistory: weekly,
    monthlyHistory: monthly,
    dailyAverage: avg,
    longestStreak: longestStreak,
    totalEmergencyUnlocks: allUnlocks.length,
  );
});
