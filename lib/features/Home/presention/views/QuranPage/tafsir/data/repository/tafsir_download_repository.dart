import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/tafsir/data/models/translation_data.dart';
import '../../../date/translation_sources.dart';
import '../../../date/muyassar.dart';
import '../../../date/sahih_english.dart';

class TafsirDownloadRepository {
  final Dio _dio;
  late Box<dynamic> _tafsirContentBox;
  final String _boxName = 'tafsir_content_box_v2';

  TafsirDownloadRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _tafsirContentBox = await Hive.openBox(_boxName);
    } else {
      _tafsirContentBox = Hive.box(_boxName);
    }
  }

  /// Returns the merged list of available tafsirs:
  /// 1. Built-in (Muyassar, Sahih) - always downloaded.
  /// 2. Downloadable - status checked from Hive.
  List<TranslationData> getAvailableTafsirs() {
    // 1. Built-in Tafsirs
    final builtInTafsirs = [
      TranslationData(
        name: 'التفسير الميسر',
        url: 'internal_muyassar', // Special key
        isDownloaded: true,
      ),
      TranslationData(
        name: 'English - Sahih International',
        url: 'internal_sahih', // Special key
        isDownloaded: true,
      ),
    ];

    // 2. Downloadable Tafsirs
    final downloadableTafsirs = translationsMapList
        .where(
          (map) =>
              map['name'] != 'إعراب كلمات القرآن الكريم' &&
              map['name'] != 'معاني الكلمات',
        )
        .map((map) {
          final key = map['name']!;
          // Skip if it matches built-in name (though names here differ slightly usually)
          if (builtInTafsirs.any((t) => t.name == key)) {
            // If downloadable list has same name, skip or merge.
            // For now, assume lists are distinct enough or we prefer built-in.
          }

          final isDownloaded = _tafsirContentBox.containsKey(key);
          return TranslationData(
            name: key,
            url: map['url']!,
            isDownloaded: isDownloaded,
          );
        })
        .toList();

    // 3. Merge
    final allTafsirs = [...builtInTafsirs, ...downloadableTafsirs];

    // 4. Sort
    final lastDownloadedKey = getLastDownloadedKey();

    allTafsirs.sort((a, b) {
      // 1. Last Downloaded (Top Priority over others, but maybe after E3rab if E3rab is forced?)
      // Actually if E3rab is forced top, the list shows it first.
      // But usually "Last Downloaded" implies the user WANTS that one.
      // Let's keep Last Downloaded as ABSOLUTE priority,
      // UNLESS the user implies "E3rab at the top" means "The List Structure has E3rab first by default".
      // If Last Downloaded is set, that takes precedence for the "Active" one.

      if (a.name == lastDownloadedKey) return -1;
      if (b.name == lastDownloadedKey) return 1;

      // 2. User-Downloaded vs Built-in vs Neither
      // User Downloaded (isDownloaded + !internal)
      // Built-in (internal)
      // Neither (!isDownloaded)

      final aIsInternal = a.url.startsWith('internal_');
      final bIsInternal = b.url.startsWith('internal_');
      final aIsUserDownloaded = a.isDownloaded && !aIsInternal;
      final bIsUserDownloaded = b.isDownloaded && !bIsInternal;

      // Priority: UserDownloaded > BuiltIn > NotDownloaded
      // So checking "UserDownloaded" status
      if (aIsUserDownloaded && !bIsUserDownloaded) return -1;
      if (!aIsUserDownloaded && bIsUserDownloaded) return 1;

      // If both represent the same "downloaded class" (e.g. both user-downloaded or both not),
      // we check built-in next. But wait, if both are UserDownloaded, we are done with that check.
      // If neither are UserDownloaded, we check Built-in.

      if (aIsInternal && !bIsInternal) {
        // Both not user-downloaded. a is built-in (so effectively downloaded), b is not.
        // Built-in > Not Downloaded
        return -1;
      }
      if (!aIsInternal && bIsInternal) {
        return 1;
      }

      // Default: Alphabetical? Or original list order?
      // Since sort is not stable by default in all implementations, but usually is fine.
      // We'll leave original relative order if no other criteria.
      return 0;
    });

    return allTafsirs;
  }

  void setLastDownloadedKey(String key) {
    _tafsirContentBox.put('last_downloaded_tafsir_key', key);
  }

  String? getLastDownloadedKey() {
    return _tafsirContentBox.get('last_downloaded_tafsir_key') as String?;
  }

  /// Downloads the tafsir JSON and saves it to Hive.
  Future<void> downloadTafsir(
    TranslationData tafsir, {
    required Function(double) onProgress,
  }) async {
    try {
      final response = await _dio.get(
        tafsir.url,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      if (response.statusCode == 200) {
        // Assume response.data is the List/Map JSON
        await _tafsirContentBox.put(tafsir.storageKey, response.data);
      } else {
        throw Exception('Failed to download tafsir: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Download error: $e');
    }
  }

  /// Retrieves the tafsir content from Hive or Local Assets.
  /// Returns null if not found.
  dynamic getTafsirContent(TranslationData tafsir) {
    if (tafsir.url == 'internal_muyassar') {
      return muyassar; // Return local list directly
    } else if (tafsir.url == 'internal_sahih') {
      return en_sahih; // Return local list directly
    }

    return _tafsirContentBox.get(tafsir.storageKey);
  }
}
