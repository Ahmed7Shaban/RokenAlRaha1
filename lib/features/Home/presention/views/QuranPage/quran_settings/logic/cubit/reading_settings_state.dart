import 'package:equatable/equatable.dart';
import '../../data/models/reading_theme_model.dart';

enum ReadingScrollMode { vertical, horizontal }

abstract class ReadingSettingsState extends Equatable {
  const ReadingSettingsState();

  @override
  List<Object> get props => [];
}

class ReadingSettingsInitial extends ReadingSettingsState {}

class ReadingSettingsLoaded extends ReadingSettingsState {
  final ReadingTheme theme;
  final ReadingScrollMode scrollMode;

  const ReadingSettingsLoaded({required this.theme, required this.scrollMode});

  @override
  List<Object> get props => [theme, scrollMode];

  ReadingSettingsLoaded copyWith({
    ReadingTheme? theme,
    ReadingScrollMode? scrollMode,
  }) {
    return ReadingSettingsLoaded(
      theme: theme ?? this.theme,
      scrollMode: scrollMode ?? this.scrollMode,
    );
  }
}
