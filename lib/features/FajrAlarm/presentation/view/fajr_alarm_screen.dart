import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../services/fajr_alarm_service.dart';
import '../../data/fajr_question_model.dart';
import 'dart:async';

class FajrAlarmScreen extends StatefulWidget {
  const FajrAlarmScreen({super.key});

  @override
  State<FajrAlarmScreen> createState() => _FajrAlarmScreenState();
}

class _FajrAlarmScreenState extends State<FajrAlarmScreen> {
  final FajrAlarmService _service = FajrAlarmService();
  List<FajrQuestion> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _feedbackMessage;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _startAlarm();
  }

  Future<void> _startAlarm() async {
    // 1. Load Questions (3 questions to ensure wakefulness)
    final qs = await _service.getQuestions(3);
    if (mounted) {
      setState(() {
        _questions = qs;
        _isLoading = false;
      });
    }

    // 2. Start Sound (Looping)
    _service.startAlarmSound();
  }

  @override
  void dispose() {
    // Ensure sound stops handled
    super.dispose();
  }

  void _handleAnswer(int index) {
    if (_questions.isEmpty) return;
    
    final currentQuestion = _questions[_currentIndex];

    if (index == currentQuestion.correct) {
      // Correct!
      if (_currentIndex < _questions.length - 1) {
        // Next Question
        setState(() {
          _currentIndex++;
          _feedbackMessage = null; // Clear feedback for next Q
        });
      } else {
        // All Done!
        setState(() {
          _isSuccess = true;
          _feedbackMessage = "أحسنت! تقبل الله صلاتك 🕌";
        });
        _service.stopAlarmSound();

        // Delay to show success then close
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } else {
      // Wrong
      setState(() {
        _feedbackMessage = "إجابة خاطئة، حاول مرة أخرى!";
      });
      // Sound continues...
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prevent back button
    return PopScope(
      canPop: _isSuccess, // Only pop if success
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header Animation
                    const SizedBox(height: 30),

                    // Progress Indicator
                    Text(
                      "سؤال ${_currentIndex + 1} من ${_questions.length}",
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Title
                    Text(
                      "صلاة الفجر خير من النوم",
                      style: GoogleFonts.tajawal(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "أجب عن ${_questions.length} أسئلة لإيقاف المنبه",
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Question Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _questions[_currentIndex].question,
                            style: GoogleFonts.tajawal(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_feedbackMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                _feedbackMessage!,
                                style: GoogleFonts.tajawal(
                                  color: _isSuccess || _feedbackMessage!.contains("أحسنت")
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Answers
                    ...List.generate(_questions[_currentIndex].answers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSuccess
                                ? null
                                : () => _handleAnswer(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _questions[_currentIndex].answers[index],
                              style: GoogleFonts.tajawal(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }
}
