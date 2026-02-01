import 'package:equatable/equatable.dart';
import '../data/models/khatma_model.dart';
import '../data/models/daily_ward_model.dart';

abstract class KhatmaState extends Equatable {
  const KhatmaState();

  @override
  List<Object?> get props => [];
}

class KhatmaInitial extends KhatmaState {}

class KhatmaLoading extends KhatmaState {}

class KhatmaLoaded extends KhatmaState {
  final List<KhatmaModel> khatmas;
  final KhatmaModel? activeKhatma;
  final List<DailyWard> wards;
  final int streak;
  final int totalCompleted;

  const KhatmaLoaded({
    this.khatmas = const [],
    this.activeKhatma,
    this.wards = const [],
    this.streak = 0,
    this.totalCompleted = 0,
  });

  KhatmaLoaded copyWith({
    List<KhatmaModel>? khatmas,
    KhatmaModel? activeKhatma,
    List<DailyWard>? wards,
    int? streak,
    int? totalCompleted,
  }) {
    return KhatmaLoaded(
      khatmas: khatmas ?? this.khatmas,
      activeKhatma: activeKhatma ?? this.activeKhatma,
      wards: wards ?? this.wards,
      streak: streak ?? this.streak,
      totalCompleted: totalCompleted ?? this.totalCompleted,
    );
  }

  @override
  List<Object?> get props => [
    khatmas,
    activeKhatma,
    wards,
    streak,
    totalCompleted,
  ];
}

class KhatmaError extends KhatmaState {
  final String message;
  const KhatmaError(this.message);
  @override
  List<Object> get props => [message];
}
