part of 'ayah_tafsir_cubit.dart';

abstract class AyahTafsirState extends Equatable {
  const AyahTafsirState();

  @override
  List<Object?> get props => [];
}

class AyahTafsirInitial extends AyahTafsirState {}

class AyahTafsirLoading extends AyahTafsirState {
  // If we are loading only the content, we might still want to show the sheet structure.
  // But this state usually implies full screen loading or specific section loading.
}

class AyahTafsirLoaded extends AyahTafsirState {
  final TafsirContent? currentContent;
  final List<TafsirMetaData> availableTafsirs;
  final int currentTafsirId;

  final String? errorMessage;

  const AyahTafsirLoaded({
    this.currentContent,
    this.availableTafsirs = const [],
    required this.currentTafsirId,
    this.errorMessage,
  });

  AyahTafsirLoaded copyWith({
    TafsirContent? currentContent,
    List<TafsirMetaData>? availableTafsirs,
    int? currentTafsirId,
    String? errorMessage,
  }) {
    return AyahTafsirLoaded(
      currentContent: currentContent ?? this.currentContent,
      availableTafsirs: availableTafsirs ?? this.availableTafsirs,
      currentTafsirId: currentTafsirId ?? this.currentTafsirId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    currentContent,
    availableTafsirs,
    currentTafsirId,
    errorMessage,
  ];
}

class AyahTafsirError extends AyahTafsirState {
  final String message;
  const AyahTafsirError(this.message);
  @override
  List<Object?> get props => [message];
}
