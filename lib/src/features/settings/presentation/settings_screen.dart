import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/state_manager.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stateManagerProvider);
    final notifier = ref.read(stateManagerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Daily Limit Section
            _buildSectionHeader('Limits & Goals'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Scroll Limit',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 2),
                            Text('Maximum videos per day', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (state.dailyGoal > 10) {
                                  notifier.updateSettings(dailyGoal: state.dailyGoal - 5);
                                }
                              },
                              icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                            ),
                            Text(
                              '${state.dailyGoal}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            IconButton(
                              onPressed: () {
                                notifier.updateSettings(dailyGoal: state.dailyGoal + 5);
                              },
                              icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Est. Average Video Duration',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text('Used to estimate daily viewing time (${state.estimatedVideoDurationSeconds} seconds)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Slider(
                      value: state.estimatedVideoDurationSeconds.toDouble(),
                      min: 15,
                      max: 90,
                      divisions: 5,
                      label: '${state.estimatedVideoDurationSeconds}s',
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        notifier.updateSettings(estimatedVideoDurationSeconds: val.round());
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Platforms Section
            _buildSectionHeader('Monitored Applications'),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  children: [
                    _buildPlatformSwitch(
                      'YouTube Shorts',
                      state.enabledPlatforms.contains('youtube'),
                      (val) => _togglePlatform(state.enabledPlatforms, 'youtube', val, notifier),
                    ),
                    const Divider(height: 1),
                    _buildPlatformSwitch(
                      'Instagram Reels',
                      state.enabledPlatforms.contains('instagram'),
                      (val) => _togglePlatform(state.enabledPlatforms, 'instagram', val, notifier),
                    ),
                    const Divider(height: 1),
                    _buildPlatformSwitch(
                      'Facebook Reels',
                      state.enabledPlatforms.contains('facebook'),
                      (val) => _togglePlatform(state.enabledPlatforms, 'facebook', val, notifier),
                    ),
                    const Divider(height: 1),
                    _buildPlatformSwitch(
                      'TikTok',
                      state.enabledPlatforms.contains('tiktok'),
                      (val) => _togglePlatform(state.enabledPlatforms, 'tiktok', val, notifier),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Display Position Section
            _buildSectionHeader('Interface Options'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overlay Position',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    const Text('Where the floating counter appears during short form sessions', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: state.overlayPosition,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'top_right', child: Text('Top Right')),
                        DropdownMenuItem(value: 'top_left', child: Text('Top Left')),
                        DropdownMenuItem(value: 'bottom_right', child: Text('Bottom Right')),
                        DropdownMenuItem(value: 'bottom_left', child: Text('Bottom Left')),
                        DropdownMenuItem(value: 'bottom_center', child: Text('Bottom Center')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          notifier.updateSettings(overlayPosition: val);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPlatformSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _togglePlatform(Set<String> currentPlatforms, String platform, bool enable, StateManagerNotifier notifier) {
    final updated = Set<String>.from(currentPlatforms);
    if (enable) {
      updated.add(platform);
    } else {
      updated.remove(platform);
    }
    notifier.updateSettings(enabledPlatforms: updated);
  }
}

