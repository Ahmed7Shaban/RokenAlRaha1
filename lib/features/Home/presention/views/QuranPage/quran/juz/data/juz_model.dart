class JuzModel {
  final int number;
  final int startPage;
  final int endPage;
  final String startSurahName;
  final int startAyahNumber;
  final String endSurahName;
  final int endAyahNumber;

  const JuzModel({
    required this.number,
    required this.startPage,
    required this.endPage,
    required this.startSurahName,
    required this.startAyahNumber,
    required this.endSurahName,
    required this.endAyahNumber,
  });
}

class JuzProgressModel {
  final int juzNumber;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;

  const JuzProgressModel({
    required this.juzNumber,
    required this.progress,
    required this.isCompleted,
  });
}
