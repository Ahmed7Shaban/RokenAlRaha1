class FajrQuestion {
  final String question;
  final List<String> answers;
  final int correct;

  FajrQuestion({
    required this.question,
    required this.answers,
    required this.correct,
  });

  factory FajrQuestion.fromJson(Map<String, dynamic> json) {
    return FajrQuestion(
      question: json['question'],
      answers: List<String>.from(json['answers']),
      correct: json['correct'],
    );
  }
}
