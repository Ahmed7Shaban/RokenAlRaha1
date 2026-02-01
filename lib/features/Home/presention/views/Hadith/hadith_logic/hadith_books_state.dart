part of 'hadith_books_cubit.dart';

abstract class HadithBooksState extends Equatable {
  const HadithBooksState();

  @override
  List<Object?> get props => [];
}

class HadithBooksInitial extends HadithBooksState {}

class HadithBooksLoading extends HadithBooksState {}

class HadithBooksLoaded extends HadithBooksState {
  final List<HadithBook> books;
  final String? downloadingBookId;
  final double? downloadProgress; // 0.0 to 1.0
  final String? downloadError;

  const HadithBooksLoaded(
    this.books, {
    this.downloadingBookId,
    this.downloadProgress,
    this.downloadError,
  });

  HadithBooksLoaded copyWith({
    List<HadithBook>? books,
    String? downloadingBookId,
    double? downloadProgress,
    String? downloadError,
  }) {
    return HadithBooksLoaded(
      books ?? this.books,
      downloadingBookId: downloadingBookId,
      downloadProgress: downloadProgress,
      downloadError: downloadError,
    );
  }

  HadithBooksLoaded clearDownloadState() {
    return HadithBooksLoaded(books);
  }

  @override
  List<Object?> get props => [
    books,
    downloadingBookId,
    downloadProgress,
    downloadError,
  ];
}

class HadithBooksError extends HadithBooksState {
  final String message;

  const HadithBooksError(this.message);

  @override
  List<Object> get props => [message];
}
