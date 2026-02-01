import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/tafsir_model.dart';
import '../../domain/usecases/get_tafsir.dart';

// import '../../domain/usecases/download_tafsir.dart'; // Removed

part 'ayah_tafsir_state.dart';

class AyahTafsirCubit extends Cubit<AyahTafsirState> {
  final GetTafsirUseCase getTafsirUseCase;
  final GetAvailableTafsirsUseCase getAvailableTafsirsUseCase;
  // final DownloadTafsirUseCase downloadTafsirUseCase; // Removed
  // final SearchTafsirUseCase searchTafsirUseCase; // Removed

  // Timer? _searchDebounce; // Removed
  final Map<String, TafsirContent> _memoryCache = {};

  // Static IDs for immediate local recognition
  static const int kMuyassarId = 1;
  static const int kSahihId = 900;

  static final List<TafsirMetaData> kLocalTafsirs = [
    TafsirMetaData(
      id: kMuyassarId,
      name: 'الميسر',
      author: 'مجمع الملك فهد',
      language: 'ar',
      isDownloaded: true,
    ),
    TafsirMetaData(
      id: kSahihId,
      name: 'Saheeh International',
      author: 'Saheeh International',
      language: 'en',
      isDownloaded: true,
    ),
  ];

  AyahTafsirCubit({
    required this.getTafsirUseCase,
    required this.getAvailableTafsirsUseCase,
  }) : super(
         AyahTafsirLoaded(
           availableTafsirs: kLocalTafsirs,
           currentTafsirId: kMuyassarId,
           currentContent: null,
         ),
       );

  @override
  Future<void> close() {
    return super.close();
  }

  void loadInitialData({
    required int surahNumber,
    required int ayahNumber,
    int initialTafsirId = kMuyassarId,
  }) {
    // Determine effective ID
    final effectiveId = kLocalTafsirs.any((t) => t.id == initialTafsirId)
        ? initialTafsirId
        : kMuyassarId;

    // Update state synchronously to set the correct ID
    emit(
      AyahTafsirLoaded(
        availableTafsirs: kLocalTafsirs,
        currentTafsirId: effectiveId,
        currentContent: null,
      ),
    );

    // Fetch content immediately
    fetchTafsir(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      tafsirId: effectiveId,
    );
  }

  Future<void> fetchTafsir({
    required int surahNumber,
    required int ayahNumber,
    int? tafsirId,
  }) async {
    final currentState = state;
    // We strictly maintain Loaded state
    if (currentState is! AyahTafsirLoaded) return;

    final targetId = tafsirId ?? currentState.currentTafsirId;
    final cacheKey = "${targetId}_${surahNumber}_$ayahNumber";

    // 1. Check Memory Cache
    if (_memoryCache.containsKey(cacheKey)) {
      emit(
        currentState.copyWith(
          currentTafsirId: targetId,
          currentContent: _memoryCache[cacheKey],
          errorMessage: null,
        ),
      );
      return;
    }

    // Since we are local only, we can assume "loading" is very fast.
    // However, keeping the architecture consistent.
    if (currentState.currentTafsirId != targetId) {
      emit(currentState.copyWith(currentTafsirId: targetId));
    }

    try {
      final content = await getTafsirUseCase(
        tafsirId: targetId,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
      );

      if (!isClosed) {
        _memoryCache[cacheKey] = content;
        emit(
          AyahTafsirLoaded(
            availableTafsirs: currentState.availableTafsirs,
            currentTafsirId: targetId,
            currentContent: content,
            errorMessage: null,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          AyahTafsirLoaded(
            availableTafsirs: currentState.availableTafsirs,
            currentTafsirId: targetId,
            currentContent: null,
            errorMessage: "Tafsir not available.",
          ),
        );
      }
    }
  }

  // Future<void> downloadTafsir(int tafsirId) async { // Removed
  //   final currentState = state;
  //   if (currentState is! AyahTafsirLoaded) return;
  //   if (currentState.downloadingIds.contains(tafsirId)) return;

  //   emit(
  //     currentState.copyWith(
  //       downloadingIds: [...currentState.downloadingIds, tafsirId],
  //     ),
  //   );

  //   try {
  //     await downloadTafsirUseCase(tafsirId);
  //     // On successful download, you might want to refresh the available tafsirs
  //     // or update the state to reflect the downloaded status.
  //     // For now, we just remove it from downloadingIds.
  //     if (!isClosed) {
  //       emit(
  //         currentState.copyWith(
  //           downloadingIds: currentState.downloadingIds
  //               .where((id) => id != tafsirId)
  //               .toList(),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (!isClosed && state is AyahTafsirLoaded) {
  //       final errorState = state as AyahTafsirLoaded;
  //       emit(
  //         errorState.copyWith(
  //           downloadingIds: errorState.downloadingIds
  //               .where((id) => id != tafsirId)
  //               .toList(),
  //         ),
  //       );
  //     }
  //   }
  // } // Removed
}
