import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:quran/quran.dart';

part 'quran_state.dart';

enum QuranSegment { surah, hizb, juz, pages }

class QuranCubit extends Cubit<QuranState> {
  // Data is now loaded internally, so we don't require it in constructor
  QuranCubit() : super(const QuranState(isLoading: true)) {
    _loadInitialData();
  }

  dynamic suraJsonData;

  /// تحميل البيانات الأولية
  Future<void> _loadInitialData() async {
    try {
      // Load JSON from assets
      final String jsonString = await rootBundle.loadString(
        'assets/json/surahs.json',
      );

      // Parse in background isolate
      suraJsonData = await compute(_parseJson, jsonString);

      // Emit loaded state
      emit(state.copyWith(filteredData: suraJsonData, isLoading: false));
    } catch (e) {
      debugPrint("Error loading Surah data: $e");
      emit(state.copyWith(isLoading: false));
    }
  }

  static List<dynamic> _parseJson(String jsonString) {
    return jsonDecode(jsonString);
  }

  /// تغيير التبويب (Segment)
  /// تغيير التبويب (Segment)
  void changeSegment(QuranSegment segment) {
    if (state.segment == segment) return;

    dynamic dataForSegment;

    switch (segment) {
      case QuranSegment.surah:
        dataForSegment = suraJsonData;
        break;
      case QuranSegment.hizb:
        dataForSegment = _splitHizb(suraJsonData);
        break;
      case QuranSegment.juz:
        dataForSegment = _splitJuz(suraJsonData);
        break;
      case QuranSegment.pages:
        dataForSegment = [];
        break;
    }

    emit(
      state.copyWith(
        segment: segment,
        filteredData: dataForSegment,
        pageNumbers: [],
        ayatFiltered: null,
        searchQuery: "",
        isLoading: false,
      ),
    );
  }

  // --- Mode Switching ---
  void changeSearchMode(SearchMode mode) {
    if (state.searchMode == mode) return;

    // Clear existing results but keep query to re-search in new mode
    final currentQuery = state.searchQuery;

    // Update mode first
    emit(
      state.copyWith(
        searchMode: mode,
        filteredData: suraJsonData, // Reset surah list
        ayatFiltered: null, // Reset ayah results
      ),
    );

    // Trigger search in new mode if we have a query
    if (currentQuery.isNotEmpty) {
      search(currentQuery);
    }
  }

  /// Main Search Entry Point
  void search(String query) {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    final trimmedQuery = query.trim();

    switch (state.searchMode) {
      case SearchMode.surahName:
        _searchBySurahName(trimmedQuery);
        break;

      case SearchMode.surahNumber:
        _searchBySurahNumber(trimmedQuery);
        break;

      case SearchMode.ayah:
        _searchByAyahText(trimmedQuery);
        break;
    }
  }

  // --- Helper: Search by Surah Name ---
  void _searchBySurahName(String query) {
    final normalizedQuery = _normalizeArabic(query);

    final results = suraJsonData.where((sura) {
      final String englishName = (sura['englishName'] ?? "")
          .toString()
          .toLowerCase();
      final String arabicName = getSurahNameArabic(sura["number"]);
      final normalizedSurah = _normalizeArabic(arabicName);

      return englishName.contains(query.toLowerCase()) ||
          normalizedSurah.contains(normalizedQuery);
    }).toList();

    emit(
      state.copyWith(
        searchQuery: query,
        filteredData: results,
        ayatFiltered: null, // Ensure ayah results are clear
        pageNumbers: [],
      ),
    );
  }

  // --- Helper: Search by Surah Number ---
  void _searchBySurahNumber(String query) {
    List<dynamic> results = [];
    final int? number = int.tryParse(query);

    if (number != null && number >= 1 && number <= 114) {
      // Find exact surah number
      final match = suraJsonData.firstWhere(
        (s) => s["number"] == number,
        orElse: () => null,
      );
      if (match != null) results.add(match);
    }

    emit(
      state.copyWith(
        searchQuery: query,
        filteredData: results,
        ayatFiltered: null,
        pageNumbers: [],
      ),
    );
  }

  // --- Helper: Search by Ayah Text ---
  void _searchByAyahText(String query) {
    final normalizedQuery = _normalizeArabic(query);
    List<Map<String, dynamic>> ayatResults = [];
    int maxResults = 50; // Performance limit

    // Scan all 114 Surahs
    for (int s = 1; s <= 114; s++) {
      int vCount = getVerseCount(s);
      for (int v = 1; v <= vCount; v++) {
        // Normalize text for comparison
        String rawText = getVerse(s, v, verseEndSymbol: false);
        String normalizedText = _normalizeArabic(rawText);

        if (normalizedText.contains(normalizedQuery)) {
          ayatResults.add({
            "surah": s,
            "verse": v,
            "text": rawText,
            "page": getPageNumber(s, v),
          });

          if (ayatResults.length >= maxResults) break;
        }
      }
      if (ayatResults.length >= maxResults) break;
    }

    Map<String, dynamic>? resultWrapper;
    if (ayatResults.isNotEmpty) {
      resultWrapper = {"occurences": ayatResults.length, "result": ayatResults};
    }

    emit(
      state.copyWith(
        searchQuery: query,
        filteredData: [], // Hide Surah list in Ayah mode to focus on verses
        ayatFiltered: resultWrapper,
        pageNumbers: [],
      ),
    );
  }

  String _normalizeArabic(String text) {
    String normalized = text;
    // Remove diacritics
    normalized = normalized.replaceAll(
      RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'),
      '',
    );
    // Normalize Alef
    normalized = normalized.replaceAll(RegExp(r'[أإآ]'), 'ا');
    // Normalize Yaa
    normalized = normalized.replaceAll('ى', 'ي');
    // Normalize Taa Marbuta
    normalized = normalized.replaceAll('ة', 'ه');
    return normalized;
  }

  /// مسح البحث
  /// مسح البحث
  void clearSearch() {
    emit(
      state.copyWith(
        searchQuery: "",
        filteredData: suraJsonData,
        pageNumbers: [],
        ayatFiltered: null,
      ),
    );
  }

  /// تقسيم السور لأحزاب
  List<dynamic> _splitHizb(dynamic data) {
    List<dynamic> hizbList = [];
    for (int i = 0; i < data.length; i += 2) {
      hizbList.add(
        data.sublist(i, (i + 2) > data.length ? data.length : i + 2),
      );
    }
    print("📊 Split into ${hizbList.length} Hizb");
    return hizbList;
  }

  /// تقسيم السور لأجزاء
  List<dynamic> _splitJuz(dynamic data) {
    List<dynamic> juzList = [];
    for (int i = 0; i < data.length; i += 5) {
      juzList.add(data.sublist(i, (i + 5) > data.length ? data.length : i + 5));
    }
    print("📊 Split into ${juzList.length} Juz");
    return juzList;
  }
}
