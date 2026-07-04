import 'package:isar/isar.dart';

part 'unlock_record.g.dart';

@collection
class UnlockRecord {
  Id id = Isar.autoIncrement;

  late int timestamp; // Milliseconds since epoch
  late int durationMinutes;
}
