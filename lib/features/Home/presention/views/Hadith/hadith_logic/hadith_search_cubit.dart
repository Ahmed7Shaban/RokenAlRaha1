import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/models/hadith_book.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/models/hadith_content.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/repositories/hadith_repository.dart';

part 'hadith_search_state.dart';

class HadithSearchCubit extends Cubit<HadithSearchState> {
  final HadithRepository _repository;

  HadithSearchCubit(this._repository) : super(HadithSearchInitial());

  Future<void> search(String query) async {
    if (query.isEmpty) {
      emit(HadithSearchInitial());
      return;
    }

    emit(HadithSearchLoading());
    // We do NOT wrap the whole block in try/catch to force successful state emission
    // unless getting books list itself fails.
    try {
      final books = await _repository.getBooks();
      final downloadedBooks = books.where((b) => b.isDownloaded).toList();

      List<HadithSearchResult> results = [];

      for (var book in downloadedBooks) {
        try {
          // Robustly attempt to read book content
          final content = await _repository.getHadiths(book);

          final filtered = content
              .where((h) {
                return h.hadith.contains(query) ||
                    (h.searchTerm != null && h.searchTerm!.contains(query));
              })
              .map((h) => HadithSearchResult(hadith: h, book: book))
              .toList();

          results.addAll(filtered);
        } catch (e) {
          // Gracefully ignore individual book errors (e.g. file missing)
          // so the search continues for other books.
          debugPrint("Search error in book ${book.name}: $e");
          continue;
        }
      }

      // Always emit Loaded, even if results are empty.
      emit(HadithSearchLoaded(results, query));
    } catch (e) {
      // Only reach here if getting book list fails entirely
      emit(HadithSearchError("حدث خطأ أثناء تهيئة البحث: $e"));
    }
  }
}

class HadithSearchResult {
  final HadithContent hadith;
  final HadithBook book;

  HadithSearchResult({required this.hadith, required this.book});
}
