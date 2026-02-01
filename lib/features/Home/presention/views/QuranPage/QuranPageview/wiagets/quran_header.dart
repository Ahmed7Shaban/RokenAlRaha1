import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/data/models/reading_theme_model.dart';
import 'package:flutter/material.dart';
import 'package:quran/quran.dart';
import 'package:quran/quran.dart' as quran;
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/presentation/widgets/reading_settings_sheet.dart';

class QuranHeader extends StatelessWidget {
  final int pageIndex;
  final dynamic jsonData;

  const QuranHeader({Key? key, required this.pageIndex, required this.jsonData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final String surahName = _getSafeSurahName();

    return BlocBuilder<ReadingSettingsCubit, ReadingSettingsState>(
      builder: (context, state) {
        ReadingTheme currentTheme = ReadingTheme.defaultTheme;
        if (state is ReadingSettingsLoaded) {
          currentTheme = state.theme;
        }
        final Color textColor = currentTheme.textColor;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.02,
            vertical: 8,
          ),
          child: Column(
            children: [
              SizedBox(
                width: screenSize.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // زر العودة
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: 24,
                        color: textColor,
                      ), // Dynamic Color
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                    // اسم السورة
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          surahName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Amiri",
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor, // Dynamic Color
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // زر الإعدادات
                    IconButton(
                      onPressed: () {
                        ReadingSettingsSheet.show(context);
                      },
                      icon: Icon(
                        Icons.settings,
                        size: 24,
                        color: textColor,
                      ), // Dynamic Color
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getSafeSurahName() {
    try {
      // 1. Safety check for pageData
      final pageData = getPageData(pageIndex);
      if (pageData.isEmpty) return "القرآن الكريم";

      // 2. Get first item safely
      final firstItem = pageData[0];
      if (firstItem == null || firstItem is! Map) return "القرآن الكريم";

      // 3. Get Surah Number
      final surahNum = firstItem["surah"];
      if (surahNum == null || surahNum is! int) return "القرآن الكريم";

      // 4. Try to get name from jsonData if available
      if (jsonData != null && jsonData is List && jsonData.isNotEmpty) {
        final index = surahNum - 1;
        if (index >= 0 && index < jsonData.length) {
          final item = jsonData[index];
          if (item != null && item["name"] != null) {
            return item["name"].toString();
          }
        }
      }

      // 5. Fallback to quran package
      return quran.getSurahNameArabic(surahNum);
    } catch (e) {
      debugPrint("Header Error: $e");
      return "القرآن الكريم";
    }
  }
}
