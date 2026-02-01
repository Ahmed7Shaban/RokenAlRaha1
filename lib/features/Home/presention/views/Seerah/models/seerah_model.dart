class SeerahModel {
  final int id;
  final String title;
  final String period;
  final String description;
  final String lesson;
  final String? link;

  SeerahModel({
    required this.id,
    required this.title,
    required this.period,
    required this.description,
    required this.lesson,
    this.link,
  });

  factory SeerahModel.fromJson(Map<String, dynamic> json) {
    return SeerahModel(
      id: json['id'],
      title: json['title'],
      period:
          json['date'] ??
          json['period'] ??
          '', // Handle both keys for backward compatibility
      description: json['description'],
      lesson: json['lesson'],
      link: json['link'],
    );
  }
}
