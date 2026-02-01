class LastReadModel {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final int pageNumber;

  LastReadModel({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.pageNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'surahName': surahName,
      'pageNumber': pageNumber,
    };
  }

  factory LastReadModel.fromJson(Map<String, dynamic> json) {
    return LastReadModel(
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int,
      surahName: json['surahName'] as String,
      pageNumber: json['pageNumber'] as int,
    );
  }
}
