import 'package:equatable/equatable.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/models/hadith_book.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/models/hadith_content.dart';

abstract class HadithHomeState extends Equatable {
  const HadithHomeState();

  @override
  List<Object?> get props => [];
}

class HadithHomeInitial extends HadithHomeState {}

class HadithHomeLoading extends HadithHomeState {}

class HadithHomeLoaded extends HadithHomeState {
  final HadithContent hadith;
  final HadithBook book;

  const HadithHomeLoaded({required this.hadith, required this.book});

  @override
  List<Object?> get props => [hadith, book];
}

class HadithHomeError extends HadithHomeState {
  final String message;

  const HadithHomeError(this.message);

  @override
  List<Object?> get props => [message];
}
