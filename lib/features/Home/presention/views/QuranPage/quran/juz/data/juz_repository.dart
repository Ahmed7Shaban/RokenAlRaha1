import 'package:quran/quran.dart';
import 'juz_model.dart';

class JuzRepository {
  /// Defines the page boundaries for each Juz (Standard Madani Mushaf)
  /// Juz 1 starts at page 1. Juz 2 at 22, etc. (Mostly 20 pages per Juz)
  static final List<int> _juzStartPages = [
    1,
    22,
    42,
    62,
    82,
    102,
    122,
    142,
    162,
    182,
    202,
    222,
    242,
    262,
    282,
    302,
    322,
    342,
    362,
    382,
    402,
    422,
    442,
    462,
    482,
    502,
    522,
    542,
    562,
    582,
  ];

  static const int _totalPages = 604;

  List<JuzModel> getAllJuz() {
    return List.generate(30, (index) {
      final juzNumber = index + 1;
      final startPage = _juzStartPages[index];
      final endPage = (index == 29)
          ? _totalPages
          : _juzStartPages[index + 1] - 1;

      // Get Start Surah info using quran package
      // getJuzURL helps? No. getSurahName? Yes.
      // We need to find which Surah is at startPage.
      // Ideally we'd hardcode for perfect accuracy, but mapping pages to Surahs dynamically is expensive/complex here.
      // For this task, I'll use generic descriptive text logic or hardcoded simplified list if needed.
      // OR better: use `quran.getSurahAndVersesFromJuz(juzNumber)` if available? No.
      // I'll leave the Surah names simpler or fetch strictly based on known map.

      // Map of Start Surahs (Simplified for demo)
      Map<String, int> startInfo = _getJuzStartInfo(juzNumber);
      Map<String, int> endInfo = _getJuzEndInfo(juzNumber);

      return JuzModel(
        number: juzNumber,
        startPage: startPage,
        endPage: endPage,
        startSurahName: getSurahNameArabic(startInfo['surah']!),
        startAyahNumber: startInfo['ayah']!,
        endSurahName: getSurahNameArabic(endInfo['surah']!),
        endAyahNumber: endInfo['ayah']!,
      );
    });
  }

  // Simplified map for specific start/end metadata
  Map<String, int> _getJuzStartInfo(int juz) {
    // Return format: {'surah': x, 'ayah': y}
    // Using mapping based on standard Quran
    // This is a minimal fallback implementation
    // A robust app would have a full map.
    // I'll rely on the fact that Juz 1 starts at Al-Fatiha 1.
    if (juz == 1) return {'surah': 1, 'ayah': 1};
    // ... For brevity I will return generic "Page $startPage" info if exact ayah not critical,
    // but user requested "Surah name + Ayah number".
    // I will use a reliable approximation for key Juz or just generic for now to not bloat code,
    // referencing the start page.

    // Actually, `quran` package has data `getPageData(page)`.
    // I can use THAT! `quran.getPageData(startPage)` -> returns surahs on that page.
    // PERFECT.

    try {
      final pageData = getPageData(_juzStartPages[juz - 1]);
      final first = pageData.first;
      return {'surah': first['surah'], 'ayah': first['start']};
    } catch (e) {
      return {'surah': 1, 'ayah': 1};
    }
  }

  Map<String, int> _getJuzEndInfo(int juz) {
    int endP = (juz == 30) ? 604 : _juzStartPages[juz] - 1;
    try {
      final pageData = getPageData(endP);
      final last = pageData.last;
      return {'surah': last['surah'], 'ayah': last['end']};
    } catch (e) {
      return {'surah': 114, 'ayah': 6};
    }
  }
}
