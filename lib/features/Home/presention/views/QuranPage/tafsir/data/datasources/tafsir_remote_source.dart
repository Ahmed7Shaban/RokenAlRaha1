import 'package:dio/dio.dart';
import '../models/tafsir_model.dart';
import 'package:quran/quran.dart' as quran;

abstract class TafsirRemoteSource {
  Future<List<TafsirMetaData>> getTafsirsList();
  Future<TafsirContent> getTafsir(
    int tafsirId,
    int surahNumber,
    int ayahNumber, {
    CancelToken? cancelToken,
  });
  Future<List<TafsirContent>> getSurahTafsir(int tafsirId, int surahNumber);
}

class TafsirRemoteSourceImpl implements TafsirRemoteSource {
  final Dio dio;
  final String _baseUrl = "http://api.quran-tafseer.com";

  TafsirRemoteSourceImpl({required this.dio});

  Future<T> _retry<T>(Future<T> Function() fn, {int retries = 2}) async {
    try {
      return await fn();
    } catch (e) {
      if (retries > 0) {
        await Future.delayed(const Duration(milliseconds: 500));
        return _retry(fn, retries: retries - 1);
      }
      rethrow;
    }
  }

  @override
  Future<List<TafsirMetaData>> getTafsirsList() async {
    return _retry(() async {
      final response = await dio.get('$_baseUrl/tafseer');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => TafsirMetaData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tafsirs list');
      }
    });
  }

  @override
  Future<TafsirContent> getTafsir(
    int tafsirId,
    int surahNumber,
    int ayahNumber, {
    CancelToken? cancelToken,
  }) async {
    return _retry(() async {
      final response = await dio.get(
        '$_baseUrl/tafseer/$tafsirId/$surahNumber/$ayahNumber',
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        return TafsirContent.fromJson(response.data);
      } else {
        throw Exception('Failed to load tafsir content');
      }
    }, retries: 1); // Less retries for content to stay snappy or fail fast
  }

  @override
  Future<List<TafsirContent>> getSurahTafsir(
    int tafsirId,
    int surahNumber,
  ) async {
    return _retry(() async {
      int versesCount = quran.getVerseCount(surahNumber);
      final response = await dio.get(
        '$_baseUrl/tafseer/$tafsirId/$surahNumber/1/$versesCount',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => TafsirContent.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load surah tafsir');
      }
    });
  }
}
