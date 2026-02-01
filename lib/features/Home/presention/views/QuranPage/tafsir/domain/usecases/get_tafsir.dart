import '../../data/models/tafsir_model.dart';
import '../repositories/tafsir_repository.dart';

class GetTafsirUseCase {
  final TafsirRepository repository;

  GetTafsirUseCase(this.repository);

  Future<TafsirContent> call({
    required int tafsirId,
    required int surahNumber,
    required int ayahNumber,
  }) {
    return repository.getTafsir(
      tafsirId: tafsirId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
  }
}

class GetAvailableTafsirsUseCase {
  final TafsirRepository repository;

  GetAvailableTafsirsUseCase(this.repository);

  Future<List<TafsirMetaData>> call() {
    return repository.getAvailableTafsirs();
  }
}
