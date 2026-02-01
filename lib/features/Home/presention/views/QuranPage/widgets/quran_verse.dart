import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran/quran.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran/presentation/widgets/ayah_action_sheet.dart';
import '../ayah_context/widgets/ayah_tafsir_sheet.dart';
import '../ayah_context/widgets/ayah_e3rab_sheet.dart';
import '../ayah_context/widgets/ayah_ma3any_sheet.dart';
import '../audio/presentation/widgets/ayah_audio_sheet.dart';
import 'quran_safe_utils.dart';
import '../sharing/ayah_share_service.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran/logic/cubit/ayah_bookmark_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/data/models/reading_theme_model.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran/presentation/widgets/arrival_motivation_overlay.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/last_read/logic/cubit/last_read_cubit.dart';

// ...

void _showVerseMenu({
  required BuildContext context,
  required int surah,
  required int verse,
  required int pageIndex,
  required String content,
  required VoidCallback onFinish,
}) {
  // Capture the cubits from the parent context
  AyahBookmarkCubit? bookmarkCubit;
  ReadingSettingsCubit? readingSettingsCubit;
  LastReadCubit? lastReadCubit;

  try {
    lastReadCubit = context.read<LastReadCubit>();
  } catch (e) {
    debugPrint("Could not find LastReadCubit: $e");
  }

  try {
    bookmarkCubit = context.read<AyahBookmarkCubit>();
  } catch (e) {
    debugPrint("Could not find AyahBookmarkCubit: $e");
  }

  try {
    readingSettingsCubit = context.read<ReadingSettingsCubit>();
  } catch (e) {
    debugPrint("Could not find ReadingSettingsCubit: $e");
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final sheetWidget = AyahActionSheet(
        surahNumber: surah,
        verseNumber: verse,
        verseText: content,
        onTafsir: () {
          Navigator.pop(sheetContext);
          AyahTafsirSheet.show(
            context,
            surahNumber: surah,
            verseNumber: verse,
            initialType: TafsirType.muyassar,
          ).whenComplete(onFinish);
        },

        // onTranslation: () {
        //   Navigator.pop(sheetContext);

        //   debugPrint("--- Translation Request ---");
        //   debugPrint("Surah: $surah, Verse: $verse");

        //   AyahTafsirSheet.show(
        //     context,
        //     surahNumber: surah,
        //     verseNumber: verse,
        //     initialType: TafsirType.sahih,
        //   ).whenComplete(onFinish);
        // },
        onSaveLastRead: () {
          Navigator.pop(sheetContext);
          if (lastReadCubit != null) {
            lastReadCubit.saveLastRead(
              surahNumber: surah,
              ayahNumber: verse,
              surahName: getSurahNameArabic(surah),
              pageNumber: pageIndex,
            );
            ArrivalMotivationOverlay.show(
              context,
              surahName: getSurahNameArabic(surah),
              ayahNumber: verse,
              juzNumber: getJuzNumber(surah, verse),
            );
          }
        },
        onSave: () {
          // Internal toggle handles it, just close or feedback
          Navigator.pop(sheetContext);
        },
        onShare: () {
          Navigator.pop(sheetContext);

          // Fetch current theme colors dynamically
          ReadingTheme currentTheme = ReadingTheme.defaultTheme;
          // Use the captured cubit if available, otherwise try context
          if (readingSettingsCubit != null &&
              readingSettingsCubit.state is ReadingSettingsLoaded) {
            currentTheme =
                (readingSettingsCubit.state as ReadingSettingsLoaded).theme;
          } else {
            try {
              final state = context.read<ReadingSettingsCubit>().state;
              if (state is ReadingSettingsLoaded) {
                currentTheme = state.theme;
              }
            } catch (e) {
              debugPrint("Could not find ReadingSettingsCubit: $e");
            }
          }

          AyahShareService().shareAyahAsImage(
            context,
            surahNumber: surah,
            verseNumber: verse,
            verseText: content,
            backgroundColor: currentTheme.backgroundColor,
            textColor: currentTheme.textColor,
          );
        },
        onCopy: () {
          Navigator.pop(sheetContext);
          Clipboard.setData(ClipboardData(text: content));
          _showFeedback(context, "تم نسخ الآية بنجاح");
        },
        onListen: () {
          Navigator.pop(sheetContext);
          AyahAudioSheet.show(
            context,
            surahNumber: surah,
            verseNumber: verse,
          ).whenComplete(onFinish);
        },
        // onAsbabAlNuzul: () {},
        onWordMeanings: () {
          Navigator.pop(sheetContext);
          AyahMa3anySheet.show(
            context,
            surahNumber: surah,
            verseNumber: verse,
          ).whenComplete(onFinish);
        },
        // onAyahTopic: () {},
        // onDictionary: () {},
        // onItalianTranslation: () {},
        onE3rab: () {
          Navigator.pop(sheetContext);
          AyahE3rabSheet.show(
            context,
            surahNumber: surah,
            verseNumber: verse,
          ).whenComplete(onFinish);
        },
      );

      // Prepare providers list
      final List<BlocProvider> providers = [];
      if (bookmarkCubit != null) {
        providers.add(
          BlocProvider<AyahBookmarkCubit>.value(value: bookmarkCubit),
        );
      }
      if (readingSettingsCubit != null) {
        providers.add(
          BlocProvider<ReadingSettingsCubit>.value(value: readingSettingsCubit),
        );
      }

      if (providers.isNotEmpty) {
        return MultiBlocProvider(providers: providers, child: sheetWidget);
      }
      return sheetWidget;
    },
  ).whenComplete(onFinish);
}

