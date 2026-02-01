import 'package:quran/quran.dart' as quran;

class QuranSafeUtils {
  /// Safely fetches the Arabic text of a verse.
  /// Returns a fallback message if the Surah or Verse number is invalid.
  static String getSafeVerse(int surah, int verse) {
    try {
      if (surah < 1 || surah > 114) return "سورة غير موجودة";
      int verseCount = quran.getVerseCount(surah);
      if (verse < 1 || verse > verseCount) return "آية غير موجودة";

      return quran.getVerse(surah, verse);
    } catch (e) {
      return "الآية غير موجودة";
    }
  }

  /// Safely fetches the English translation of a verse.
  /// Returns a fallback message if the Surah or Verse number is invalid.
  static String getSafeTranslation(int surah, int verse) {
    try {
      if (surah < 1 || surah > 114) return "Invalid Surah";
      int verseCount = quran.getVerseCount(surah);
      if (verse < 1 || verse > verseCount) return "Translation unavailable";

      return quran.getVerseTranslation(surah, verse);
    } catch (e) {
      return "Translation unavailable";
    }
  }

  /// Safely gets Surah Name in Arabic
  static String getSafeSurahName(int surah) {
    try {
      if (surah < 1 || surah > 114) return "";
      return quran.getSurahNameArabic(surah);
    } catch (e) {
      return "";
    }
  }
}
