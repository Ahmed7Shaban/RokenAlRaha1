import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cubit/quiz_state.dart';
import '../quiz_model.dart';
import 'custom_share_card.dart';

class QuizShareView extends StatelessWidget {
  final QuestionResult? result; // Provided if sharing from history
  final QuizQuestion? question; // Provided if sharing fresh question
  final bool showCorrectAnswer; // Logic from Settings for fresh question

  const QuizShareView({
    super.key,
    this.result,
    this.question,
    this.showCorrectAnswer = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine question source
    final QuizQuestion displayQuestion = result?.question ?? question!;

    return CustomShareCard(
      title: "اختبر معلوماتك الإسلامية",
      child: Column(
        children: [
          // The Question Text
          Text(
            displayQuestion.q,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              color: Colors.white,
              fontSize: 22, // Slightly larger
              height: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),

          // The Answers List
          ...displayQuestion.answers.map((answer) {
            Color borderColor = Colors.white12;
            Color bgColor = Colors.transparent;
            Color textColor = Colors.white70;
            IconData? icon;
            Color iconColor = Colors.transparent;

            // --- Logic for History Share (result != null) ---
            if (result != null) {
              final bool isUserAnswer =
                  (answer.answer == result!.userAnswer.answer);
              final bool isCorrect = answer.isCorrect;

              if (isCorrect) {
                // Correct Answer: Always Green
                borderColor = Colors.greenAccent;
                bgColor = Colors.green.withOpacity(0.1);
                textColor = Colors.white;
                icon = Icons.check_circle;
                iconColor = Colors.greenAccent;
              } else if (isUserAnswer && !result!.isCorrect) {
                // User's Wrong Answer: Red
                borderColor = Colors.redAccent;
                bgColor = Colors.red.withOpacity(0.1);
                textColor = Colors.white;
                icon = Icons.cancel;
                iconColor = Colors.redAccent;
              }
            }
            // --- Logic for Main Share (Fresh Question) ---
            else if (showCorrectAnswer && answer.isCorrect) {
              // Settings Enabled: Highlight Correct Answer
              borderColor = Colors.greenAccent;
              bgColor = Colors.green.withOpacity(0.1);
              textColor = Colors.white;
              icon = Icons.check_circle;
              iconColor = Colors.greenAccent;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      answer.answer,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, color: iconColor, size: 20),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
