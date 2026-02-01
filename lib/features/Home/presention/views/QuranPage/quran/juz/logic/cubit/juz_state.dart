import '../../data/juz_model.dart';

abstract class JuzState {}

class JuzInitial extends JuzState {}

class JuzLoading extends JuzState {}

class JuzLoaded extends JuzState {
  final List<JuzUiModel> juzList;

  JuzLoaded(this.juzList);
}

class JuzUiModel {
  final JuzModel data;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final bool isCurrent; // Defines if this is the active Juz being read

  JuzUiModel({
    required this.data,
    required this.progress,
    required this.isCompleted,
    required this.isCurrent,
  });

  JuzUiModel copyWith({double? progress, bool? isCompleted, bool? isCurrent}) {
    return JuzUiModel(
      data: data,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}
