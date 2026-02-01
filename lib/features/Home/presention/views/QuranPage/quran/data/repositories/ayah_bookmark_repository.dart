import 'package:shared_preferences/shared_preferences.dart';
import '../models/ayah_bookmark_model.dart';

class AyahBookmarkRepository {
  static const String _storageKey = 'ayah_bookmarks_v1';
  final SharedPreferences _prefs;

  AyahBookmarkRepository(this._prefs);

  static Future<AyahBookmarkRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AyahBookmarkRepository(prefs);
  }

  /// Load all bookmarks from local storage
  List<AyahBookmarkModel> loadBookmarks() {
    final List<String>? jsonList = _prefs.getStringList(_storageKey);
    if (jsonList == null) return [];

    return jsonList
        .map((jsonStr) => AyahBookmarkModel.fromJson(jsonStr))
        .toList();
  }

  /// Save the full list of bookmarks
  Future<void> saveBookmarks(List<AyahBookmarkModel> bookmarks) async {
    final List<String> jsonList = bookmarks.map((b) => b.toJson()).toList();
    await _prefs.setStringList(_storageKey, jsonList);
  }

  /// Add or update a bookmark
  Future<List<AyahBookmarkModel>> addOrUpdateBookmark(
    AyahBookmarkModel bookmark,
  ) async {
    final currentList = loadBookmarks();

    // Remove existing if any (to update color)
    currentList.removeWhere((b) => b.id == bookmark.id);

    // Add new
    currentList.add(bookmark);

    await saveBookmarks(currentList);
    return currentList;
  }

  /// Remove a bookmark
  Future<List<AyahBookmarkModel>> removeBookmark(int surah, int verse) async {
    final currentList = loadBookmarks();
    final id = "${surah}_$verse";

    currentList.removeWhere((b) => b.id == id);

    await saveBookmarks(currentList);
    return currentList;
  }
}
