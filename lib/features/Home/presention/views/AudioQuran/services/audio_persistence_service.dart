import 'package:hive_flutter/hive_flutter.dart';

class AudioPersistenceService {
  static const String _boxName = 'audio_quran_persistence';
  static const String _keySurah = 'last_surah';
  static const String _keyAyah = 'last_ayah';
  static const String _keyReciterId = 'last_reciter_id';
  static const String _keyPosition = 'last_position_ms';

  Box? _box;

  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
  }

  Future<void> saveState({
    required int surah,
    required int ayah,
    required String reciterId,
    required int positionMs,
  }) async {
    await init();
    await _box!.put(_keySurah, surah);
    await _box!.put(_keyAyah, ayah);
    await _box!.put(_keyReciterId, reciterId);
    await _box!.put(_keyPosition, positionMs);
  }

  Future<Map<String, dynamic>?> loadState() async {
    await init();
    if (!_box!.containsKey(_keySurah)) return null;

    return {
      'surah': _box!.get(_keySurah, defaultValue: 1),
      'ayah': _box!.get(_keyAyah, defaultValue: 1),
      'reciterId': _box!.get(_keyReciterId, defaultValue: 'alafasy'),
      'positionMs': _box!.get(_keyPosition, defaultValue: 0),
    };
  }
}
