import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/models/hadith_book.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/models/hadith_content.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/repositories/hadith_repository.dart';

part 'hadith_details_state.dart';

class HadithDetailsCubit extends Cubit<HadithDetailsState> {
  final HadithRepository _repository;
  final HadithBook book;

  List<HadithContent> _allHadiths = [];

  HadithDetailsCubit(this._repository, this.book)
    : super(HadithDetailsInitial());

  Future<void> loadHadiths() async {
    emit(HadithDetailsLoading());
    try {
      _allHadiths = await _repository.getHadiths(book);
      final lastRead = await _repository.getLastReadIndex(book.id);
      final favorites = await _repository.getFavorites(book.id);
      final readHadiths = await _repository.getReadHadiths(book.id);
      final notes = await _repository.getNotes(book.id);

      if (isClosed) return;

      emit(
        HadithDetailsLoaded(
          hadiths: _allHadiths,
          filteredHadiths: _allHadiths,
          lastReadIndex: lastRead,
          favorites: favorites,
          readHadiths: readHadiths,
          notes: notes,
        ),
      );
    } catch (e) {
      if (!isClosed) emit(HadithDetailsError(e.toString()));
    }
  }

  void search(String query) {
    if (state is HadithDetailsLoaded) {
      final currentState = state as HadithDetailsLoaded;
      if (query.isEmpty) {
        emit(currentState.copyWith(filteredHadiths: _allHadiths));
        return;
      }

      final lowerQuery = query.toLowerCase();
      final filtered = _allHadiths.where((h) {
        return h.hadith.contains(query) ||
            (h.searchTerm != null && h.searchTerm!.contains(query));
      }).toList();

      emit(currentState.copyWith(filteredHadiths: filtered));
    }
  }

  Future<void> saveProgress(int index) async {
    if (state is HadithDetailsLoaded) {
      await _repository.saveLastReadIndex(book.id, index);
    }
  }

  Future<void> toggleFavorite(int hadithNumber) async {
    if (state is HadithDetailsLoaded) {
      final currentState = state as HadithDetailsLoaded;

      // Update local state immediately for UI response
      final updatedFavorites = Set<int>.from(currentState.favorites);
      if (updatedFavorites.contains(hadithNumber)) {
        updatedFavorites.remove(hadithNumber);
      } else {
        updatedFavorites.add(hadithNumber);
      }

      // We change state first for responsiveness, assuming call won't fail or we don't care about sync yet
      if (!isClosed) emit(currentState.copyWith(favorites: updatedFavorites));
      // Save
      await _repository.toggleFavorite(book.id, hadithNumber);
    }
  }

  Future<void> markAsRead(int hadithNumber) async {
    if (state is HadithDetailsLoaded) {
      final currentState = state as HadithDetailsLoaded;
      if (currentState.readHadiths.contains(hadithNumber)) return;

      final updatedRead = Set<int>.from(currentState.readHadiths);
      updatedRead.add(hadithNumber);

      if (!isClosed) emit(currentState.copyWith(readHadiths: updatedRead));
      await _repository.markHadithAsRead(book.id, hadithNumber);
    }
  }

  Future<void> saveNote(int hadithNumber, String note) async {
    if (state is HadithDetailsLoaded) {
      final currentState = state as HadithDetailsLoaded;
      final updatedNotes = Map<int, String>.from(currentState.notes);
      updatedNotes[hadithNumber] = note;

      if (!isClosed) emit(currentState.copyWith(notes: updatedNotes));
      await _repository.saveNote(book.id, hadithNumber, note);
    }
  }

  Future<void> deleteNote(int hadithNumber) async {
    if (state is HadithDetailsLoaded) {
      final currentState = state as HadithDetailsLoaded;

      if (!currentState.notes.containsKey(hadithNumber)) return;

      final updatedNotes = Map<int, String>.from(currentState.notes);
      updatedNotes.remove(hadithNumber);

      if (!isClosed) emit(currentState.copyWith(notes: updatedNotes));
      await _repository.deleteNote(book.id, hadithNumber);
    }
  }
}
