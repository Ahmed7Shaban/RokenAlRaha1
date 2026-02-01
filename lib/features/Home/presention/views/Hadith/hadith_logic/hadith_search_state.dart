part of 'hadith_search_cubit.dart';

abstract class HadithSearchState extends Equatable {
  const HadithSearchState();

  @override
  List<Object> get props => [];
}

class HadithSearchInitial extends HadithSearchState {}

class HadithSearchLoading extends HadithSearchState {}

class HadithSearchLoaded extends HadithSearchState {
  final List<HadithSearchResult> results;
  final String query;

  const HadithSearchLoaded(this.results, this.query);

  @override
  List<Object> get props => [results, query];
}

class HadithSearchError extends HadithSearchState {
  final String message;

  const HadithSearchError(this.message);

  @override
  List<Object> get props => [message];
}
