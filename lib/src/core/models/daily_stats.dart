import 'package:isar/isar.dart';

part 'daily_stats.g.dart';

@collection
class DailyStats {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String date; // Format: YYYY-MM-DD

  late int totalCount;
  late int estimatedViewingTimeSeconds;

  late int youtubeCount;
  late int instagramCount;
  late int facebookCount;
  late int tiktokCount;
}
