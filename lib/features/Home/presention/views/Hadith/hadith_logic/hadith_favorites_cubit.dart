import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/models/hadith_book.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/models/hadith_content.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/repositories/hadith_repository.dart';

part 'hadith_favorites_state.dart';

class HadithFavoritesCubit extends Cubit<HadithFavoritesState> {
  final HadithRepository _repository;

  HadithFavoritesCubit(this._repository) : super(HadithFavoritesInitial());

  Future<void> loadFavorites() async {
    emit(HadithFavoritesLoading());
    try {
      final books = await _repository.getBooks();
      List<FavoriteHadithModel> allFavorites = [];

      for (var book in books) {
        // We can only show favorites from downloaded books to access content
        // Alternatively, if we store favorites with content separate from full book, we could show them.
        // But current architecture stores ID only. So book must be present.
        if (!book.isDownloaded) continue;

        final favoriteIds = await _repository.getFavorites(book.id);
        if (favoriteIds.isEmpty) continue;

        final bookContent = await _repository.getHadiths(book);

        for (var id in favoriteIds) {
          try {
            final hadith = bookContent.firstWhere((h) => h.number == id);
            allFavorites.add(FavoriteHadithModel(book: book, hadith: hadith));
          } catch (e) {
            // Hadith not found in book? Should not happen if data consistent.
          }
        }
      }

      emit(HadithFavoritesLoaded(allFavorites));
    } catch (e) {
      emit(HadithFavoritesError("فشل تحميل المفضلة: $e"));
    }
  }

  Future<void> refresh() => loadFavorites();
}
