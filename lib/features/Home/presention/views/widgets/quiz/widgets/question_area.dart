import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../quiz_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QuestionArea extends StatelessWidget {
  final QuizQuestion question;
  final Answer? selectedAnswer;
  final bool isAnswered;
  final Function(Answer) onAnswerSelected;

  const QuestionArea({
    super.key,
    required this.question,
    required this.selectedAnswer,
    required this.isAnswered,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question Text
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child:
              Text(
                    question.q,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.6,
                    ),
                  )
                  .animate(key: ValueKey(question.id))
                  .fadeIn(duration: 400.ms)
                  .moveY(begin: 10, end: 0),
        ),

        const SizedBox(height: 10),

        // Answers
        ...question.answers.map((answer) {
          final isSelected = selectedAnswer == answer;

          Color bgColor = Colors.white.withOpacity(0.1);
          Color borderColor = Colors.white24;
          Color textColor = Colors.white;

          if (isAnswered) {
            if (isSelected) {
              bgColor = answer.isCorrect
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2);
              borderColor = answer.isCorrect ? Colors.green : Colors.red;
            } else if (answer.isCorrect) {
              // Show correct answer if wrong was selected
              bgColor = Colors.green.withOpacity(0.2);
              borderColor = Colors.green;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isAnswered ? null : () => onAnswerSelected(answer),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          answer.answer,
                          style: GoogleFonts.tajawal(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isAnswered && (isSelected || answer.isCorrect))
                        Icon(
                          answer.isCorrect ? Icons.check_circle : Icons.cancel,
                          color: answer.isCorrect
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
