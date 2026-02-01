import 'package:hive_flutter/hive_flutter.dart';

import '../models/tafsir_model.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/date/muyassar.dart'
    as muyassar_data;
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/date/sahih_english.dart'
    as sahih_data;

abstract class TafsirLocalSource {
  Future<void> init();
  Future<List<TafsirMetaData>> getAvailableTafsirs();
  Future<void> cacheTafsirsList(List<TafsirMetaData> list);
  Future<TafsirContent?> getTafsir({
    required int tafsirId,
    required int surahNumber,
    required int ayahNumber,
  });
  Future<void> saveTafsir(TafsirContent content);
  Future<void> saveBulkTafsir(List<TafsirContent> contents);
  Future<bool> isTafsirDownloaded(int tafsirId);
  Future<void> setTafsirDownloaded(int tafsirId);
  Future<List<TafsirContent>> searchTafsir(
    String query, {
    required List<int> downloadedIds,
  });
}

class TafsirLocalSourceImpl implements TafsirLocalSource {
  static const String metaBoxName = 'tafsir_meta_box';
  static const String contentBoxName = 'tafsir_content_box';

  // Hardcoded IDs for local assets
  static const int kMuyassarId = 1;
  static const int kSahihId =
      900; // Arbitrary distinct ID for Sahih if not from API

  Box<TafsirMetaData>? _metaBox;
  Box<TafsirContent>? _contentBox;

  @override
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(TafsirMetaDataAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(TafsirContentAdapter());
    }

    _metaBox = await Hive.openBox<TafsirMetaData>(metaBoxName);
    _contentBox = await Hive.openBox<TafsirContent>(contentBoxName);
  }

  @override
  Future<List<TafsirMetaData>> getAvailableTafsirs() async {
    // Strictly return only the two types stored locally as requested
    return [
      TafsirMetaData(
        id: kMuyassarId,
        name: 'التفسير الميسر',
        author: 'نخبة من العلماء',
        language: 'ar',
        isDownloaded: true,
      ),
      TafsirMetaData(
        id: kSahihId,
        name: 'Sahih International',
        author: 'Sahih International',
        language: 'en',
        isDownloaded: true,
      ),
    ];
  }

  @override
  Future<void> cacheTafsirsList(List<TafsirMetaData> list) async {
    // We only update the ones from API, preserving local hardcoded status if any
    // Map to preserve existing `isDownloaded` state if we are refreshing the list
    final values = _metaBox?.values.toList() ?? <TafsirMetaData>[];
    final existing = {for (var e in values) e.id: e};

    for (var item in list) {
      // If retrieving from API, it might overwrite our local "isDownloaded" status if we aren't careful
      // But API list doesn't have `isDownloaded`.
      // This method assumes the incoming list handles that or we merge.
      if (existing.containsKey(item.id)) {
        final old = existing[item.id];
        if (old != null) {
          item.isDownloaded = old.isDownloaded;
        }
      }
      await _metaBox?.put(item.id, item);
    }
  }

  @override
  Future<TafsirContent?> getTafsir({
    required int tafsirId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    // Check Local Static Files
    if (tafsirId == kMuyassarId) {
      // Access muyassar list safely
      // Importing 'muyassar' variable from the file
      // Assuming 'muyassar' is a List in the imported file
      try {
        final entry = muyassar_data.muyassar.firstWhere(
          (e) => e['sura'] == surahNumber && e['aya'] == ayahNumber,
          orElse: () => null,
        );
        if (entry != null) {
          return TafsirContent(
            tafsirId: tafsirId,
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            text: entry['text'].toString(),
          );
        }
      } catch (e) {
        // Fallback
      }
    } else if (tafsirId == kSahihId) {
      try {
        final entry = sahih_data.en_sahih.firstWhere(
          (e) => e['sura'] == surahNumber && e['aya'] == ayahNumber,
          orElse: () => null,
        );
        if (entry != null) {
          return TafsirContent(
            tafsirId: tafsirId,
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            text: entry['text'].toString(),
          );
        }
      } catch (e) {
        // Fallback
      }
    }

    // Check Hive
    final key = '${tafsirId}_${surahNumber}_$ayahNumber';
    // _contentBox uses dynamic keys usually, let's use String keys for explicit control
    // But Hive keys can be anything.
    // However, Hive objects are stored. If we use `put(key, value)`, we can `get(key)`.
    // My box is open as Box<TafsirContent>.

    // CAUTION: The user required "Cache key format: tafseerId_surah_ayah"
    // So I must use this string key.

    return _contentBox?.get(key);
  }

  @override
  Future<void> saveTafsir(TafsirContent content) async {
    final key =
        '${content.tafsirId}_${content.surahNumber}_${content.ayahNumber}';
    await _contentBox?.put(key, content);
  }

  @override
  Future<void> saveBulkTafsir(List<TafsirContent> contents) async {
    final map = <String, TafsirContent>{};
    for (var c in contents) {
      final key = '${c.tafsirId}_${c.surahNumber}_${c.ayahNumber}';
      map[key] = c;
    }
    await _contentBox?.putAll(map);
  }

  @override
  Future<bool> isTafsirDownloaded(int tafsirId) async {
    if (tafsirId == kMuyassarId || tafsirId == kSahihId) return true;
    final meta = _metaBox?.get(tafsirId);
    return meta?.isDownloaded ?? false;
  }

  @override
  Future<void> setTafsirDownloaded(int tafsirId) async {
    final meta = _metaBox?.get(tafsirId);
    if (meta != null) {
      meta.isDownloaded = true;
      await meta.save();
    }
  }

  @override
  Future<List<TafsirContent>> searchTafsir(
    String query, {
    required List<int> downloadedIds,
  }) async {
    final results = <TafsirContent>[];
    if (query.isEmpty) return results;

    // Search Local Static
    if (downloadedIds.contains(kMuyassarId)) {
      final matches = muyassar_data.muyassar
          .where((e) => e['text'].toString().contains(query))
          .take(50); // Limit?
      for (var m in matches) {
        results.add(
          TafsirContent(
            tafsirId: kMuyassarId,
            surahNumber: m['sura'],
            ayahNumber: m['aya'],
            text: m['text'].toString(),
          ),
        );
      }
    }

    if (downloadedIds.contains(kSahihId)) {
      final matches = sahih_data.en_sahih
          .where((e) => e['text'].toString().contains(query))
          .take(50);
      for (var m in matches) {
        results.add(
          TafsirContent(
            tafsirId: kSahihId,
            surahNumber: m['sura'],
            ayahNumber: m['aya'],
            text: m['text'].toString(),
          ),
        );
      }
    }

    // Search Hive
    // Searching entire hive box might be slow if huge.
    // Hive isn't a SQL DB.
    // But "Tafsir Search: Update results instantly (no API calls). Work across all downloaded Tafsir".
    // 6000 verses * 10 tafsirs = 60,000 items. Iterating in memory is feasible in Dart (~ms).
    // _contentBox.values is an Iterable.

    final otherIds = downloadedIds
        .where((id) => id != kMuyassarId && id != kSahihId)
        .toSet();

    if (otherIds.isNotEmpty) {
      final matches = _contentBox?.values.where((c) {
        return otherIds.contains(c.tafsirId) && c.text.contains(query);
      });
      if (matches != null) {
        results.addAll(matches);
      }
    }

    return results;
  }
}
