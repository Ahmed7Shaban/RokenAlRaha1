import 'package:quran/quran.dart';

class QuranSplitterLogic {
  /// Splits the page data into chunks based on character count to ensure
  /// images are not too long and verses are not lost.
  ///
  /// [pageData] is the list of JSON objects defining ranges [{surah: 1, start: 1, end: 7}].
  /// [maxCharsPerPart] suggests when to cut the page.
  static List<List<Map<String, dynamic>>> splitPageData(
    List<dynamic> pageData, {
    int maxCharsPerPart = 900, // Tuned for optimal image height
  }) {
    if (pageData.isEmpty) return [];

    // 1. Flatten all verses into a granular list of "Verse Items"
    // Each item: {surah: INT, verse: INT, length: INT}
    List<Map<String, dynamic>> allVerses = [];
    for (var item in pageData) {
      final surah = item['surah'] as int;
      final start = item['start'] as int;
      final end = item['end'] as int;
      for (int v = start; v <= end; v++) {
        final text = getVerse(surah, v);
        allVerses.add({'surah': surah, 'verse': v, 'length': text.length});
      }
    }

    // 2. Group verses into chunks
    List<List<Map<String, dynamic>>> chunksData = [];
    List<Map<String, dynamic>> currentChunkVerses = [];
    int currentChunkLength = 0;

    for (var vItem in allVerses) {
      final vLen = vItem['length'] as int;

      // If adding this verse exceeds limit AND we have at least something in the chunk,
      // then close the current chunk and start a new one.
      // Exception: If a single verse is huge (rare), it goes into a new chunk alone.
      if (currentChunkLength + vLen > maxCharsPerPart &&
          currentChunkVerses.isNotEmpty) {
        chunksData.add(_reconstructRanges(currentChunkVerses));
        currentChunkVerses = [];
        currentChunkLength = 0;
      }

      currentChunkVerses.add(vItem);
      currentChunkLength += vLen;
    }

    // Add remaining
    if (currentChunkVerses.isNotEmpty) {
      chunksData.add(_reconstructRanges(currentChunkVerses));
    }

    return chunksData;
  }

  /// Reconstructs the granular verse list back into range-based JSON format
  /// used by QuranRichText and other widgets.
  /// e.g. [{surah:1, verse:1}, {surah:1, verse:2}] -> [{surah:1, start:1, end:2}]
  static List<Map<String, dynamic>> _reconstructRanges(
    List<Map<String, dynamic>> verseItems,
  ) {
    if (verseItems.isEmpty) return [];

    List<Map<String, dynamic>> resultRanges = [];

    // Start with the first verse
    int currentSurah = verseItems.first['surah'];
    int startVerse = verseItems.first['verse'];
    int lastVerse = startVerse;

    for (int i = 1; i < verseItems.length; i++) {
      final item = verseItems[i];
      final surah = item['surah'] as int;
      final verse = item['verse'] as int;

      // If sequential within the same Surah, extend the range
      if (surah == currentSurah && verse == lastVerse + 1) {
        lastVerse = verse;
      } else {
        // Close previous range
        resultRanges.add({
          'surah': currentSurah,
          'start': startVerse,
          'end': lastVerse,
        });

        // Start new range
        currentSurah = surah;
        startVerse = verse;
        lastVerse = verse;
      }
    }

    // Close final range
    resultRanges.add({
      'surah': currentSurah,
      'start': startVerse,
      'end': lastVerse,
    });

    return resultRanges;
  }
}
