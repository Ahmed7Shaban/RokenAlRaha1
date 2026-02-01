import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/quran.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_view_page.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran/logic/cubit/ayah_bookmark_cubit.dart';

class AyatFilteredListView extends StatelessWidget {
  final dynamic ayatFiltered;
  final String searchQuery;
  final dynamic suraJsonData;

  const AyatFilteredListView({
    super.key,
    required this.ayatFiltered,
    required this.searchQuery,
    required this.suraJsonData,
  });

  @override
  Widget build(BuildContext context) {
    if (ayatFiltered == null || ayatFiltered['result'] == null) {
      return const SizedBox();
    }

    final results = ayatFiltered['result'] as List<dynamic>;

    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: Text(
            "لا توجد نتائج",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16.sp,
              fontFamily: 'Cairo', // Assuming Cairo is available or default
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        final surahNum = item['surah'];
        final verseNum = item['verse'];
        final verseText = item['text']; // Using raw text passed from cubit
        final pageNum = item['page']; // Using page from cubit

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // Determine highlighting key (surah:verse)
                final highlightKey = "$surahNum:$verseNum";

                // Capture cubits
                final readingSettingsCubit = context
                    .read<ReadingSettingsCubit>();
                final ayahBookmarkCubit = context.read<AyahBookmarkCubit>();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: readingSettingsCubit),
                        BlocProvider.value(value: ayahBookmarkCubit),
                      ],
                      child: ScreenUtilInit(
                        designSize: const Size(392.7, 800.7),
                        child: QuranViewPage(
                          shouldHighlightText: true,
                          highlightVerse: highlightKey,
                          jsonData: suraJsonData,
                          pageNumber: pageNum,
                          // Wait, getPageNumber returns 1-604. QuranViewPage pageNumber.
                          // Let's check logic in SurahListSection: getPageNumber(surah['number'], 1).
                          // QuranViewPage calls `PageController(initialPage: index)`.
                          // Usually PageView is 0-indexed.
                          // In SurahListSection: `pageNumber: getPageNumber(...)`.
                          // I should check if QuranViewPage adjusts it.
                          // QuranViewPage: `index = widget.pageNumber;`. `PageController(initialPage: index)`.
                          // `itemCount: totalPagesCount + 1`.
                          // If totalPagesCount is 604?
                          // Let's check `quran` package. `getPageNumber` returns 1-604.
                          // If I pass 1, index is 1. PageView page 1.
                          // Page 0 is likely the cover or something?
                          // QuranPage widget: `if (pageIndex == 0) return Cover...`
                          // So index 1 is Page 1.
                          // Correct. No -1 needed if `quran` package returns 1-based and PageView matches.
                          // Wait, `getPageNumber` for Fatiha is 1.
                          // If I pass 1, `initialPage: 1`. PageView shows item 1.
                          // Item 0 is Cover. Item 1 is Page 1.
                          // So PASS 1-based page number directly.
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Result Text with Highlighting
                    RichText(
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18.sp,
                          color: Colors.black87,
                          height: 1.8,
                        ),
                        children: _buildHighlightedSpans(
                          verseText,
                          searchQuery,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Metadata (Surah Name + Ayah Number)
                    Text(
                      "سورة ${getSurahNameArabic(surahNum)} · آية $verseNum",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontFamily: 'Cairo',
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Highlighting Logic
  List<TextSpan> _buildHighlightedSpans(String originalText, String query) {
    if (query.trim().isEmpty) return [TextSpan(text: originalText)];

    String normalize(String text) {
      return text
          .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
          .replaceAll(RegExp(r'[أإآ]'), 'ا')
          .replaceAll('ى', 'ي')
          .replaceAll('ة', 'ه');
    }

    final normalizedTextBuilder = StringBuffer();
    final List<int> indexMap = [];
    final ignoreReg = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');

    for (int i = 0; i < originalText.length; i++) {
      final char = originalText[i];
      if (ignoreReg.hasMatch(char)) continue;

      String normChar = char;
      if ('أإآ'.contains(char))
        normChar = 'ا';
      else if (char == 'ى')
        normChar = 'ي';
      else if (char == 'ة')
        normChar = 'ه';

      normalizedTextBuilder.write(normChar);
      indexMap.add(i);
    }

    final normalizedText = normalizedTextBuilder.toString();
    final normalizedQuery = normalize(query);

    final spans = <TextSpan>[];
    int currentOrigIndex = 0;
    int currentNormIndex = 0;

    while (true) {
      final matchIdx = normalizedText.indexOf(
        normalizedQuery,
        currentNormIndex,
      );
      if (matchIdx == -1) break;

      final matchLen = normalizedQuery.length;
      final matchEndIdx = matchIdx + matchLen;

      final origStart = indexMap[matchIdx];
      // Calculate end index mapping
      final origEnd = (matchEndIdx < indexMap.length)
          ? indexMap[matchEndIdx]
          : originalText.length;

      // Before match
      if (origStart > currentOrigIndex) {
        spans.add(
          TextSpan(text: originalText.substring(currentOrigIndex, origStart)),
        );
      }

      // Match
      spans.add(
        TextSpan(
          text: originalText.substring(origStart, origEnd),
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            backgroundColor: AppColors.primaryColor.withOpacity(
              0.1,
            ), // Subtle background
          ),
        ),
      );

      currentOrigIndex = origEnd;
      currentNormIndex = matchEndIdx;
    }

    if (currentOrigIndex < originalText.length) {
      spans.add(TextSpan(text: originalText.substring(currentOrigIndex)));
    }

    return spans;
  }
}
