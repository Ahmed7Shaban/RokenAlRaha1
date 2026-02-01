import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran/quran.dart' as quran;

import '../../data/reciters_data.dart';
import 'audio_player_state.dart';

class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final AudioPlayer _audioPlayer;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;

  AudioPlayerCubit({required int initialSurah, required int initialVerse})
    : _audioPlayer = AudioPlayer(),
      super(
        AudioPlayerState.initial(
          initialSurah: initialSurah,
          initialVerse: initialVerse,
        ),
      ) {
    _initAudioListeners();
  }

  void _initAudioListeners() {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((
      playerState,
    ) {
      final processingState = playerState.processingState;
      final playing = playerState.playing;

      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        emit(state.copyWith(status: AudioStatus.loading));
      } else if (playing && processingState == ProcessingState.ready) {
        emit(state.copyWith(status: AudioStatus.playing));
      } else if (!playing && processingState == ProcessingState.ready) {
        emit(state.copyWith(status: AudioStatus.paused));
      } else if (processingState == ProcessingState.completed) {
        emit(state.copyWith(status: AudioStatus.stopped));
        // Optional: Auto-play next verse? User didn't strictly ask, but it's nice.
        // Let's stick to requirements: buttons to next/prev.
      }
    });

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      emit(state.copyWith(currentPosition: position));
    });

    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        emit(state.copyWith(totalDuration: duration));
      }
    });
  }

  Future<void> loadAndPlayVerse() async {
    try {
      emit(state.copyWith(status: AudioStatus.loading).clearError());

      // Construct URL
      // http://everyayah.com/data/{Reciter}/{Surah3}{Ayah3}.mp3
      final subfolder = state.selectedReciter.subfolder;
      final surahStr = state.currentSurah.toString().padLeft(3, '0');
      final verseStr = state.currentVerse.toString().padLeft(3, '0');
      final url =
          "https://everyayah.com/data/$subfolder/$surahStr$verseStr.mp3";

      // Just Audio usually handles caching if we use LockCachingAudioSource but that requires external package just_audio_cache
      // Or we can rely on standard HTTP caching if headers allow.
      // For this implementation, we stream directly.

      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
    } catch (e) {
      emit(
        state.copyWith(
          status: AudioStatus.error,
          errorMessage: "تعذر تشغيل الصوت: $e",
        ),
      );
    }
  }

  void changeReciter(Reciter reciter) {
    if (state.selectedReciter == reciter) return;
    emit(state.copyWith(selectedReciter: reciter));
    if (state.status == AudioStatus.playing ||
        state.status == AudioStatus.loading) {
      loadAndPlayVerse();
    }
  }

  void togglePlayPause() {
    if (state.status == AudioStatus.playing) {
      _audioPlayer.pause();
    } else if (state.status == AudioStatus.paused) {
      _audioPlayer.play();
    } else {
      loadAndPlayVerse();
    }
  }

  void nextVerse() {
    int nextV = state.currentVerse + 1;
    int nextS = state.currentSurah;

    if (nextV > quran.getVerseCount(nextS)) {
      nextS++;
      if (nextS > 114) return; // End of Quran
      nextV = 1;
    }

    emit(state.copyWith(currentSurah: nextS, currentVerse: nextV));
    loadAndPlayVerse();
  }

  void prevVerse() {
    int prevV = state.currentVerse - 1;
    int prevS = state.currentSurah;

    if (prevV < 1) {
      prevS--;
      if (prevS < 1) return; // Start of Quran
      prevV = quran.getVerseCount(prevS);
    }

    emit(state.copyWith(currentSurah: prevS, currentVerse: prevV));
    loadAndPlayVerse();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
