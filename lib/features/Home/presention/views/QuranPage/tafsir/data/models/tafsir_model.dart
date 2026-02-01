import 'package:hive/hive.dart';

part 'tafsir_model.g.dart';

@HiveType(typeId: 10)
class TafsirMetaData extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String author;
  @HiveField(3)
  final String language;
  @HiveField(4)
  bool isDownloaded;

  TafsirMetaData({
    required this.id,
    required this.name,
    required this.author,
    required this.language,
    this.isDownloaded = false,
  });

  factory TafsirMetaData.fromJson(Map<String, dynamic> json) {
    return TafsirMetaData(
      id: json['id'],
      name: json['name'],
      author: json['author'],
      language: json['language'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'author': author,
      'language': language,
      'isDownloaded': isDownloaded,
    };
  }
}

@HiveType(typeId: 11)
class TafsirContent extends HiveObject {
  @HiveField(0)
  final int tafsirId;
  @HiveField(1)
  final int surahNumber;
  @HiveField(2)
  final int ayahNumber;
  @HiveField(3)
  final String text;

  TafsirContent({
    required this.tafsirId,
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
  });

  factory TafsirContent.fromJson(Map<String, dynamic> json) {
    return TafsirContent(
      tafsirId: json['tafseer_id'],
      surahNumber: json['ayah_url'] != null
          ? int.parse(json['ayah_url'].split('/')[2])
          : 0, // Fallback if url parsing fails
      ayahNumber: json['ayah_number'],
      text: json['text'],
    );
  }
}
