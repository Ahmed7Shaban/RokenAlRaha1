import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/models/hadith_book.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/repositories/hadith_repository.dart';
import 'hadith_home_state.dart';

class HadithDataController extends Cubit<HadithHomeState> {
  final HadithRepository _repository;
  final Random _random = Random();

  HadithDataController({HadithRepository? repository})
      : _repository = repository ?? HadithRepository(),
        super(HadithHomeInitial());

  Future<void> fetchRandomHadith() async {
    emit(HadithHomeLoading());

    try {
      // 1. Get all books
      final books = await _repository.getBooks();

      // 2. Filter available (Downloaded or Local)
      final availableBooks = books.where((b) => b.isDownloaded || b.isLocal).toList();

      if (availableBooks.isEmpty) {
        emit(const HadithHomeError("لا توجد كتب حديث متاحة. يرجى تحميل الكتب من قسم الحديث."));
        return;
      }

      // 3. Pick a random book and fetch hadith
      // Retry logic in case a book fails (e.g. corrupted file)
      bool success = false;
      int attempts = 0;
      
      while (!success && attempts < 3) {
        attempts++;
        try {
          final randomBook = availableBooks[_random.nextInt(availableBooks.length)];
          final hadiths = await _repository.getHadiths(randomBook);

          if (hadiths.isNotEmpty) {
            final randomHadith = hadiths[_random.nextInt(hadiths.length)];
            emit(HadithHomeLoaded(hadith: randomHadith, book: randomBook));
            success = true;
          }
        } catch (e) {
          // If a specific book fails, loop again to try another
          continue;
        }
      }

      if (!success) {
        emit(const HadithHomeError("تعذر تحميل حديث عشوائي. يرجى المحاولة لاحقاً."));
      }

    } catch (e) {
      emit(HadithHomeError("حدث خطأ غير متوقع: ${e.toString()}"));
    }
  }
}
