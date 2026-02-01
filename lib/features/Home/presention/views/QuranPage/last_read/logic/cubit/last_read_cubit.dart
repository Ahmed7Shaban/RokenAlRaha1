import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/last_read_model.dart';
import '../../data/repositories/last_read_repository.dart';
import 'last_read_state.dart';

class LastReadCubit extends Cubit<LastReadState> {
  final LastReadRepository _repository;

  LastReadCubit(this._repository) : super(LastReadInitial()) {
    loadLastRead();
  }

  Future<void> loadLastRead() async {
    emit(LastReadLoading());
    try {
      final lastRead = await _repository.loadLastRead();
      emit(LastReadLoaded(lastRead));
    } catch (e) {
      emit(LastReadError("Failed to load last read: $e"));
    }
  }

  Future<void> saveLastRead({
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    required int pageNumber,
  }) async {
    try {
      final model = LastReadModel(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        surahName: surahName,
        pageNumber: pageNumber,
      );
      await _repository.saveLastRead(model);
      emit(LastReadLoaded(model));
    } catch (e) {
      emit(LastReadError("Failed to save last read: $e"));
    }
  }
}
