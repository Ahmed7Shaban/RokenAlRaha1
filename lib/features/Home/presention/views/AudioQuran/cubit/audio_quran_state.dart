import 'package:equatable/equatable.dart';
import '../../QuranPage/audio/data/reciters_data.dart';

enum AudioPlaybackStatus { initial, loading, playing, paused, stopped, error }

class AudioQuranState extends Equatable {
  final AudioPlaybackStatus status;
  final int currentSurahNumber; // 1-114
  final int currentAyahNumber; // 1-N
  final Reciter selectedReciter;
  final Duration currentPosition;
  final Duration totalDuration;
  final String? errorMessage;

  // Download State
  final int? downloadingSurahId;
  final double downloadProgress;
  final List<int> downloadedSurahs;

  // Volume (0.0 - 1.0)
  final double volume;

  const AudioQuranState({
    this.status = AudioPlaybackStatus.initial,
    this.currentSurahNumber = 1,
    this.currentAyahNumber = 1,
    this.selectedReciter = const Reciter(
      id: "alafasy",
      name: "مشاري العفاسي",
      subfolder: "Alafasy_128kbps",
    ),
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.errorMessage,
    this.downloadingSurahId,
    this.downloadProgress = 0.0,
    this.downloadedSurahs = const [],
    this.volume = 1.0,
  });

  bool get isPlaying => status == AudioPlaybackStatus.playing;

  AudioQuranState copyWith({
    AudioPlaybackStatus? status,
    int? currentSurahNumber,
    int? currentAyahNumber,
    Reciter? selectedReciter,
    Duration? currentPosition,
    Duration? totalDuration,
    String? errorMessage,
    int? downloadingSurahId,
    double? downloadProgress,
    List<int>? downloadedSurahs,
    double? volume,
  }) {
    return AudioQuranState(
      status: status ?? this.status,
      currentSurahNumber: currentSurahNumber ?? this.currentSurahNumber,
      currentAyahNumber: currentAyahNumber ?? this.currentAyahNumber,
      selectedReciter: selectedReciter ?? this.selectedReciter,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadingSurahId: downloadingSurahId ?? this.downloadingSurahId,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadedSurahs: downloadedSurahs ?? this.downloadedSurahs,
      volume: volume ?? this.volume,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentSurahNumber,
    currentAyahNumber,
    selectedReciter,
    currentPosition,
    totalDuration,
    errorMessage,
    downloadingSurahId,
    downloadProgress,
    downloadedSurahs,
    volume,
  ];
}
