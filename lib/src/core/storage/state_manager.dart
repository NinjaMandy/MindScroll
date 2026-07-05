import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/daily_stats.dart';
import '../models/unlock_record.dart';

class MindScrollState {
  final String todayDate;
  final int dailyGoal;
  final Map<String, int> todayCounts;
  final Set<String> enabledPlatforms;
  final String overlayPosition;
  final int estimatedVideoDurationSeconds;
  final int emergencyUnlockUntil;

  MindScrollState({
    required this.todayDate,
    required this.dailyGoal,
    required this.todayCounts,
    required this.enabledPlatforms,
    required this.overlayPosition,
    required this.estimatedVideoDurationSeconds,
    required this.emergencyUnlockUntil,
  });

  factory MindScrollState.defaultState() {
    return MindScrollState(
      todayDate: _getTodayString(),
      dailyGoal: 50,
      todayCounts: {'youtube': 0, 'instagram': 0, 'facebook': 0, 'tiktok': 0},
      enabledPlatforms: {'youtube', 'instagram', 'facebook', 'tiktok'},
      overlayPosition: 'top_right',
      estimatedVideoDurationSeconds: 30,
      emergencyUnlockUntil: 0,
    );
  }

  static String _getTodayString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  int get totalCount => todayCounts.values.reduce((a, b) => a + b);

  MindScrollState copyWith({
    String? todayDate,
    int? dailyGoal,
    Map<String, int>? todayCounts,
    Set<String>? enabledPlatforms,
    String? overlayPosition,
    int? estimatedVideoDurationSeconds,
    int? emergencyUnlockUntil,
  }) {
    return MindScrollState(
      todayDate: todayDate ?? this.todayDate,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      todayCounts: todayCounts ?? this.todayCounts,
      enabledPlatforms: enabledPlatforms ?? this.enabledPlatforms,
      overlayPosition: overlayPosition ?? this.overlayPosition,
      estimatedVideoDurationSeconds: estimatedVideoDurationSeconds ?? this.estimatedVideoDurationSeconds,
      emergencyUnlockUntil: emergencyUnlockUntil ?? this.emergencyUnlockUntil,
    );
  }
}

class StateManagerNotifier extends StateNotifier<MindScrollState> {
  final Isar _isar;
  File? _stateFile;

  StateManagerNotifier(this._isar) : super(MindScrollState.defaultState()) {
    _init();
  }

