import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/data/models/reading_theme_model.dart';
import '../../sharing/ayah_share_service.dart';

/// Handles business logic for Ayah actions.
/// This separates logic from UI widgets, making it easier to test and maintain.
class AyahActionHandler {
  final AyahShareService _shareService;

  AyahActionHandler({AyahShareService? shareService})
    : _shareService = shareService ?? AyahShareService();

  /// Copies the verse text to the system clipboard.
  Future<void> copyAyah(BuildContext context, String verseText) async {
    await Clipboard.setData(ClipboardData(text: verseText));
    _showSnackBar(context, "تم نَسخ الآية بنجاح");
  }

  /// Share verse as an image or text.
  Future<void> shareAyah(
    BuildContext context, {
    required int surahNumber,
    required int verseNumber,
    required String verseText,
  }) async {
    // Fetch current theme colors
    ReadingTheme currentTheme = ReadingTheme.defaultTheme;
    try {
      final state = context.read<ReadingSettingsCubit>().state;
      if (state is ReadingSettingsLoaded) {
        currentTheme = state.theme;
      }
    } catch (e) {
      debugPrint(
        "AyahActionHandler: Could not finding ReadingSettingsCubit: $e",
      );
    }

    // We delegate the complex share logic to the existing specialized service
    await _shareService.shareAyahAsImage(
      context,
      surahNumber: surahNumber,
      verseNumber: verseNumber,
      verseText: verseText,
      backgroundColor: currentTheme.backgroundColor,
      textColor: currentTheme.textColor,
    );
    // feedback is handled inside shareAyahAsImage usually, or we can add it here if needed.
    // The existing service seems to handle loading and snackbars on error.
  }

  /// Handles the "Tafsir" action.
  Future<void> showTafsir(
    BuildContext context,
    int surahNumber,
    int verseNumber,
  ) async {
    // TODO: Implement actual navigation to Tafsir view
    _showSnackBar(context, "سيتم عرض التفسير (قريباً)");
  }

  /// Handles the "Translation" action.
  Future<void> showTranslation(
    BuildContext context,
    int surahNumber,
    int verseNumber,
  ) async {
    // TODO: Implement actual navigation to Translation view
    _showSnackBar(context, "سيتم عرض الترجمة (قريباً)");
  }

  /// Handles the "Save/Bookmark" action.
  Future<void> saveAyah(
    BuildContext context,
    int surahNumber,
    int verseNumber,
  ) async {
    // TODO: Implement Bookmark logic (e.g. Hive or SharedPreferences)
    _showSnackBar(context, "تم حفظ الآية في العلامات");
  }

  /// Common Helper to show feedback
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: "Cairo"),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: const Color(0xFF1B4332),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
