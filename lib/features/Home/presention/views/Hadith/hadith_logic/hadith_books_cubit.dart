import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/models/hadith_book.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/repositories/hadith_repository.dart';

part 'hadith_books_state.dart';

class HadithBooksCubit extends Cubit<HadithBooksState> {
  final HadithRepository _repository;

  HadithBooksCubit(this._repository) : super(HadithBooksInitial());

  Future<void> loadBooks() async {
    emit(HadithBooksLoading());
    try {
      final books = await _repository.getBooks();
      emit(HadithBooksLoaded(books));
    } catch (e) {
      emit(HadithBooksError(e.toString()));
    }
  }

  Future<void> downloadBook(HadithBook book) async {
    if (state is! HadithBooksLoaded) return;

    var currentState = state as HadithBooksLoaded;

    // Initial download state
    if (!isClosed) {
      emit(
        currentState.copyWith(
          downloadingBookId: book.id,
          downloadProgress: 0.0,
          downloadError: null, // Clear previous error
        ),
      );
    }

    try {
      await _repository.downloadBook(
        book,
        onProgress: (received, total) {
          if (!isClosed && total != -1 && state is HadithBooksLoaded) {
            // We cast again just to be safe if state changed rapidly, though unlikely in single synchronous flow
            // actually we should rely on 'state' being up to date
            emit(
              (state as HadithBooksLoaded).copyWith(
                downloadingBookId: book.id,
                downloadProgress: received / total,
              ),
            );
          }
        },
      );

      if (isClosed) return;

      // Refresh list to show 'downloaded' status and clear download state
      final books = await _repository.getBooks();
      if (!isClosed)
        emit(
          HadithBooksLoaded(books),
        ); // This acts as clearDownloadState as fresh object
    } catch (e) {
      if (!isClosed && state is HadithBooksLoaded) {
        emit(
          (state as HadithBooksLoaded).copyWith(
            downloadError:
                "فشل التحميل: حاول مرة أخرى", // User friendly message
            downloadingBookId:
                book.id, // Keep ID to show error on specific card
            downloadProgress: 0.0,
          ),
        );
      }
    }
  }

  void clearError(String bookId) {
    if (state is HadithBooksLoaded) {
      final s = state as HadithBooksLoaded;
      if (s.downloadingBookId == bookId && s.downloadError != null) {
        emit(s.clearDownloadState());
      }
    }
  }
}
