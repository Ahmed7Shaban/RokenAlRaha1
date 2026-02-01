// import 'package:just_audio/just_audio.dart';

// class AudioPlayerService {
//   final AudioPlayer _audioPlayer = AudioPlayer();

//   // Expose streams
//   Stream<Duration> get positionStream => _audioPlayer.positionStream;
//   Stream<Duration?> get durationStream => _audioPlayer.durationStream;
//   Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
//   Stream<ProcessingState> get processingStateStream =>
//       _audioPlayer.processingStateStream;
//   Stream<bool> get playingStream => _audioPlayer.playingStream;
//   Stream<int?> get currentIndexStream => _audioPlayer.currentIndexStream;
//   Stream<int?> get sequenceStateStream => _audioPlayer.sequenceStateStream.map(
//     (s) => s?.currentIndex,
//   ); // simplified for now

//   Duration get currentPosition => _audioPlayer.position;

//   /// Sets a single URL as source (legacy/fallback)
//   Future<void> setUrl({
//     required String url,
//     required String id,
//     required String title,
//     required String artist,
//     required String album,
//     String? artUri,
//   }) async {
//     final source = createAudioSource(
//       url: url,
//       id: id,
//       title: title,
//       artist: artist,
//       album: album,
//       artUri: artUri,
//     );
//     await _audioPlayer.setAudioSource(source);
//   }

//   /// Sets a playlist of sources
//   Future<void> setPlaylist({
//     required List<AudioSource> sources,
//     int initialIndex = 0,
//     Duration initialPosition = Duration.zero,
//   }) async {
//     try {
//       final playlist = ConcatenatingAudioSource(children: sources);
//       await _audioPlayer.setAudioSource(
//         playlist,
//         initialIndex: initialIndex,
//         initialPosition: initialPosition,
//       );
//     } catch (e) {
//       // Handle source errors
//       rethrow;
//     }
//   }

//   AudioSource createAudioSource({
//     required String url,
//     required String id,
//     required String title,
//     required String artist,
//     required String album,
//     String? artUri,
//   }) {
//     return AudioSource.uri(
//       Uri.parse(url),
//       tag: MediaItem(
//         id: id,
//         album: album,
//         title: title,
//         artist: artist,
//         artUri: artUri != null ? Uri.parse(artUri) : null,
//       ),
//     );
//   }

//   Future<void> play() async {
//     await _audioPlayer.play();
//   }

//   Future<void> pause() async {
//     await _audioPlayer.pause();
//   }

//   Future<void> stop() async {
//     await _audioPlayer.stop();
//   }

//   Future<void> seek(Duration position) async {
//     await _audioPlayer.seek(position);
//   }

//   Future<void> seekToIndex(int index) async {
//     await _audioPlayer.seek(Duration.zero, index: index);
//   }

//   Future<void> skipToNext() async {
//     await _audioPlayer.seekToNext();
//   }

//   Future<void> skipToPrevious() async {
//     await _audioPlayer.seekToPrevious();
//   }

//   Future<void> dispose() async {
//     await _audioPlayer.dispose();
//   }

//   bool get isPlaying => _audioPlayer.playing;

//   /// Check if there is a next item in the playlist
//   bool get hasNext => _audioPlayer.hasNext;
// }
