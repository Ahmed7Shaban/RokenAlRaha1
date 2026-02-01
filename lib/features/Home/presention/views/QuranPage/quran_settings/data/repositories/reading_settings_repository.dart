import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading_theme_model.dart';

class ReadingSettingsRepository {
  static const String _keyThemeId = 'quran_reading_theme_id';
  static const String _keyScrollMode = 'quran_reading_scroll_mode';

  Future<void> saveThemeId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeId, id);
  }

  Future<ReadingTheme> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_keyThemeId);
    if (id == null) return ReadingTheme.defaultTheme;

    return ReadingTheme.themes.firstWhere(
      (element) => element.id == id,
      orElse: () => ReadingTheme.defaultTheme,
    );
  }

  Future<void> saveScrollMode(int modeIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyScrollMode, modeIndex);
  }

  Future<int> loadScrollMode() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to Vertical (index 0) if not found
    return prefs.getInt(_keyScrollMode) ?? 0;
  }
}
