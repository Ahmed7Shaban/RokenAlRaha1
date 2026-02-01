import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/quran.dart';
import 'basmallah.dart';
import 'header_widget.dart';
import 'quran_verse.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran/logic/cubit/ayah_bookmark_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran/logic/cubit/ayah_bookmark_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/data/models/reading_theme_model.dart';

class QuranRichText extends StatelessWidget {
  final int pageIndex;
  final dynamic jsonData;
  final String selectedSpan;
  final Function(String) onSelectedSpanChange;
  final List<dynamic>? customData;

  const QuranRichText({
    Key? key,
    required this.pageIndex,
    required this.jsonData,
    required this.selectedSpan,
    required this.onSelectedSpanChange,
    this.customData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadingSettingsCubit, ReadingSettingsState>(
      builder: (context, readingState) {
        ReadingTheme currentTheme = ReadingTheme.defaultTheme;
        if (readingState is ReadingSettingsLoaded) {
          currentTheme = readingState.theme;
        }

        return BlocBuilder<AyahBookmarkCubit, AyahBookmarkState>(
          builder: (context, bookmarkState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                width: double.infinity,
                child: RichText(
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  locale: const Locale("ar"),
                  text: TextSpan(
                    style: TextStyle(
                      color: currentTheme.textColor, // Dynamic Text Color
                      fontSize: 30.sp.toDouble(),
                    ),
                    children: (customData ?? getPageData(pageIndex)).expand((
                      e,
                    ) {
                      List<InlineSpan> spans = [];

                      for (var i = e["start"]; i <= e["end"]; i++) {
                        // Header
                        if (i == 1) {
                          spans.add(
                            WidgetSpan(
                              child: HeaderWidget(e: e, jsonData: jsonData),
                            ),
                          );
                          if (pageIndex != 187 && pageIndex != 1) {
                            spans.add(WidgetSpan(child: Basmallah(index: 0)));
                          }
                          if (pageIndex == 187)
                            spans.add(
                              WidgetSpan(child: SizedBox(height: 10.h)),
                            );
                        }

                        // Highlight Highlight
                        Color? highlightColor;
                        if (bookmarkState is AyahBookmarkLoaded) {
                          highlightColor = bookmarkState.getColor(
                            e["surah"],
                            i,
                          );
                        }

                        spans.add(
                          buildQuranVerseSpan(
                            verseIndex: i,
                            surah: e["surah"],
                            pageIndex: pageIndex,
                            selectedSpan: selectedSpan,
                            onSelectedSpanChange: onSelectedSpanChange,
                            context: context,
                            highlightColor: highlightColor,
                            textColor: currentTheme
                                .textColor, // Pass text color if needed by span builder
                          ),
                        );
                      }

                      return spans;
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
