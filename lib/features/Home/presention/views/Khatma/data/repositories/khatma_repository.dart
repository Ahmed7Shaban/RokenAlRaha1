import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/khatma_model.dart';

class KhatmaRepository {
  static const String _storageKey = 'khatma_plans_v1';

  Future<List<KhatmaModel>> getKhatmas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.map((e) => KhatmaModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveKhatma(KhatmaModel khatma) async {
    final prefs = await SharedPreferences.getInstance();
    List<KhatmaModel> current = await getKhatmas();

    // Check if exists, update it
    final index = current.indexWhere((element) => element.id == khatma.id);
    if (index >= 0) {
      current[index] = khatma;
    } else {
      current.add(khatma);
    }

    await _saveList(prefs, current);
  }

  Future<void> deleteKhatma(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<KhatmaModel> current = await getKhatmas();
    current.removeWhere((element) => element.id == id);
    await _saveList(prefs, current);
  }

  // --- User Stats ---

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('khatma_streak') ?? 0;
  }

  Future<void> updateStreak(DateTime readingDate) async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString('khatma_last_streak_date');
    int currentStreak = prefs.getInt('khatma_streak') ?? 0;

    // Normalize to date only
    final today = DateTime(
      readingDate.year,
      readingDate.month,
      readingDate.day,
    );

    if (lastDateStr != null) {
      final lastDateRaw = DateTime.parse(lastDateStr);
      final lastDate = DateTime(
        lastDateRaw.year,
        lastDateRaw.month,
        lastDateRaw.day,
      );

      final diff = today.difference(lastDate).inDays;

      if (diff == 1) {
        // Consecutive day
        currentStreak++;
      } else if (diff > 1) {
        // Broke streak
        currentStreak = 1;
      }
      // If diff == 0 (same day), do nothing
    } else {
      currentStreak = 1;
    }

    await prefs.setInt('khatma_streak', currentStreak);
    await prefs.setString('khatma_last_streak_date', today.toIso8601String());
  }

  Future<void> incrementTotalCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    int total = prefs.getInt('khatma_total_completed') ?? 0;
    await prefs.setInt('khatma_total_completed', total + 1);
  }

  Future<int> getTotalCompletedSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('khatma_total_completed') ?? 0;
  }

  Future<void> _saveList(
    SharedPreferences prefs,
    List<KhatmaModel> list,
  ) async {
    final String encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
