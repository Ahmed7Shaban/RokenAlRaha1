import 'package:equatable/equatable.dart';
import '../quiz_model.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final QuizQuestion currentQuestion;
  final int currentIndex;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final List<QuestionResult> history;
  final Answer? selectedAnswer; // Null if waiting for input
  final bool isAnswered; // True if user selected an answer for current
  final bool isShareWithHighlight; // New: Share settings

  const QuizLoaded({
    required this.currentQuestion,
    required this.currentIndex,
    required this.totalQuestions,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.history = const [],
    this.selectedAnswer,
    this.isAnswered = false,
    this.isShareWithHighlight = false, // Default false
  });

  QuizLoaded copyWith({
    QuizQuestion? currentQuestion,
    int? currentIndex,
    int? totalQuestions,
    int? correctCount,
    int? wrongCount,
    List<QuestionResult>? history,
    Answer? selectedAnswer,
    bool? isAnswered,
    bool? isShareWithHighlight,
  }) {
    return QuizLoaded(
      currentQuestion: currentQuestion ?? this.currentQuestion,
      currentIndex: currentIndex ?? this.currentIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      history: history ?? this.history,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isAnswered: isAnswered ?? this.isAnswered,
      isShareWithHighlight: isShareWithHighlight ?? this.isShareWithHighlight,
    );
  }

  @override
  List<Object?> get props => [
    currentQuestion,
    currentIndex,
    totalQuestions,
    correctCount,
    wrongCount,
    history,
    selectedAnswer,
    isAnswered,
    isShareWithHighlight,
  ];
}

class QuizFinished extends QuizState {
  final int correctCount;
  final int wrongCount;
  final List<QuestionResult> history;

  const QuizFinished({
    required this.correctCount,
    required this.wrongCount,
    required this.history,
  });

  @override
  List<Object?> get props => [correctCount, wrongCount, history];
}

class QuizError extends QuizState {
  final String message;

  const QuizError(this.message);

  @override
  List<Object?> get props => [message];
}

class QuestionResult extends Equatable {
  final QuizQuestion question;
  final Answer userAnswer;
  final bool isCorrect;

  const QuestionResult({
    required this.question,
    required this.userAnswer,
    required this.isCorrect,
  });

  @override
  List<Object?> get props => [question, userAnswer, isCorrect];

  Map<String, dynamic> toJson() {
    return {
      'question': question.toJson(),
      'userAnswer': userAnswer.toJson(),
      'isCorrect': isCorrect,
    };
  }

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      question: QuizQuestion.fromJson(json['question']),
      userAnswer: Answer.fromJson(json['userAnswer']),
      isCorrect: json['isCorrect'] as bool,
    );
  }
}
