import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> setBool(String key, bool value) async {
    if (_prefs == null) await init();
    return await _prefs!.setBool(key, value);
  }

  bool getBool(String key) {
    if (_prefs == null) {
      // Logic decision: If prefs are not loaded, we assume false or maybe throw an error?
      // Ideally init() should be called in main.dart.
      // But for safety, we return false (default for booleans usually).
      return false;
    }
    return _prefs!.getBool(key) ?? false;
  }

  // Add more methods as needed (getString, setString, remove, etc.)
  Future<bool> setString(String key, String value) async {
    if (_prefs == null) await init();
    return await _prefs!.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<bool> remove(String key) async {
    if (_prefs == null) await init();
    return await _prefs!.remove(key);
  }

  Future<bool> clear() async {
    if (_prefs == null) await init();
    return await _prefs!.clear();
  }
}
