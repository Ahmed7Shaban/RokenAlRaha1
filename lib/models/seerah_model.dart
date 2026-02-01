enum SeerahCategory { lifeEvents, family, battles, topics }

extension SeerahCategoryExtension on SeerahCategory {
  String get displayName {
    switch (this) {
      case SeerahCategory.lifeEvents:
        return 'السيرة النبوية';
      case SeerahCategory.family:
        return 'آل البيت';
      case SeerahCategory.battles:
        return 'الغزوات';
      case SeerahCategory.topics:
        return 'مواضيع ومقتطفات';
    }
  }

  String get assetPath {
    switch (this) {
      case SeerahCategory.lifeEvents:
        return 'assets/json/seerah/seerah1.json';
      case SeerahCategory.family:
        return 'assets/json/seerah/seerah2.json';
      case SeerahCategory.battles:
        return 'assets/json/seerah/seerah3.json';
      case SeerahCategory.topics:
        return 'assets/json/seerah/seerah4.json';
    }
  }
}

class SeerahItem {
  final String id;
  final String title;
  final String content;
  final SeerahCategory category;

  const SeerahItem({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
  });

  factory SeerahItem.fromJson(
    Map<String, dynamic> json,
    SeerahCategory category,
    int index,
  ) {
    return SeerahItem(
      id: '${category.name}_$index',
      title: json['number'] as String? ?? 'بدون عنوان',
      content: json['label'] as String? ?? '',
      category: category,
    );
  }
}
