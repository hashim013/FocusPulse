import 'package:hive/hive.dart';

// This line tells Flutter that the generated code will be in this file.
// It will show a red error until you run the build command.
part 'tracker_session.g.dart';

/// Data Model representing a single study session.
@HiveType(typeId: 0)
class TrackerSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subject;

  @HiveField(2)
  double hours;

  @HiveField(3)
  int mood;

  @HiveField(4)
  DateTime date;

  @HiveField(5, defaultValue: [])
  List<String> tags;

  TrackerSession({
    required this.id,
    required this.subject,
    required this.hours,
    required this.mood,
    required this.date,
    this.tags = const [],
  });
}
