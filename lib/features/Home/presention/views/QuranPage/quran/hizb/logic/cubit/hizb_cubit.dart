import 'package:bloc/bloc.dart';
import '../../data/hizb_model.dart';
import '../../data/hizb_repository.dart';
import 'hizb_state.dart';
import '../../../../last_read/data/models/last_read_model.dart';

class HizbCubit extends Cubit<HizbState> {
  final HizbRepository _repository;

  HizbCubit(this._repository) : super(HizbInitial()) {
    _loadInitialHizbs();
  }

  List<HizbModel> _allHizbs = [];

  // Pagination State
  int _currentCount = 0;
  final int _pageSize = 4; // Load chunk size

  /// Initial Load (First 2-4 items)
  Future<void> _loadInitialHizbs() async {
    emit(HizbLoading());
    try {
      final initialData = await _repository.getHizbs(start: 0, limit: 2);
      _allHizbs = initialData; // Reset internal list
      _currentCount = initialData.length;

      emit(HizbLoaded(_mapToUiModels(_allHizbs, null), hasReachedMax: false));
    } catch (e) {
      emit(HizbError("Failed to load Hizbs: $e"));
    }
  }

  /// Load Next Chunk
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! HizbLoaded) return;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    try {
      emit(currentState.copyWith(isLoadingMore: true));

      // Fetch next chunk
      final moreData = await _repository.getHizbs(
        start: _currentCount,
        limit: _pageSize,
      );

      if (moreData.isEmpty) {
        emit(currentState.copyWith(hasReachedMax: true, isLoadingMore: false));
      } else {
        _allHizbs.addAll(moreData);
        _currentCount += moreData.length;

        // Maintain progress state if available
        // Note: We need to re-map new items or all items to preserve progress.
        // For simplicity and correctness with LastRead, we re-map all.
        // Optimization: In a real large list, we would only map new ones.
        // Actually, updateProgress handles re-mapping. We can just emit new list.
        // BUT we don't have lastRead here. We'll use null for now, relying on BlocListener in UI to call updateProgress immediately after if needed.
        // OR better: store `_lastRead` in Cubit state/variable.

        emit(
          HizbLoaded(
            _mapToUiModels(_allHizbs, _lastRead),
            hasReachedMax:
                moreData.length <
                _pageSize, // If less than requested, we are done
            isLoadingMore: false,
          ),
        );
      }
    } catch (e) {
      // In case of error loading more, we just stop loading more state
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  LastReadModel? _lastRead;

  void updateProgress(LastReadModel? lastRead) {
    _lastRead = lastRead;
    // Don't emit new state if we have no data yet
    if (_allHizbs.isEmpty) return;

    // Preserve existing flags
    bool reachedMax = false;
    bool loadingMore = false;

    if (state is HizbLoaded) {
      final oldState = state as HizbLoaded;
      reachedMax = oldState.hasReachedMax;
      loadingMore = oldState.isLoadingMore;
    }

    emit(
      HizbLoaded(
        _mapToUiModels(_allHizbs, lastRead),
        hasReachedMax: reachedMax,
        isLoadingMore: loadingMore,
      ),
    );
  }

  List<HizbUiModel> _mapToUiModels(
    List<HizbModel> models,
    LastReadModel? lastRead,
  ) {
    int lastReadPage = lastRead?.pageNumber ?? 0;

    return models.map((hizb) {
      // Main Hizb Progress
      double progress = 0.0;
      bool isCompleted = false;
      bool isCurrent = false;

      if (lastReadPage > hizb.endPage) {
        progress = 1.0;
        isCompleted = true;
      } else if (lastReadPage >= hizb.startPage) {
        isCurrent = true;
        int totalPages = hizb.endPage - hizb.startPage + 1;
        int readPages = lastReadPage - hizb.startPage + 1;
        progress = (readPages / totalPages).clamp(0.0, 1.0);
      }

      // Quarters Progress
      List<HizbQuarterUiModel> quarterUiModels = [];

      for (int i = 0; i < hizb.quarters.length; i++) {
        final q = hizb.quarters[i];

        // Determine End Page for this quarter
        // Note: For i=0 (Q1), end is (Q2.start-1). For i=3 (Q4), end is hizb.end.
        int qEndPage = (i < hizb.quarters.length - 1)
            ? hizb.quarters[i + 1].startPage - 1
            : hizb.endPage;

        // Calculate progress
        double qProgress = 0.0;
        bool qCompleted = false;
        bool qCurrent = false;

        // Target Logic
        int tPage = q.startPage;
        int tSurah = q.startSurahNumber;
        int tAyah = q.startAyahNumber;

        if (lastReadPage > qEndPage) {
          qProgress = 1.0;
          qCompleted = true;
        } else if (lastReadPage >= q.startPage) {
          qCurrent = true;
          int total = qEndPage - q.startPage + 1;
          int read = lastReadPage - q.startPage + 1;
          qProgress = (read / total).clamp(0.0, 1.0);

          if (lastRead != null) {
            tPage = lastRead.pageNumber;
            tSurah = lastRead.surahNumber;
            tAyah = lastRead.ayahNumber;
          }
        }

        quarterUiModels.add(
          HizbQuarterUiModel(
            data: q,
            progress: qProgress,
            isCompleted: qCompleted,
            isCurrent: qCurrent,
            targetPage: tPage,
            targetSurah: tSurah,
            targetAyah: tAyah,
          ),
        );
      }

      return HizbUiModel(
        data: hizb,
        progress: progress,
        isCompleted: isCompleted,
        isCurrent: isCurrent,
        quarters: quarterUiModels,
      );
    }).toList();
  }
}
