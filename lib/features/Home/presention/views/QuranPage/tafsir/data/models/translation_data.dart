import 'package:hive/hive.dart';

part 'translation_data.g.dart';

@HiveType(typeId: 20)
class TranslationData extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String url;

  @HiveField(2)
  bool isDownloaded;

  TranslationData({
    required this.name,
    required this.url,
    this.isDownloaded = false,
  });

  // Unique key for Hive box based on content
  String get storageKey => name;
}
