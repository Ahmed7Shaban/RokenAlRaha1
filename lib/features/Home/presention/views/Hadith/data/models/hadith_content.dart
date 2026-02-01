class HadithContent {
  final int? number;
  final String hadith;
  final String? description;
  final String? searchTerm;

  HadithContent({
    this.number,
    required this.hadith,
    this.description,
    this.searchTerm,
  });

  factory HadithContent.fromJson(Map<String, dynamic> json) {
    return HadithContent(
      number: json['number'] as int?,
      hadith: json['hadith'] as String? ?? '',
      description: json['description'] as String?,
      searchTerm: json['searchTerm'] as String?,
    );
  }
}
