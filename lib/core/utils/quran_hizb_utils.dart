/// Quran Hizb Utilities
///
/// Provides accurate Hizb (1-60) information based on Surah and Verse.
/// The Quran is divided into 30 Juz, and each Juz has 2 Hizbs.
/// Total Hizbs = 60.

/// Mapping of Hizb number (1-60) to its starting Surah and Verse.
const Map<int, ({int surah, int verse})> _hizbStartPoints = {
  1: (surah: 1, verse: 1), // Al-Fatiha 1
  2: (surah: 2, verse: 75), // Al-Baqarah 75
  3: (surah: 2, verse: 142), // Al-Baqarah 142
  4: (surah: 2, verse: 203), // Al-Baqarah 203
  5: (surah: 2, verse: 253), // Al-Baqarah 253
  6: (surah: 3, verse: 15), // Al-Imran 15
  7: (surah: 3, verse: 93), // Al-Imran 93
  8: (surah: 3, verse: 164), // Al-Imran 164
  9: (surah: 4, verse: 24), // An-Nisa 24
  10: (surah: 4, verse: 88), // An-Nisa 88
  11: (surah: 4, verse: 148), // An-Nisa 148
  12: (surah: 5, verse: 27), // Al-Ma'idah 27
  13: (surah: 5, verse: 82), // Al-Ma'idah 82
  14: (surah: 6, verse: 30), // Al-An'am 30
  15: (surah: 6, verse: 111), // Al-An'am 111
  16: (surah: 7, verse: 1), // Al-A'raf 1
  17: (surah: 7, verse: 85), // Al-A'raf 85
  18: (surah: 7, verse: 171), // Al-A'raf 171
  19: (surah: 8, verse: 41), // Al-Anfal 41
  20: (surah: 9, verse: 34), // At-Tawbah 34
  21: (surah: 9, verse: 90), // At-Tawbah 90
  22: (surah: 10, verse: 26), // Yunus 26
  23: (surah: 11, verse: 6), // Hud 6
  24: (surah: 11, verse: 84), // Hud 84
  25: (surah: 12, verse: 53), // Yusuf 53
  26: (surah: 13, verse: 19), // Ar-Ra'd 19
  27: (surah: 15, verse: 1), // Al-Hijr 1
  28: (surah: 16, verse: 51), // An-Nahl 51
  29: (surah: 17, verse: 1), // Al-Isra 1
  30: (surah: 17, verse: 99), // Al-Isra 99
  31: (surah: 18, verse: 75), // Al-Kahf 75
  32: (surah: 20, verse: 1), // Taha 1
  33: (surah: 21, verse: 1), // Al-Anbiya 1
  34: (surah: 22, verse: 1), // Al-Hajj 1
  35: (surah: 23, verse: 1), // Al-Mu'minun 1
  36: (surah: 24, verse: 21), // An-Nur 21
  37: (surah: 25, verse: 21), // Al-Furqan 21
  38: (surah: 26, verse: 111), // Ash-Shu'ara 111
  39: (surah: 27, verse: 54), // An-Naml 54
  40: (surah: 28, verse: 51), // Al-Qasas 51
  41: (surah: 29, verse: 46), // Al-Ankabut 46
  42: (surah: 31, verse: 22), // Luqman 22
  43: (surah: 33, verse: 28), // Al-Ahzab 28
  44: (surah: 34, verse: 24), // Saba 24
  45: (surah: 36, verse: 28), // Ya-Sin 28
  46: (surah: 37, verse: 145), // As-Saffat 145
  47: (surah: 39, verse: 32), // Az-Zumar 32
  48: (surah: 40, verse: 41), // Ghafir 41
  49: (surah: 41, verse: 47), // Fussilat 47
  50: (surah: 43, verse: 24), // Az-Zukhruf 24
  51: (surah: 46, verse: 1), // Al-Ahqaf 1
  52: (surah: 48, verse: 18), // Al-Fath 18
  53: (surah: 51, verse: 31), // Adh-Dhariyat 31
  54: (surah: 55, verse: 1), // Ar-Rahman 1
  55: (surah: 58, verse: 1), // Al-Mujadila 1
  56: (surah: 62, verse: 1), // Al-Jumu'ah 1
  57: (surah: 67, verse: 1), // Al-Mulk 1
  58: (surah: 72, verse: 1), // Al-Jinn 1
  59: (surah: 78, verse: 1), // An-Naba 1
  60: (surah: 87, verse: 1), // Al-A'la 1
};

/// Gets the accurate Hizb number (1-60) for a given Surah and Verse.
/// Returns -1 if inputs are invalid.
int getHizbForSurahVerse(int surahNumber, int verseNumber) {
  if (surahNumber < 1 || surahNumber > 114) return -1;
  if (verseNumber < 1) return -1;

  for (int i = 60; i >= 1; i--) {
    final start = _hizbStartPoints[i]!;
    if (surahNumber > start.surah) {
      return i;
    }
    if (surahNumber == start.surah && verseNumber >= start.verse) {
      return i;
    }
  }

  return 1; // Should not happen for valid quran verses, but fallback
}
