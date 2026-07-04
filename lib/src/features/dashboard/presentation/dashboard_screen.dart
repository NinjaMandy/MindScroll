import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/state_manager.dart';
import '../../../core/storage/history_provider.dart';
import '../../../core/theme/app_theme.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with WidgetsBindingObserver {
  static const _platformChannel = MethodChannel('com.example.mindscroll/accessibility');
  bool _isServiceEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkServiceStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkServiceStatus();
      // Sync database with latest real-time counts from accessibility service
      ref.read(stateManagerProvider.notifier).loadAndSyncState();
    }
  }

  Future<void> _checkServiceStatus() async {
    try {
      final bool enabled = await _platformChannel.invokeMethod('isServiceEnabled');
      if (mounted) {
        setState(() {
          _isServiceEnabled = enabled;
        });
      }
    } on PlatformException {
      // Error checking status
    }
  }

  Future<void> _openServiceSettings() async {
    try {
      await _platformChannel.invokeMethod('openAccessibilitySettings');
    } on PlatformException {
      // Error opening settings
    }
  }

  Color _getProgressColor(double ratio) {
    if (ratio < 0.8) return AppColors.success; // Emerald
    if (ratio < 1.0) return AppColors.warning; // Amber
    return AppColors.danger; // Crimson
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stateManagerProvider);
    final historyAsync = ref.watch(historyProvider);

    final totalCount = state.totalCount;
    final dailyGoal = state.dailyGoal;
    final ratio = dailyGoal > 0 ? totalCount / dailyGoal : 0.0;
    final clampedRatio = ratio.clamp(0.0, 1.0);
    final progressColor = _getProgressColor(ratio);
    
    final estDurationMin = (totalCount * state.estimatedVideoDurationSeconds) ~/ 60;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MindScroll', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(stateManagerProvider.notifier).loadAndSyncState();
          await _checkServiceStatus();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isServiceEnabled) ...[
                Card(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Service Required',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'To count your Shorts and Reels, please enable the MindScroll Accessibility Service in your device settings.',
                          style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _openServiceSettings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.settings),
                          label: const Text('Enable in Settings'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Today's Progress Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    children: [
                      const Text(
                        'Today\'s Scrolling',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 180,
                            height: 180,
                            child: CircularProgressIndicator(
                              value: clampedRatio,
                              strokeWidth: 14,
                              backgroundColor: isDark ? Colors.grey[850] : Colors.grey[200],
                              color: progressColor,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$totalCount',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: ratio >= 1.0 ? AppColors.danger : (isDark ? Colors.white : Colors.black),
                                ),
                              ),
                              Text(
                                'Goal: $dailyGoal',
                                style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        ratio >= 1.0
                            ? 'Limit exceeded. Time to close the scrolling apps!'
                            : ratio >= 0.8
                                ? 'Almost at your daily limit. Be mindful.'
                                : 'You are scrolling mindfully today. Great job!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Overview Stats (Time, streak etc.)
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.timer_outlined, color: AppColors.primary),
                            const SizedBox(height: 12),
                            const Text('Est. Scroll Time', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              '$estDurationMin mins',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: historyAsync.when(
                          data: (data) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.local_fire_department, color: AppColors.warning),
                              const SizedBox(height: 12),
                              const Text('Streak Under Goal', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                '${data.longestStreak} days',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ],
                          ),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.local_fire_department, color: Colors.grey),
                              SizedBox(height: 12),
                              Text('Streak Under Goal', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              SizedBox(height: 4),
                              Text('0 days', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Platform Breakdown Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Platform Breakdown',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      _buildPlatformBar(
                        'YouTube Shorts',
                        state.todayCounts['youtube'] ?? 0,
                        state.enabledPlatforms.contains('youtube'),
                        AppColors.danger,
                      ),
                      const SizedBox(height: 12),
                      _buildPlatformBar(
                        'Instagram Reels',
                        state.todayCounts['instagram'] ?? 0,
                        state.enabledPlatforms.contains('instagram'),
                        const Color(0xFFE1306C),
                      ),
                      const SizedBox(height: 12),
                      _buildPlatformBar(
                        'Facebook Reels',
                        state.todayCounts['facebook'] ?? 0,
                        state.enabledPlatforms.contains('facebook'),
                        const Color(0xFF1877F2),
                      ),
                      const SizedBox(height: 12),
                      _buildPlatformBar(
                        'TikTok',
                        state.todayCounts['tiktok'] ?? 0,
                        state.enabledPlatforms.contains('tiktok'),
                        isDark ? Colors.white : Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformBar(String label, int count, bool isEnabled, Color color) {
    final state = ref.read(stateManagerProvider);
    final total = state.totalCount;
    final double percent = total > 0 ? count / total : 0.0;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label + (!isEnabled ? ' (Disabled)' : ''),
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              Text(
                '$count videos',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: Colors.grey.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