  Future<void> _init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _stateFile = File('${appDir.path}/mindscroll_state.json');
    await loadAndSyncState();
  }

  Future<void> loadAndSyncState() async {
    if (_stateFile == null) return;

    if (!await _stateFile!.exists()) {
      await saveState();
      return;
    }

    try {
      final content = await _stateFile!.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      final todayDate = json['todayDate'] as String? ?? MindScrollState._getTodayString();
      final emergencyUnlockUntil = json['emergencyUnlockUntil'] as int? ?? 0;

      final countsJson = json['todayCounts'] as Map<String, dynamic>?;
      final todayCounts = {
        'youtube': countsJson?['youtube'] as int? ?? 0,
        'instagram': countsJson?['instagram'] as int? ?? 0,
        'facebook': countsJson?['facebook'] as int? ?? 0,
        'tiktok': countsJson?['tiktok'] as int? ?? 0,
      };

      final settingsJson = json['settings'] as Map<String, dynamic>?;
      final dailyGoal = settingsJson?['dailyGoal'] as int? ?? 50;
      final estDuration = settingsJson?['estimatedVideoDurationSeconds'] as int? ?? 30;
      final position = settingsJson?['overlayPosition'] as String? ?? 'top_right';

      final platformsList = settingsJson?['enabledPlatforms'] as List<dynamic>?;
      final enabledPlatforms = platformsList != null
          ? platformsList.map((e) => e.toString()).toSet()
          : {'youtube', 'instagram', 'facebook', 'tiktok'};

      state = MindScrollState(
        todayDate: todayDate,
        dailyGoal: dailyGoal,
        todayCounts: todayCounts,
        enabledPlatforms: enabledPlatforms,
        overlayPosition: position,
        estimatedVideoDurationSeconds: estDuration,
        emergencyUnlockUntil: emergencyUnlockUntil,
      );

      // Sync counts to Isar Database
      await _syncToIsar(todayDate, todayCounts);

      // Sync unlock history logs to Isar Database and flush them from JSON
      final unlockHistory = json['unlockHistory'] as List<dynamic>?;
      if (unlockHistory != null && unlockHistory.isNotEmpty) {
        await _syncUnlockHistoryToIsar(unlockHistory);
        
        // Remove processed history from JSON to keep it small
        json['unlockHistory'] = [];
        await _stateFile!.writeAsString(jsonEncode(json));
      }
    } catch (e) {
      // Fallback
    }
  }

  Future<void> _syncToIsar(String date, Map<String, int> counts) async {
    final total = counts.values.reduce((a, b) => a + b);
    final estViewingTime = total * state.estimatedVideoDurationSeconds;

    await _isar.writeTxn(() async {
      final existing = await _isar.dailyStats.filter().dateEqualTo(date).findFirst();

      final stats = existing ?? DailyStats();
      stats.date = date;
      stats.totalCount = total;
      stats.estimatedViewingTimeSeconds = estViewingTime;
      stats.youtubeCount = counts['youtube'] ?? 0;
      stats.instagramCount = counts['instagram'] ?? 0;
      stats.facebookCount = counts['facebook'] ?? 0;
      stats.tiktokCount = counts['tiktok'] ?? 0;

      await _isar.dailyStats.put(stats);
    });
  }

  Future<void> _syncUnlockHistoryToIsar(List<dynamic> history) async {
    await _isar.writeTxn(() async {
      for (var recordJson in history) {
        final timestamp = recordJson['timestamp'] as int;
        final duration = recordJson['durationMinutes'] as int;

        // Prevent duplicate imports by checking if timestamp exists
        final existing = await _isar.unlockRecords.filter().timestampEqualTo(timestamp).findFirst();
        if (existing == null) {
          final record = UnlockRecord()
            ..timestamp = timestamp
            ..durationMinutes = duration;
          await _isar.unlockRecords.put(record);
        }
      }
    });
  }

  Future<void> saveState() async {
    if (_stateFile == null) return;

    final jsonMap = {
      'todayDate': state.todayDate,
      'emergencyUnlockUntil': state.emergencyUnlockUntil,
      'todayCounts': state.todayCounts,
      'settings': {
        'dailyGoal': state.dailyGoal,
        'estimatedVideoDurationSeconds': state.estimatedVideoDurationSeconds,
        'overlayPosition': state.overlayPosition,
        'enabledPlatforms': state.enabledPlatforms.toList(),
      },
      'unlockHistory': [] // Let Kotlin populate this
    };

    try {
      await _stateFile!.writeAsString(jsonEncode(jsonMap));
    } catch (e) {
      // Error writing state file
    }
  }

  Future<void> updateSettings({
    int? dailyGoal,
    int? estimatedVideoDurationSeconds,
    String? overlayPosition,
    Set<String>? enabledPlatforms,
  }) async {
    state = state.copyWith(
      dailyGoal: dailyGoal,
      estimatedVideoDurationSeconds: estimatedVideoDurationSeconds,
      overlayPosition: overlayPosition,
      enabledPlatforms: enabledPlatforms,
    );

    await saveState();
    
    // Recalculate and re-sync today's stats in Isar with the new configurations
    await _syncToIsar(state.todayDate, state.todayCounts);
  }
}

// Riverpod Provider definitions
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar database must be overridden in main.dart');
});

final stateManagerProvider = StateNotifierProvider<StateManagerNotifier, MindScrollState>((ref) {
  final isar = ref.watch(isarProvider);
  return StateManagerNotifier(isar);
});
