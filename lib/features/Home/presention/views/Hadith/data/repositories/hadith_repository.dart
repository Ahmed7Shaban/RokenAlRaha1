import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/models/hadith_book.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/models/hadith_content.dart';

class HadithRepository {
  static const String _settingsBoxName = 'hadith_settings';
  static const String _downloadedBooksKey = 'downloaded_books';
  static const String _progressKeyPrefix = 'progress_';

  final Dio _dio = Dio();
  Box? _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_settingsBoxName)) {
      _box = await Hive.openBox(_settingsBoxName);
    } else {
      _box = Hive.box(_settingsBoxName);
    }
  }

  // Predefined List of Books
  final List<HadithBook> _allBooks = [
    HadithBook(
      id: 'ahmed',
      name: 'مسند أحمد',
      totalHadiths: 26363, // Approximate
      localPath: 'assets/json/hadith/ahmed.json',
      isDownloaded: true, // Always available
    ),
    HadithBook(
      id: 'muslim',
      name: 'صحيح مسلم',
      totalHadiths: 7563, // Approximate
      localPath: 'assets/json/hadith/muslim.json',
      isDownloaded: true, // Always available
    ),
    HadithBook(
      id: 'bukhari',
      name: 'صحيح البخاري',
      totalHadiths: 7563, // Approximate count often cited
      url:
          'https://raw.githubusercontent.com/Mohamed-Nagdy/Quran-App-Data/refs/heads/main/Hadith%20Books%20Json/bukhari.json',
    ),
    HadithBook(
      id: 'abi_daud',
      name: 'سنن أبي داود',
      totalHadiths: 5274,
      url:
          'https://raw.githubusercontent.com/Mohamed-Nagdy/Quran-App-Data/refs/heads/main/Hadith%20Books%20Json/abi_daud.json',
    ),
    HadithBook(
      id: 'trmizi',
      name: 'جامع الترمذي', // Or Sunan Tirmidhi
      totalHadiths: 3956,
      url:
          'https://raw.githubusercontent.com/Mohamed-Nagdy/Quran-App-Data/refs/heads/main/Hadith%20Books%20Json/trmizi.json',
    ),
    HadithBook(
      id: 'nasai',
      name: 'سنن النسائي',
      totalHadiths: 5758,
      url:
          'https://raw.githubusercontent.com/Mohamed-Nagdy/Quran-App-Data/refs/heads/main/Hadith%20Books%20Json/nasai.json',
    ),
    HadithBook(
      id: 'ibn_maja',
      name: 'سنن ابن ماجه',
      totalHadiths: 4341,
      url:
          'https://raw.githubusercontent.com/Mohamed-Nagdy/Quran-App-Data/refs/heads/main/Hadith%20Books%20Json/ibn_maja.json',
    ),
    HadithBook(
      id: 'darimi',
      name: 'سنن الدارمي',
      totalHadiths: 3550, // Approximation
      url:
          'https://raw.githubusercontent.com/Mohamed-Nagdy/Quran-App-Data/refs/heads/main/Hadith%20Books%20Json/darimi.json',
    ),
    HadithBook(
      id: 'malik',
      name: 'موطأ مالك',
      totalHadiths: 1721, // Approximation
      url:
          'https://raw.githubusercontent.com/Mohamed-Nagdy/Quran-App-Data/refs/heads/main/Hadith%20Books%20Json/malik.json',
    ),
  ];

  Future<List<HadithBook>> getBooks() async {
    await init();
    final downloadedIds =
        _box
            ?.get(_downloadedBooksKey, defaultValue: <String>[])
            ?.cast<String>() ??
        [];

    for (var book in _allBooks) {
      if (book.isLocal) {
        book.isDownloaded = true;
      } else {
        book.isDownloaded = downloadedIds.contains(book.id);
        if (book.isDownloaded) {
          final exists = await _checkFileExists(book.id);
          if (!exists) {
            book.isDownloaded = false;
          }
        }
      }
      // Populate read count
      book.readCount = await getLastReadIndex(book.id);
    }
    return _allBooks;
  }

  Future<bool> _checkFileExists(String bookId) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/hadith_$bookId.json');
    return file.exists();
  }

  Future<void> downloadBook(
    HadithBook book, {
    required Function(int received, int total) onProgress,
  }) async {
    if (book.url == null) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/hadith_${book.id}.json';

      await _dio.download(book.url!, savePath, onReceiveProgress: onProgress);

      await _markAsDownloaded(book.id);
      book.isDownloaded = true;
    } catch (e) {
      throw Exception('Failed to download book: $e');
    }
  }

  Future<void> _markAsDownloaded(String bookId) async {
    await init();
    List<String> downloaded =
        _box
            ?.get(_downloadedBooksKey, defaultValue: <String>[])
            ?.cast<String>() ??
        [];
    if (!downloaded.contains(bookId)) {
      downloaded.add(bookId);
      await _box?.put(_downloadedBooksKey, downloaded);
    }
  }

  Future<List<HadithContent>> getHadiths(HadithBook book) async {
    String jsonString;
    try {
      if (book.isLocal) {
        jsonString = await rootBundle.loadString(book.localPath!);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/hadith_${book.id}.json');
        if (await file.exists()) {
          try {
            jsonString = await file.readAsString();
          } catch (e) {
            // FileSystemException or encoding error
            await file.delete();
            // Also need to update internal state/hive if possible,
            // but deleting file ensures getBooks() returns isDownloaded=false next time.
            throw Exception(
              "ملف الكتاب تالف. تم حذفه تلقائياً، يرجى إعادة التحميل.",
            );
          }
        } else {
          throw Exception("ملف الكتاب غير موجود");
        }
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => HadithContent.fromJson(e)).toList();
    } catch (e) {
      // If JSON decode failed or readAsString failed
      if (!book.isLocal) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/hadith_${book.id}.json');
        if (await file.exists()) {
          await file.delete();
        }
        throw Exception("بيانات الكتاب تالفة. تم الحذف، يرجى إعادة التحميل.");
      }
      throw e;
    }
  }

  Future<int> getLastReadIndex(String bookId) async {
    await init();
    return _box?.get('$_progressKeyPrefix$bookId', defaultValue: 0) ?? 0;
  }

  Future<void> saveLastReadIndex(String bookId, int index) async {
    await init();
    await _box?.put('$_progressKeyPrefix$bookId', index);
  }

  // Favorites
  Future<Set<int>> getFavorites(String bookId) async {
    await init();
    final List<int> favs =
        _box?.get('favorites_$bookId', defaultValue: <int>[])?.cast<int>() ??
        [];
    return favs.toSet();
  }

  Future<void> saveFavorites(String bookId, Set<int> favorites) async {
    await init();
    await _box?.put('favorites_$bookId', favorites.toList());
  }

  Future<void> toggleFavorite(String bookId, int hadithNumber) async {
    final favs = await getFavorites(bookId);
    if (favs.contains(hadithNumber)) {
      favs.remove(hadithNumber);
    } else {
      favs.add(hadithNumber);
    }
    await saveFavorites(bookId, favs);
  }

  // Read Status
  Future<Set<int>> getReadHadiths(String bookId) async {
    await init();
    final List<int> read =
        _box?.get('read_$bookId', defaultValue: <int>[])?.cast<int>() ?? [];
    return read.toSet();
  }

  Future<void> saveReadHadiths(String bookId, Set<int> readHadiths) async {
    await init();
    await _box?.put('read_$bookId', readHadiths.toList());
  }

  Future<void> markHadithAsRead(String bookId, int hadithNumber) async {
    final read = await getReadHadiths(bookId);
    if (!read.contains(hadithNumber)) {
      read.add(hadithNumber);
      await saveReadHadiths(bookId, read);
    }
  }

  // Notes
  Future<Map<int, String>> getNotes(String bookId) async {
    await init();
    // Getting map directly from hive usually requires casting manually if stored as Map
    // Or we store as json string? For simplicity, let's store as Map<String, String> key=hadithNum
    final Map<dynamic, dynamic> rawMap =
        _box?.get('notes_$bookId', defaultValue: {}) ?? {};
    final Map<int, String> notes = {};
    rawMap.forEach((key, value) {
      if (key is String) {
        final k = int.tryParse(key);
        if (k != null) notes[k] = value.toString();
      } else if (key is int) {
        notes[key] = value.toString();
      }
    });
    return notes;
  }

  Future<void> saveNote(String bookId, int hadithNumber, String note) async {
    await init();
    final notes = await getNotes(bookId);
    notes[hadithNumber] = note;

    // hive supports int keys in maps usually, but safer to stick to what works or use json
    await _box?.put('notes_$bookId', notes);
  }

  Future<void> deleteNote(String bookId, int hadithNumber) async {
    await init();
    final notes = await getNotes(bookId);
    notes.remove(hadithNumber);
    await _box?.put('notes_$bookId', notes);
  }
}
