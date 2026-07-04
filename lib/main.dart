import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'src/core/models/daily_stats.dart';
import 'src/core/models/unlock_record.dart';
import 'src/core/storage/state_manager.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/home/presentation/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Isar database in the application documents directory
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [DailyStatsSchema, UnlockRecordSchema],
    directory: dir.path,
  );

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const MindScrollApp(),
    ),
  );
}

class MindScrollApp extends ConsumerWidget {
  const MindScrollApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watches the stateManagerProvider to ensure configurations are loaded and updated reactively
    ref.watch(stateManagerProvider);

    return MaterialApp(
      title: 'MindScroll',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeShell(),
    );
  }
}
