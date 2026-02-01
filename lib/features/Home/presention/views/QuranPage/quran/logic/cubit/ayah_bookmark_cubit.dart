import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/ayah_bookmark_model.dart';
import '../../data/repositories/ayah_bookmark_repository.dart';
import 'ayah_bookmark_state.dart';

class AyahBookmarkCubit extends Cubit<AyahBookmarkState> {
  final AyahBookmarkRepository _repository;

  AyahBookmarkCubit(this._repository) : super(AyahBookmarkInitial()) {
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    emit(AyahBookmarkLoading());
    try {
      final bookmarks = _repository.loadBookmarks();
      _emitLoaded(bookmarks);
    } catch (e) {
      emit(AyahBookmarkError("Failed to load bookmarks: $e"));
    }
  }

  Future<void> toggleBookmark(int surah, int verse, int colorValue) async {
    try {
      // Create new model
      final newBookmark = AyahBookmarkModel(
        surahNumber: surah,
        verseNumber: verse,
        colorValue: colorValue,
      );

      final updatedList = await _repository.addOrUpdateBookmark(newBookmark);
      _emitLoaded(updatedList);
    } catch (e) {
      emit(AyahBookmarkError("Failed to save bookmark"));
    }
  }

  Future<void> removeBookmark(int surah, int verse) async {
    try {
      final updatedList = await _repository.removeBookmark(surah, verse);
      _emitLoaded(updatedList);
    } catch (e) {
      emit(AyahBookmarkError("Failed to remove bookmark"));
    }
  }

  void _emitLoaded(List<AyahBookmarkModel> list) {
    // Generate lookup map
    final Map<String, int> colorMap = {};
    for (var b in list) {
      colorMap[b.id] = b.colorValue;
    }
    emit(AyahBookmarkLoaded(list, colorMap));
  }
}
