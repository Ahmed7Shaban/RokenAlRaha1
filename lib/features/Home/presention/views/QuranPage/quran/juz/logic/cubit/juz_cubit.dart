import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/juz_repository.dart';
import 'juz_state.dart';

class JuzCubit extends Cubit<JuzState> {
  final JuzRepository _repository;

  JuzCubit(this._repository) : super(JuzInitial()) {
    _loadJuzList();
  }

  void _loadJuzList() {
    emit(JuzLoading());
    try {
      final rawList = _repository.getAllJuz();
      final uiList = rawList
          .map(
            (juz) => JuzUiModel(
              data: juz,
              progress: 0.0,
              isCompleted: false,
              isCurrent: false,
            ),
          )
          .toList();
      emit(JuzLoaded(uiList));
    } catch (e) {
      // In a real app, handle error
      emit(JuzLoaded([]));
    }
  }

  void updateProgress(int lastReadPage) {
    if (state is! JuzLoaded) return;

    final currentList = (state as JuzLoaded).juzList;
    final updatedList = currentList.map((item) {
      final start = item.data.startPage;
      final end = item.data.endPage;

      double progress = 0.0;
      bool isCompleted = false;
      bool isCurrent = false;

      if (lastReadPage > end) {
        progress = 1.0;
        isCompleted = true;
      } else if (lastReadPage < start) {
        progress = 0.0;
      } else {
        // Inside this Juz
        isCurrent = true;
        // Calculate percentage
        // Total pages in this Juz segment
        final totalInJuz = end - start + 1;
        // Pages read in this Juz (inclusive of current page?)
        // If I am on startPage, progress is minimal. If on endPage, max.
        final readInJuz = lastReadPage - start; // 0-indexed relative
        progress = (readInJuz + 1) / totalInJuz; // +1 to count current page
      }

      // Clamp just in case
      if (progress > 1.0) progress = 1.0;
      if (progress < 0.0) progress = 0.0;

      return JuzUiModel(
        data: item.data,
        progress: progress,
        isCompleted: isCompleted,
        isCurrent: isCurrent,
      );
    }).toList();

    emit(JuzLoaded(updatedList));
  }
}
