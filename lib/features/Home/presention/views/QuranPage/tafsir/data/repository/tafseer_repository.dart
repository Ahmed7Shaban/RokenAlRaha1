import '../../domain/repositories/tafsir_repository.dart';
import '../datasources/tafsir_local_source.dart';
import '../models/tafsir_model.dart';

class TafseerRepositoryImpl implements TafsirRepository {
  final TafsirLocalSource localSource;

  TafseerRepositoryImpl({required this.localSource});

  Future<void> init() async {
    await localSource.init();
  }

  @override
  Future<List<TafsirMetaData>> getAvailableTafsirs() async {
    await init();
    return localSource.getAvailableTafsirs();
  }

  @override
  Future<TafsirContent> getTafsir({
    required int tafsirId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    await init();

    // Strictly Local
    final localContent = await localSource.getTafsir(
      tafsirId: tafsirId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );

    if (localContent != null) {
      return localContent;
    }

    throw Exception("Tafsir content not found locally.");
  }
}
