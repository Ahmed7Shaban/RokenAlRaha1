part of 'masbaha_cubit.dart';

abstract class MasbahaState {}

class MisbahaInitial extends MasbahaState {}

class MasbahaListLoaded extends MasbahaState {
  final List<String> tasbeehItems;
  final List<String> istighfarItems;
  final List<Map<String, dynamic>>
  customItems; // Stores full objects for details

  MasbahaListLoaded({
    required this.tasbeehItems,
    required this.istighfarItems,
    this.customItems = const [],
  });
}

class MisbahaUpdated extends MasbahaState {
  final int count;
  final int seconds;
  final bool isMilestone;

  MisbahaUpdated({
    required this.count,
    required this.seconds,
    required this.isMilestone,
    this.score = 0,
  });

  final int score;
}
