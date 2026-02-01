import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/reading_theme_model.dart';
import '../../data/repositories/reading_settings_repository.dart';
import 'reading_settings_state.dart';

class ReadingSettingsCubit extends Cubit<ReadingSettingsState> {
  final ReadingSettingsRepository _repository;

  ReadingSettingsCubit(this._repository) : super(ReadingSettingsInitial()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final theme = await _repository.loadTheme();
    final scrollModeIndex = await _repository.loadScrollMode();
    final scrollMode =
        ReadingScrollMode.values[scrollModeIndex]; // Safe if index is correct

    emit(ReadingSettingsLoaded(theme: theme, scrollMode: scrollMode));
  }

  Future<void> updateTheme(ReadingTheme newTheme) async {
    if (state is ReadingSettingsLoaded) {
      final currentState = state as ReadingSettingsLoaded;
      emit(currentState.copyWith(theme: newTheme));
      await _repository.saveThemeId(newTheme.id);
    } else {
      // Fallback if somehow not loaded
      emit(
        ReadingSettingsLoaded(
          theme: newTheme,
          scrollMode: ReadingScrollMode.vertical,
        ),
      );
      await _repository.saveThemeId(newTheme.id);
    }
  }

  Future<void> updateScrollMode(ReadingScrollMode newMode) async {
    if (state is ReadingSettingsLoaded) {
      final currentState = state as ReadingSettingsLoaded;
      emit(currentState.copyWith(scrollMode: newMode));
      await _repository.saveScrollMode(newMode.index);
    }
  }
}
