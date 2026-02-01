class QuizQuestion {
  final int id;
  final String q;
  final List<Answer> answers;
  final String category;
  final String topic;

  QuizQuestion({
    required this.id,
    required this.q,
    required this.answers,
    required this.category,
    required this.topic,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      q: json['q'],
      answers: (json['answers'] as List)
          .map((e) => Answer.fromJson(e))
          .toList(),
      category: json['category'],
      topic: json['topic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'q': q,
      'answers': answers.map((e) => e.toJson()).toList(),
      'category': category,
      'topic': topic,
    };
  }
}

class Answer {
  final String answer;
  final int t; // 1 = Correct, 0 = Wrong

  Answer({required this.answer, required this.t});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(answer: json['answer'], t: json['t']);
  }

  Map<String, dynamic> toJson() {
    return {'answer': answer, 't': t};
  }

  bool get isCorrect => t == 1;
}
