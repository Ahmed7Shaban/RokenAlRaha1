import 'package:quran/quran.dart';
import 'hizb_model.dart';
import 'hizb_date.dart';

class HizbRepository {
  // Static cache to store models we've already built
  static final List<HizbModel> _cachedModels = [];

  /// Fetches a subset of Hizbs using the static Map source text.
  /// [start] is 0-indexed (offset in the list of Hizbs).
  /// [limit] is number of Hizbs to load.
  Future<List<HizbModel>> getHizbs({int start = 0, int limit = 2}) async {
    // 60 Hizbs total
    const totalHizbs = 60;

    // Determine which Hizbs we need that aren't cached yet
    // We want to reach index (start + limit) ideally.
    int neededCount = start + limit;
    if (neededCount > totalHizbs) neededCount = totalHizbs;

    // Build models sequentially until we fill the cache to needed level
    while (_cachedModels.length < neededCount) {
      int nextHizbNum = _cachedModels.length + 1; // 1-based Hizb Number
      // Synchronous build - no await needed
      HizbModel model = _buildHizbModelFromMap(nextHizbNum);
      _cachedModels.add(model);
    }

    // Return the slice
    if (start >= _cachedModels.length) return [];
    int end = start + limit;
    if (end > _cachedModels.length) end = _cachedModels.length;

    return _cachedModels.sublist(start, end);
  }

  HizbModel _buildHizbModelFromMap(int hizbNum) {
    // 1. Get Data from Map
    final quartersList = quranHizbs[hizbNum];
    if (quartersList == null || quartersList.length != 4) {
      // Return empty placeholder instead of throwing to prevent crash
      return _createEmptyModel(hizbNum);
    }

    // 2. Process Quarters
    List<HizbQuarter> quarters = [];
    for (int i = 0; i < 4; i++) {
      final qMap = quartersList[i];
      String surahName = qMap['surah'];
      int verseNum = qMap['verse'];

      // Robust Name Lookup
      int surahNum = _getSurahNumberByName(surahName);

      // Safety Check: Verse Range
      int totalVerses = getVerseCount(surahNum);
      if (verseNum > totalVerses) {
        verseNum = totalVerses; // Clamp to last verse
      }
      if (verseNum < 1) verseNum = 1;

      // Get Text
      String text = "";
      try {
        text = getVerse(surahNum, verseNum, verseEndSymbol: false);
      } catch (e) {
        text = "Verse text unavailable";
      }

      // Get Page
      int page = getPageNumber(surahNum, verseNum);

      quarters.add(
        HizbQuarter(
          number: i + 1,
          startPage: page,
          startSurahName: surahName,
          startSurahNumber: surahNum,
          startAyahNumber: verseNum,
          verseText: text,
        ),
      );
    }

    // 3. Determine Start/End of Hizb
    // Start is start of Q1
    final q1 = quarters[0];

    // End is defined as: The verse before the start of the Next Hizb.
    // For Hizb 60, it's the end of Quran.
    int endSurahNum;
    int endVerseNum;
    int endPageNum;
    String endSurahName;

    if (hizbNum < 60) {
      final nextHizbList = quranHizbs[hizbNum + 1];
      if (nextHizbList != null) {
        final nextStart = nextHizbList[0];
        int nextSNum = _getSurahNumberByName(nextStart['surah']);
        int nextVNum = nextStart['verse'];

        // Safety clamp for next verse lookup too
        int nextTotal = getVerseCount(nextSNum);
        if (nextVNum > nextTotal) nextVNum = nextTotal;
        if (nextVNum < 1) nextVNum = 1;

        // Decrement by 1 to get end of current
        if (nextVNum > 1) {
          endSurahNum = nextSNum;
          endVerseNum = nextVNum - 1;
        } else {
          endSurahNum = nextSNum - 1;
          if (endSurahNum < 1) endSurahNum = 1;
          endVerseNum = getVerseCount(endSurahNum);
        }
      } else {
        endSurahNum = q1.startSurahNumber;
        endVerseNum = q1.startAyahNumber;
      }
    } else {
      // Hizb 60 End
      endSurahNum = 114;
      endVerseNum = 6;
    }

    endPageNum = getPageNumber(endSurahNum, endVerseNum);
    endSurahName = getSurahNameArabic(endSurahNum);

    return HizbModel(
      number: hizbNum,
      startPage: q1.startPage,
      endPage: endPageNum,
      startSurahName: q1.startSurahName,
      startSurahNumber: q1.startSurahNumber,
      startAyahNumber: q1.startAyahNumber,
      endSurahNumber: endSurahNum,
      endSurahName: endSurahName,
      endAyahNumber: endVerseNum,
      quarters: quarters,
    );
  }

  // --- Helpers ---

  int _getSurahNumberByName(String name) {
    String normalizedInput = _normalize(name);

    for (int i = 1; i <= 114; i++) {
      String nameArabic = getSurahNameArabic(i);
      if (_normalize(nameArabic) == normalizedInput) return i;
    }

    // Fallback: Try removing explicit prefixes if any
    if (name.startsWith("سورة")) {
      return _getSurahNumberByName(name.replaceAll("سورة", "").trim());
    }

    // Fallback to Al-Fatiha (1) to prevent crash
    return 1;
  }

  /// Normalizes Arabic text for flexible comparison
  String _normalize(String text) {
    if (text.isEmpty) return "";
    String res = text;

    // Remove "سورة" prefix and trim
    res = res.replaceAll('سورة', '').trim();

    // Remove Diacritics (Tashkeel)
    res = res.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');

    // Normalize Alefs (أ, إ, آ -> ا)
    res = res.replaceAll(RegExp(r'[أإآ]'), 'ا');

    // Normalize Ya/Alif Maqsura (ى -> ي)
    res = res.replaceAll('ى', 'ي');

    // Normalize Taa Marbuta (ة -> ه)
    res = res.replaceAll('ة', 'ه');

    return res.trim();
  }

  HizbModel _createEmptyModel(int num) {
    return HizbModel(
      number: num,
      startPage: 1,
      endPage: 1,
      startSurahName: "Unknown",
      startSurahNumber: 1,
      startAyahNumber: 1,
      endSurahNumber: 1,
      endSurahName: "Unknown",
      endAyahNumber: 1,
      quarters: [],
    );
  }
}
