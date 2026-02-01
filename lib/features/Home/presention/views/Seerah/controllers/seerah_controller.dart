import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../models/seerah_model.dart';
import '../../../../../../services/seerah_service.dart';

class SeerahController {
  final SeerahService _service = SeerahService();

  // Cache
  Map<SeerahCategory, List<SeerahItem>> _cachedData = {};

  /// Loads items for a specific category
  Future<List<SeerahItem>> getItems(SeerahCategory category) async {
    if (_cachedData.containsKey(category)) {
      return _cachedData[category]!;
    }
    final items = await _service.getSeerahItems(category);
    _cachedData[category] = items;
    return items;
  }

  /// Loads ALL data (useful for search or stats)
  Future<void> loadAllData() async {
    if (_cachedData.length == SeerahCategory.values.length) return;
    _cachedData = await _service.getAllSeerahData();
  }

  Future<List<SeerahItem>> search(String query) async {
    await loadAllData();
    final List<SeerahItem> results = [];
    _cachedData.forEach((key, value) {
      results.addAll(
        value.where(
          (item) => item.title.contains(query) || item.content.contains(query),
        ),
      );
    });
    return results;
  }

  // -------------------------
  // Progress & Interaction
  // -------------------------

  Future<List<String>> getReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    // Use new key for v2
    return prefs.getStringList('seerah_read_ids_v2') ?? [];
  }

  Future<void> markAsRead(String id, bool isRead) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> readList = prefs.getStringList('seerah_read_ids_v2') ?? [];

    if (isRead) {
      if (!readList.contains(id)) {
        readList.add(id);
      }
    } else {
      readList.remove(id);
    }
    await prefs.setStringList('seerah_read_ids_v2', readList);
  }

  Future<List<String>> getBookmarkIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('seerah_bookmark_ids_v2') ?? [];
  }

  Future<void> toggleBookmark(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarkList =
        prefs.getStringList('seerah_bookmark_ids_v2') ?? [];

    if (bookmarkList.contains(id)) {
      bookmarkList.remove(id);
    } else {
      bookmarkList.add(id);
    }
    await prefs.setStringList('seerah_bookmark_ids_v2', bookmarkList);
  }

  Future<int> getShareCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('seerah_share_count') ?? 0;
  }

  Future<void> incrementShareCount() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt('seerah_share_count') ?? 0;
    await prefs.setInt('seerah_share_count', current + 1);
  }

  // -------------------------
  // Helpers for Badges
  // -------------------------

  Future<int> getTotalCount() async {
    await loadAllData();
    int total = 0;
    _cachedData.values.forEach((list) => total += list.length);
    return total;
  }

  bool checkCategoryCompleted(SeerahCategory category, List<String> readIds) {
    if (!_cachedData.containsKey(category)) return false;
    final items = _cachedData[category]!;
    if (items.isEmpty) return false;
    return items.every((e) => readIds.contains(e.id));
  }
}