/// Builds a TextSpan for a specific Quran verse with interaction handling.
TextSpan buildQuranVerseSpan({
  required int verseIndex,
  required int surah,
  required int pageIndex,
  required String selectedSpan,
  required Function(String) onSelectedSpanChange,
  required BuildContext context,
  Color? highlightColor,
  Color? textColor,
}) {
  // 1. Generate Verse ID for selection logic
  // The ID format includes a leading space as per existing convention
  final String verseId = " $surah$verseIndex";
  final bool isSelected = selectedSpan == verseId;

  // 2. Prepare Verse Text (Typography Logic)
  // Handles special spacing for the first verse or standard text
  String text;
  if (verseIndex == 1) {
    // Typography fix for the first verse often used in some fonts
    final rawText = getVerseQCF(surah, verseIndex).replaceAll(" ", "");
    if (rawText.isNotEmpty) {
      text = '${rawText.substring(0, 1)}\u200A${rawText.substring(1)}';
    } else {
      text = rawText;
    }
  } else {
    text = getVerseQCF(surah, verseIndex).replaceAll(' ', '');
  }

  // 3. Prepare Text for Copy/Share (Safe Fetch)
  final String contentText = getSafeVerse(surah, verseIndex);

  // 4. Return The Span
  return TextSpan(
    text: text,
    style: TextStyle(
      color: textColor ?? Colors.black,
      height: (pageIndex == 1 || pageIndex == 2) ? 2.h : 1.95.h,
      fontFamily: "QCF_P${pageIndex.toString().padLeft(3, "0")}",
      fontSize: _getFontSize(pageIndex),
      backgroundColor: isSelected
          ? const Color(0xffD4AF37).withOpacity(0.3)
          : (highlightColor?.withOpacity(0.4) ?? Colors.transparent),
    ),
    // 5. Interaction Handler
    recognizer: LongPressGestureRecognizer()
      ..onLongPressStart = (details) {
        // A. Highlight the verse
        onSelectedSpanChange(verseId);

        // B. Show the Actions Menu
        _showVerseMenu(
          context: context,
          surah: surah,
          verse: verseIndex,
          pageIndex: pageIndex,
          content: contentText,
          onFinish: () {
            // C. Clear highlight when menu is closed
            onSelectedSpanChange("");
          },
        );
      },
  );
}

/// Helper function to show the Bottom Sheet with safe context handling
/// (Previously instantiated _showVerseMenu is above)

void _showFeedback(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.right,
        style: const TextStyle(fontFamily: 'Amiri'),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

/// Helper for dynamic font sizing based on page density
double _getFontSize(int pageIndex) {
  if (pageIndex == 1 || pageIndex == 2) return 28.sp;
  if (pageIndex == 145 || pageIndex == 201) return 23.1.sp;
  if (pageIndex == 532 || pageIndex == 533) return 22.5.sp;
  return 23.1.sp;
}

// --- Safe Fetch Helpers ---
// Use generic helper class for reliability

String getSafeVerse(int surah, int verse) =>
    QuranSafeUtils.getSafeVerse(surah, verse);
String getSafeTranslation(int surah, int verse) =>
    QuranSafeUtils.getSafeTranslation(surah, verse);
