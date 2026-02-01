import '../../data/hizb_model.dart';

abstract class HizbState {}

class HizbInitial extends HizbState {}

class HizbLoading extends HizbState {}

class HizbLoaded extends HizbState {
  final List<HizbUiModel> hizbList;
  final bool hasReachedMax;
  final bool isLoadingMore;

  HizbLoaded(
    this.hizbList, {
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  HizbLoaded copyWith({
    List<HizbUiModel>? hizbList,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return HizbLoaded(
      hizbList ?? this.hizbList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class HizbError extends HizbState {
  final String message;
  HizbError(this.message);
}

// UI Models to hold presentation state
class HizbUiModel {
  final HizbModel data;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final bool isCurrent;
  final List<HizbQuarterUiModel> quarters;

  HizbUiModel({
    required this.data,
    required this.progress,
    required this.isCompleted,
    required this.isCurrent,
    required this.quarters,
  });
}

class HizbQuarterUiModel {
  final HizbQuarter data;
  final double progress;
  final bool isCompleted;
  final bool isCurrent;
  final int targetPage;
  final int targetSurah;
  final int targetAyah;

  HizbQuarterUiModel({
    required this.data,
    required this.progress,
    required this.isCompleted,
    required this.isCurrent,
    required this.targetPage,
    required this.targetSurah,
    required this.targetAyah,
  });
}
