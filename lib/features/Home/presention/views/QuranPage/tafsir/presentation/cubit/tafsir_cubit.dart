import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/tafsir_model.dart';
import '../../data/models/translation_data.dart';
import '../../data/repository/tafsir_download_repository.dart';
import 'tafsir_state.dart';

class TafsirCubit extends Cubit<TafsirState> {
  final TafsirDownloadRepository _repository;

  TafsirCubit(this._repository) : super(const TafsirState());

  Future<void>? _initFuture;

  Future<void> init() async {
    _initFuture = _repository.init();
    await _initFuture;
    final tafsirs = _repository.getAvailableTafsirs();

    // Check if any is already selected or default
    // For now just load the list
    emit(state.copyWith(availableTafsirs: tafsirs));
  }

  Future<void> downloadTafsir(TranslationData tafsir) async {
    if (_initFuture != null) await _initFuture;

    // Prevent double download
    if (state.downloadStatuses[tafsir.name] == DownloadStatus.downloading)
      return;

    // Update status to downloading
    final newStatuses = Map<String, DownloadStatus>.from(
      state.downloadStatuses,
    );
    newStatuses[tafsir.name] = DownloadStatus.downloading;

    emit(state.copyWith(downloadStatuses: newStatuses, errorMessage: null));

    try {
      await _repository.downloadTafsir(
        tafsir,
        onProgress: (progress) {
          final newProgress = Map<String, double>.from(state.downloadProgress);
          newProgress[tafsir.name] = progress;
          emit(state.copyWith(downloadProgress: newProgress));
        },
      );

      // Mark as downloaded per UI state
      tafsir.isDownloaded = true;

      // Save as last downloaded to prioritize it
      _repository.setLastDownloadedKey(tafsir.name);

      // Update status to downloaded
      final doneStatuses = Map<String, DownloadStatus>.from(
        state.downloadStatuses,
      );
      doneStatuses[tafsir.name] = DownloadStatus.downloaded;

      // Re-fetch sorted list from repository
      final updatedTafsirs = _repository.getAvailableTafsirs();

      emit(
        state.copyWith(
          downloadStatuses: doneStatuses,
          availableTafsirs: updatedTafsirs,
        ),
      );

      // Auto-select upon download completion if desired?
      // For now just reordering list.
    } catch (e) {
      final errorStatuses = Map<String, DownloadStatus>.from(
        state.downloadStatuses,
      );
      errorStatuses[tafsir.name] = DownloadStatus.error;

      emit(
        state.copyWith(
          downloadStatuses: errorStatuses,
          errorMessage: "Download failed: $e",
        ),
      );
    }
  }

  Future<void> selectTafsir(TranslationData tafsir) async {
    if (_initFuture != null) await _initFuture;

    if (!tafsir.isDownloaded) {
      emit(state.copyWith(errorMessage: "Please download this Tafsir first"));
      return;
    }

    // Valid selection
    try {
      // Prioritize this tafsir in the list for next time (or immediate refresh)
      _repository.setLastDownloadedKey(tafsir.name);

      // Refresh list sorting
      final updatedTafsirs = _repository.getAvailableTafsirs();
      emit(state.copyWith(availableTafsirs: updatedTafsirs));

      final rawContent = _repository.getTafsirContent(tafsir);
      if (rawContent == null) {
        emit(
          state.copyWith(
            errorMessage: "Content not found even though marked downloaded",
          ),
        );
        return;
      }

      // Parse JSON
      final List<dynamic> jsonList = (rawContent is String)
          ? jsonDecode(rawContent) as List<dynamic>
          : rawContent as List<dynamic>;

      final Map<String, TafsirContent> map = {};

      for (var json in jsonList) {
        // Adapt parsing logic here if needed.
        // We try to be flexible or use the existing model if keys match.
        // If keys are 'sura', 'aya', 'text' (common format), we adapt.

        int sura = 0;
        int aya = 0;
        String text = "";

        if (json is Map) {
          // Check for common keys
          if (json.containsKey('sura'))
            sura = int.tryParse(json['sura'].toString()) ?? 0;
          else if (json.containsKey('surah'))
            sura = int.tryParse(json['surah'].toString()) ?? 0;

          if (json.containsKey('aya'))
            aya = int.tryParse(json['aya'].toString()) ?? 0;
          else if (json.containsKey('ayah'))
            aya = int.tryParse(json['ayah'].toString()) ?? 0;

          if (json.containsKey('text')) {
            text = cleanHtmlTags(json['text'].toString());
          }
        }

        if (sura != 0 && aya != 0) {
          final content = TafsirContent(
            tafsirId: 0, // Not critical
            surahNumber: sura,
            ayahNumber: aya,
            text: text,
          );
          map["${sura}_$aya"] = content;
        }
      }

      emit(
        state.copyWith(
          selectedTafsir: tafsir,
          currentTafsirMap: map,
          errorMessage: null, // Clear error on success
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: "Failed to load tafsir content: $e"));
    }
  }

  TafsirContent? getTafsirForAyah(int surah, int ayah) {
    return state.currentTafsirMap["${surah}_$ayah"];
  }

  String cleanHtmlTags(String htmlString) {
    // Replace <br> and <p> with newlines to preserve formatting
    var text = htmlString.replaceAll(
      RegExp(r'<br\s*/?>', caseSensitive: false),
      '\n',
    );
    text = text.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');

    // Remove all other HTML tags
    return text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}
