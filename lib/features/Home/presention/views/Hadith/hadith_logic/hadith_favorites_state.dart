part of 'hadith_favorites_cubit.dart';

abstract class HadithFavoritesState extends Equatable {
  const HadithFavoritesState();

  @override
  List<Object> get props => [];
}

class HadithFavoritesInitial extends HadithFavoritesState {}

class HadithFavoritesLoading extends HadithFavoritesState {}

class HadithFavoritesLoaded extends HadithFavoritesState {
  final List<FavoriteHadithModel> favorites;

  const HadithFavoritesLoaded(this.favorites);

  @override
  List<Object> get props => [favorites];
}

class HadithFavoritesError extends HadithFavoritesState {
  final String message;

  const HadithFavoritesError(this.message);

  @override
  List<Object> get props => [message];
}

class FavoriteHadithModel {
  final HadithBook book;
  final HadithContent hadith;

  const FavoriteHadithModel({required this.book, required this.hadith});
}
