import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:quran/quran.dart' as quran;
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/audio/data/reciters_data.dart';
import 'audio_quran_state.dart';

class AudioQuranCubit extends Cubit<AudioQuranState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Connectivity _connectivity = Connectivity();
  final Dio _dio = Dio();

  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _currentIndexSubscription;
  StreamSubscription? _connectivitySubscription;

  bool _hasInternet = true;
  int _retryAttempts = 0;
  bool _wasPlayingBeforeError = false;

  static const String _boxName = 'audio_settings';

  AudioQuranCubit() : super(const AudioQuranState()) {
    _loadInitialState();
    _initAudioListeners();
    _initConnectivity();
  }

  // Exposed for UI widgets (Slider)
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<int?> get currentIndexStream => _audioPlayer.currentIndexStream;

  Future<void> _loadInitialState() async {
    try {
      final box = await Hive.openBox(_boxName);
      final surah = box.get('surah', defaultValue: 1);
      final ayah = box.get('ayah', defaultValue: 1);
      final reciterId = box.get('reciterId', defaultValue: "alafasy");
      final reciterName = box.get('reciterName', defaultValue: "مشاري العفاسي");
      final reciterFolder = box.get(
        'reciterFolder',
        defaultValue: "Alafasy_128kbps",
      );
      final List<int> downloaded = List<int>.from(
        box.get('downloaded_surahs_${reciterId}', defaultValue: []),
      );

      final savedReciter = Reciter(
        id: reciterId,
        name: reciterName,
        subfolder: reciterFolder,
      );

      // Default volume
      _audioPlayer.setVolume(1.0);

      emit(
        state.copyWith(
          currentSurahNumber: surah,
          currentAyahNumber: ayah,
          selectedReciter: savedReciter,
          status: AudioPlaybackStatus.initial,
          downloadedSurahs: downloaded,
          volume: 1.0,
        ),
      );
    } catch (e) {
      // Ignore Hive errors
    }
  }

  Future<void> _saveState() async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put('surah', state.currentSurahNumber);
      await box.put('ayah', state.currentAyahNumber);
      await box.put('reciterId', state.selectedReciter.id);
      await box.put('reciterName', state.selectedReciter.name);
      await box.put('reciterFolder', state.selectedReciter.subfolder);
    } catch (e) {
      // Ignore
    }
  }

  void _initConnectivity() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) async {
      if (isClosed) return;

      bool hasInterface = results.any(
        (r) =>
            r != ConnectivityResult.none && r != ConnectivityResult.bluetooth,
      );

      if (!hasInterface) {
        _handleConnectionLoss();
      } else {
        if (!_hasInternet || state.status == AudioPlaybackStatus.error) {
          final hasRealNet = await _checkInternetAccess();
          if (hasRealNet) {
            _hasInternet = true;
            _handleConnectionRestored();
          }
        }
      }
    });
  }

  Future<bool> _checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _handleConnectionLoss() {
    _hasInternet = false;
    if (state.downloadingSurahId != null) {
      // Just let Dio fail
    }

    bool isLocal = state.downloadedSurahs.contains(state.currentSurahNumber);
    if (!isLocal && state.isPlaying) {
      _wasPlayingBeforeError = true;
      _audioPlayer.pause();
      emit(
        state.copyWith(
          status: AudioPlaybackStatus.paused,
          errorMessage: "انقطع الاتصال، جاري الانتظار...",
        ),
      );
    }
  }

  void _handleConnectionRestored() {
    if (_wasPlayingBeforeError) {
      _wasPlayingBeforeError = false;
      if (state.status == AudioPlaybackStatus.error ||
          state.errorMessage != null) {
        retry();
      } else {
        _audioPlayer.play();
      }
    } else {
      if (state.errorMessage != null && state.errorMessage!.contains("اتصال")) {
        emit(state.copyWith(errorMessage: null));
      }
    }
  }

  // --- Downloading Logic ---

  Future<String> _getPrivateDirectory(int surahNumber) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final reciterId = state.selectedReciter.id;
    final dirPath = '${appDocDir.path}/audio_quran/$reciterId/$surahNumber';
    final directory = Directory(dirPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return dirPath;
  }

  Future<void> downloadSurah(int surahNumber) async {
    if (!_hasInternet && !(await _checkInternetAccess())) {
      return;
    }

    if (state.downloadingSurahId != null) return; // Busy

    emit(
      state.copyWith(downloadingSurahId: surahNumber, downloadProgress: 0.0),
    );

    try {
      final savePath = await _getPrivateDirectory(surahNumber);
      final int totalAyahs = quran.getVerseCount(surahNumber);
      final String reciterPath = state.selectedReciter.subfolder;
      final String surahPad = surahNumber.toString().padLeft(3, '0');

      for (int i = 1; i <= totalAyahs; i++) {
        final String ayahPad = i.toString().padLeft(3, '0');
        final String fileName = '$ayahPad.mp3';
        final String filePath = '$savePath/$fileName';
        final File file = File(filePath);

        if (!await file.exists()) {
          final String url =
              "https://everyayah.com/data/$reciterPath/$surahPad$ayahPad.mp3";
          await _dio.download(url, filePath);
        }

        double progress = i / totalAyahs;
        emit(state.copyWith(downloadProgress: progress));
      }

      await _markSurahAsDownloaded(surahNumber);
    } catch (e) {
      // Error
    } finally {
      emit(state.copyWith(downloadingSurahId: null, downloadProgress: 0.0));
    }
  }

  Future<void> _markSurahAsDownloaded(int surahNumber) async {
    final box = await Hive.openBox(_boxName);
    final key = 'downloaded_surahs_${state.selectedReciter.id}';
    final List<int> current = List<int>.from(box.get(key, defaultValue: []));

    if (!current.contains(surahNumber)) {
      current.add(surahNumber);
      await box.put(key, current);
      emit(state.copyWith(downloadedSurahs: current));
    }
  }

  // --- Playback Logic ---

  Future<void> playSurah(int surahNumber, {int startAyah = 1}) async {
    _retryAttempts = 0;
    bool isDownloaded = state.downloadedSurahs.contains(surahNumber);

    if (!isDownloaded && !_hasInternet && !(await _checkInternetAccess())) {
      emit(
        state.copyWith(
          status: AudioPlaybackStatus.error,
          errorMessage: "لا يوجد اتصال بالإنترنت",
        ),
      );
      return;
    }
    _hasInternet = true;

    if (_audioPlayer.playing) await _audioPlayer.stop();

    emit(
      state.copyWith(
        currentSurahNumber: surahNumber,
        currentAyahNumber: startAyah,
        status: AudioPlaybackStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final playlist = await _buildSurahPlaylist(surahNumber, isDownloaded);
      await _audioPlayer.setAudioSource(
        playlist,
        initialIndex: startAyah - 1,
        initialPosition: Duration.zero,
      );
      await _audioPlayer.play();
      _saveState();
    } catch (e) {
      _handlePlayerError(e);
    }
  }

  Future<ConcatenatingAudioSource> _buildSurahPlaylist(
    int surah,
    bool isDownloaded,
  ) async {
    final int totalAyahs = quran.getVerseCount(surah);
    final String reciterPath = state.selectedReciter.subfolder;
    final String surahPad = surah.toString().padLeft(3, '0');

    String? localPath;
    if (isDownloaded) {
      localPath = await _getPrivateDirectory(surah);
    }

    final List<AudioSource> audioSources = List.generate(totalAyahs, (index) {
      final i = index + 1;
      final String ayahPad = i.toString().padLeft(3, '0');

      if (isDownloaded && localPath != null) {
        final fileUri = Uri.file('$localPath/$ayahPad.mp3');
        return AudioSource.uri(fileUri, tag: {'surah': surah, 'ayah': i});
      } else {
        final String url =
            "https://everyayah.com/data/$reciterPath/$surahPad$ayahPad.mp3";
        return AudioSource.uri(
          Uri.parse(url),
          tag: {'surah': surah, 'ayah': i},
        );
      }
    });

    return ConcatenatingAudioSource(
      useLazyPreparation: true,
      shuffleOrder: DefaultShuffleOrder(),
      children: audioSources,
    );
  }

  void _initAudioListeners() {
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (!isClosed && duration != null) {
        emit(state.copyWith(totalDuration: duration));
      }
    });

    _currentIndexSubscription = _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && !isClosed) {
        final playlist = _audioPlayer.audioSource as ConcatenatingAudioSource?;
        if (playlist != null && index < playlist.children.length) {
          final source = playlist.children[index] as UriAudioSource;
          final tag = source.tag as Map<String, dynamic>?;

          if (tag != null) {
            final newAyah = tag['ayah'] as int;
            if (newAyah != state.currentAyahNumber) {
              emit(state.copyWith(currentAyahNumber: newAyah));
              _saveState();
            }
          }
        }
      }
    });

    _playerStateSubscription = _audioPlayer.playerStateStream.listen(
      (playerState) {
        if (isClosed) return;

        final isPlaying = playerState.playing;
        final processingState = playerState.processingState;

        if (processingState == ProcessingState.completed) {
          _playNextSurah();
          return;
        }

        AudioPlaybackStatus newStatus = state.status;

        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          newStatus = AudioPlaybackStatus.loading;
        } else if (isPlaying) {
          newStatus = AudioPlaybackStatus.playing;
        } else if (processingState == ProcessingState.ready) {
          newStatus = isPlaying
              ? AudioPlaybackStatus.playing
              : AudioPlaybackStatus.paused;
          if (!isPlaying) _saveState();
        }

        if (newStatus != state.status) {
          emit(state.copyWith(status: newStatus));
        }
      },
      onError: (Object e) {
        if (!isClosed) _handlePlayerError(e);
      },
    );
  }

  Future<void> _handlePlayerError(Object e) async {
    bool isLocal = state.downloadedSurahs.contains(state.currentSurahNumber);
    if (isLocal) {
      _audioPlayer.pause();
      emit(
        state.copyWith(
          status: AudioPlaybackStatus.error,
          errorMessage: "تعذر تشغيل الملف المحفوظ.",
        ),
      );
      return;
    }

    if (e.toString().contains("SocketException") ||
        e.toString().contains("HttpException") ||
        e.toString().contains("Connection")) {
      if (_retryAttempts < 3) {
        _retryAttempts++;
        int delay = _retryAttempts * 1000;
        emit(
          state.copyWith(
            status: AudioPlaybackStatus.loading,
            errorMessage: "ضعف في الاتصال، محاولة $_retryAttempts/3...",
          ),
        );
        await Future.delayed(Duration(milliseconds: delay));

        if (isClosed) return;
        try {
          if (_audioPlayer.audioSource != null) {
            await _audioPlayer.play();
          } else {
            await retry();
          }
        } catch (_) {}
        return;
      }
    }

    _retryAttempts = 0;
    _wasPlayingBeforeError = false;
    _audioPlayer.pause();
    emit(
      state.copyWith(
        status: AudioPlaybackStatus.error,
        errorMessage: "تعذر تشغيل الصوت. تحقق من الإنترنت.",
      ),
    );
  }

  Future<void> togglePlay() async {
    if (state.status == AudioPlaybackStatus.playing) {
      await _audioPlayer.pause();
    } else {
      if (state.status == AudioPlaybackStatus.error) {
        retry();
      } else {
        if (_audioPlayer.audioSource == null) {
          playSurah(
            state.currentSurahNumber,
            startAyah: state.currentAyahNumber,
          );
        } else {
          _audioPlayer.play();
        }
      }
    }
  }

  Future<void> nextAyah() async {
    if (_audioPlayer.hasNext) {
      await _audioPlayer.seekToNext();
    } else {
      await _playNextSurah();
    }
  }

  Future<void> previousAyah() async {
    if (_audioPlayer.hasPrevious) {
      await _audioPlayer.seekToPrevious();
    } else {
      await _audioPlayer.seek(Duration.zero, index: 0);
    }
  }

  Future<void> _playNextSurah() async {
    if (state.currentSurahNumber < 114) {
      await playSurah(state.currentSurahNumber + 1);
    } else {
      await _audioPlayer.stop();
      emit(state.copyWith(status: AudioPlaybackStatus.stopped));
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(clamped);
    emit(state.copyWith(volume: clamped));
  }

  Future<void> retry() async {
    _retryAttempts = 0;
    await playSurah(
      state.currentSurahNumber,
      startAyah: state.currentAyahNumber,
    );
  }

  void changeReciter(Reciter reciter) async {
    if (state.selectedReciter.id == reciter.id) return;

    final box = await Hive.openBox(_boxName);
    final List<int> downloaded = List<int>.from(
      box.get('downloaded_surahs_${reciter.id}', defaultValue: []),
    );

    emit(
      state.copyWith(selectedReciter: reciter, downloadedSurahs: downloaded),
    );
    playSurah(state.currentSurahNumber, startAyah: state.currentAyahNumber);
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _currentIndexSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
