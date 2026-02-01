part of 'hadith_details_cubit.dart';

abstract class HadithDetailsState extends Equatable {
  const HadithDetailsState();

  @override
  List<Object> get props => [];
}

class HadithDetailsInitial extends HadithDetailsState {}

class HadithDetailsLoading extends HadithDetailsState {}

class HadithDetailsLoaded extends HadithDetailsState {
  final List<HadithContent> hadiths;
  final List<HadithContent> filteredHadiths;
  final int lastReadIndex;
  final Set<int> favorites;
  final Set<int> readHadiths;
  final Map<int, String> notes;

  const HadithDetailsLoaded({
    required this.hadiths,
    required this.filteredHadiths,
    required this.lastReadIndex,
    this.favorites = const {},
    this.readHadiths = const {},
    this.notes = const {},
  });

  HadithDetailsLoaded copyWith({
    List<HadithContent>? hadiths,
    List<HadithContent>? filteredHadiths,
    int? lastReadIndex,
    Set<int>? favorites,
    Set<int>? readHadiths,
    Map<int, String>? notes,
  }) {
    return HadithDetailsLoaded(
      hadiths: hadiths ?? this.hadiths,
      filteredHadiths: filteredHadiths ?? this.filteredHadiths,
      lastReadIndex: lastReadIndex ?? this.lastReadIndex,
      favorites: favorites ?? this.favorites,
      readHadiths: readHadiths ?? this.readHadiths,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object> get props => [
    hadiths,
    filteredHadiths,
    lastReadIndex,
    favorites,
    readHadiths,
    notes,
  ];
}

class HadithDetailsError extends HadithDetailsState {
  final String message;

  const HadithDetailsError(this.message);

  @override
  List<Object> get props => [message];
}
