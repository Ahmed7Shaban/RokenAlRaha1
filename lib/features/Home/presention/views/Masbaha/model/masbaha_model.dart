import 'package:hive/hive.dart';

part 'masbaha_model.g.dart';

@HiveType(typeId: 0)
class MasbahaModel extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final int count;

  @HiveField(2)
  final int durationInSeconds;

  @HiveField(3)
  final DateTime date;

  MasbahaModel({
    required this.title,
    required this.count,
    required this.durationInSeconds,
    required this.date,
  });

  Duration get duration => Duration(seconds: durationInSeconds);
}
