import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/last_read_model.dart';

class LastReadRepository {
  static const String _keyLastRead = 'quran_last_read_ayah';

  Future<void> saveLastRead(LastReadModel model) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(model.toJson());
    await prefs.setString(_keyLastRead, jsonString);
  }

  Future<LastReadModel?> loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyLastRead);
    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return LastReadModel.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }
}
