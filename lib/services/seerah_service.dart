import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/seerah_model.dart';
import 'dart:developer' as developer;

class SeerahService {
  // Singleton pattern
  static final SeerahService _instance = SeerahService._internal();

  factory SeerahService() {
    return _instance;
  }

  SeerahService._internal();

  /// Loads all Seerah data from JSON files.
  Future<Map<SeerahCategory, List<SeerahItem>>> getAllSeerahData() async {
    final Map<SeerahCategory, List<SeerahItem>> data = {};

    for (var category in SeerahCategory.values) {
      try {
        final String jsonString = await rootBundle.loadString(
          category.assetPath,
        );
        final List<dynamic> jsonList = json.decode(jsonString);

        final List<SeerahItem> items = jsonList.asMap().entries.map((entry) {
          return SeerahItem.fromJson(entry.value, category, entry.key);
        }).toList();

        data[category] = items;
      } catch (e) {
        developer.log(
          'Error loading seerah data for category $category: $e',
          name: 'SeerahService',
        );
        data[category] = []; // Return empty list on error
      }
    }

    return data;
  }

  /// Loads items for a specific category
  Future<List<SeerahItem>> getSeerahItems(SeerahCategory category) async {
    try {
      final String jsonString = await rootBundle.loadString(category.assetPath);
      final List<dynamic> jsonList = json.decode(jsonString);

      return jsonList.asMap().entries.map((entry) {
        return SeerahItem.fromJson(entry.value, category, entry.key);
      }).toList();
    } catch (e) {
      developer.log(
        'Error loading seerah data for category $category: $e',
        name: 'SeerahService',
      );
      return [];
    }
  }
}
