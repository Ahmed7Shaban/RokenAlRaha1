import 'package:equatable/equatable.dart';
import '../../data/reciters_data.dart';

enum AudioStatus { initial, loading, playing, paused, stopped, error }

class AudioPlayerState extends Equatable {
  final AudioStatus status;
  final Reciter selectedReciter;
  final int currentSurah;
  final int currentVerse;
  final Duration currentPosition;
  final Duration totalDuration;
  final String? errorMessage;

  const AudioPlayerState({
    this.status = AudioStatus.initial,
    required this.selectedReciter,
    required this.currentSurah,
    required this.currentVerse,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.errorMessage,
  });

  factory AudioPlayerState.initial({
    required int initialSurah,
    required int initialVerse,
  }) {
    return AudioPlayerState(
      status: AudioStatus.initial,
      selectedReciter: availableReciters.first,
      currentSurah: initialSurah,
      currentVerse: initialVerse,
    );
  }

  AudioPlayerState copyWith({
    AudioStatus? status,
    Reciter? selectedReciter,
    int? currentSurah,
    int? currentVerse,
    Duration? currentPosition,
    Duration? totalDuration,
    String? errorMessage,
  }) {
    return AudioPlayerState(
      status: status ?? this.status,
      selectedReciter: selectedReciter ?? this.selectedReciter,
      currentSurah: currentSurah ?? this.currentSurah,
      currentVerse: currentVerse ?? this.currentVerse,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      errorMessage:
          errorMessage, // If null passed, it means we clear it? Or keeping it?
      // Usually copyWith null-coalescing keeps old value. To clear, we'd need a specific flag or nullable logic.
      // For simplicity here, if errorMessage is passed as null it remains null/old?
      // Actually standard pattern: errorMessage: errorMessage ?? this.errorMessage.
      // To allow clearing, we can just pass null if the intent is update.
      // But typically we clear error on new actions.
    );
  }

  // Helper to clear error
  AudioPlayerState clearError() {
    return AudioPlayerState(
      status: status,
      selectedReciter: selectedReciter,
      currentSurah: currentSurah,
      currentVerse: currentVerse,
      currentPosition: currentPosition,
      totalDuration: totalDuration,
      errorMessage: null,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedReciter,
    currentSurah,
    currentVerse,
    currentPosition,
    totalDuration,
    errorMessage,
  ];
}
