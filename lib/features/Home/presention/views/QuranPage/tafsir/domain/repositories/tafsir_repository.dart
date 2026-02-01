import '../../data/models/tafsir_model.dart';

abstract class TafsirRepository {
  Future<List<TafsirMetaData>> getAvailableTafsirs();
  Future<TafsirContent> getTafsir({
    required int tafsirId,
    required int surahNumber,
    required int ayahNumber,
  });
}
