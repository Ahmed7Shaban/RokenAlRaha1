class HizbModel {
  final int number;
  final int startPage;
  final int endPage;
  final String startSurahName;
  final int startSurahNumber; // Added
  final int startAyahNumber;
  final int endSurahNumber;
  final String endSurahName;
  final int endAyahNumber;

  final List<HizbQuarter> quarters;

  HizbModel({
    required this.number,
    required this.startPage,
    required this.endPage,
    required this.startSurahName,
    required this.startSurahNumber,
    required this.startAyahNumber,
    required this.endSurahNumber,
    required this.endSurahName,
    required this.endAyahNumber,
    required this.quarters,
  });
}

class HizbQuarter {
  final int number;
  final int startPage;
  final String startSurahName;
  final int startSurahNumber; // Added
  final int startAyahNumber;
  final String verseText;

  HizbQuarter({
    required this.number,
    required this.startPage,
    required this.startSurahName,
    required this.startSurahNumber,
    required this.startAyahNumber,
    required this.verseText,
  });
}
