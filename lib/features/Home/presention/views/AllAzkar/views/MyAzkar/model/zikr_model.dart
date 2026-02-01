import 'package:hive/hive.dart';

part 'zikr_model.g.dart';

@HiveType(typeId: 1)
class ZikrModel extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final int count;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final int dailyGoal;

  @HiveField(5)
  final int totalCount;

  ZikrModel({
    required this.title,
    required this.content,
    required this.count,
    this.category = "عام",
    this.dailyGoal = 100,
    this.totalCount = 0,
    this.notificationTime,
    this.isNotificationEnabled = false,
    this.lastUpdatedDate,
  });

  @HiveField(6)
  final DateTime? notificationTime;

  @HiveField(7)
  final bool isNotificationEnabled;

  @HiveField(8)
  final DateTime? lastUpdatedDate;
}
