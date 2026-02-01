import 'package:equatable/equatable.dart';
import '../../data/models/tafsir_model.dart';
import '../../data/models/translation_data.dart';

enum DownloadStatus { idle, downloading, downloaded, error }

class TafsirState extends Equatable {
  final List<TranslationData> availableTafsirs;
  final TranslationData? selectedTafsir;
  // Content indexed by "surah_ayah" key for O(1) access
  final Map<String, TafsirContent> currentTafsirMap;

  // Download tracking
  final Map<String, double> downloadProgress;
  final Map<String, DownloadStatus> downloadStatuses;
  final String? errorMessage;

  const TafsirState({
    this.availableTafsirs = const [],
    this.selectedTafsir,
    this.currentTafsirMap = const {},
    this.downloadProgress = const {},
    this.downloadStatuses = const {},
    this.errorMessage,
  });

  TafsirState copyWith({
    List<TranslationData>? availableTafsirs,
    TranslationData? selectedTafsir,
    Map<String, TafsirContent>? currentTafsirMap,
    Map<String, double>? downloadProgress,
    Map<String, DownloadStatus>? downloadStatuses,
    String? errorMessage,
  }) {
    return TafsirState(
      availableTafsirs: availableTafsirs ?? this.availableTafsirs,
      selectedTafsir: selectedTafsir ?? this.selectedTafsir,
      currentTafsirMap: currentTafsirMap ?? this.currentTafsirMap,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadStatuses: downloadStatuses ?? this.downloadStatuses,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    availableTafsirs,
    selectedTafsir,
    currentTafsirMap,
    downloadProgress,
    downloadStatuses,
    errorMessage,
  ];
}
