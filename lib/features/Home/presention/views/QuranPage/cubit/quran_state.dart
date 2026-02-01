part of 'quran_cubit.dart';

enum SearchMode { surahName, surahNumber, ayah }

@immutable
class QuranState {
  final QuranSegment segment; // Current tab
  final List<dynamic> filteredData; // Filtered Surah data
  final List<int> pageNumbers; // Page numbers (kept for legacy/future use)
  final dynamic ayatFiltered; // Search results for Ayahs
  final String searchQuery; // Current query
  final bool isLoading; // Loading state
  final SearchMode searchMode; // Active search mode

  const QuranState({
    this.segment = QuranSegment.surah,
    this.filteredData = const [],
    this.pageNumbers = const [],
    this.ayatFiltered,
    this.searchQuery = "",
    this.isLoading = false,
    this.searchMode = SearchMode.surahName,
  });

  QuranState copyWith({
    QuranSegment? segment,
    List<dynamic>? filteredData,
    List<int>? pageNumbers,
    dynamic ayatFiltered,
    String? searchQuery,
    bool? isLoading,
    SearchMode? searchMode,
  }) {
    return QuranState(
      segment: segment ?? this.segment,
      filteredData: filteredData ?? this.filteredData,
      pageNumbers: pageNumbers ?? this.pageNumbers,
      ayatFiltered: ayatFiltered ?? this.ayatFiltered,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      searchMode: searchMode ?? this.searchMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuranState &&
        other.segment == segment &&
        listEquals(other.filteredData, filteredData) &&
        listEquals(other.pageNumbers, pageNumbers) &&
        other.ayatFiltered == ayatFiltered &&
        other.searchQuery == searchQuery &&
        other.isLoading == isLoading &&
        other.searchMode == searchMode;
  }

  @override
  int get hashCode {
    return segment.hashCode ^
        Object.hashAll(filteredData) ^
        Object.hashAll(pageNumbers) ^
        ayatFiltered.hashCode ^
        searchQuery.hashCode ^
        isLoading.hashCode ^
        searchMode.hashCode;
  }
}
