import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../quiz_model.dart';
import 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit() : super(QuizInitial());

  List<QuizQuestion> _allQuestions = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  List<QuestionResult> _history = [];
  bool _isShareWithHighlight = false; // New: Settings variable

  /// تحميل الأسئلة من ملف JSON
  /// Load questions from JSON asset
  Future<void> loadQuestions() async {
    try {
      emit(QuizLoading());
      final String response = await rootBundle.loadString(
        'assets/json/IslamicQuiz.json',
      );
      final List<dynamic> data = json.decode(response);
      _allQuestions = data.map((json) => QuizQuestion.fromJson(json)).toList();
      _allQuestions.shuffle(); // Shuffle for variety

      if (_allQuestions.isNotEmpty) {
        // --- Initialization Logic: Check Saved Progress ---
        // التحقق من وجود "بيانات محفوظة" في الذاكرة المحلية
        final prefs = await SharedPreferences.getInstance();
        final savedIndex = prefs.getInt('quiz_index');

        // استعادة إعدادات المشاركة
        _isShareWithHighlight = prefs.getBool('quiz_share_highlight') ?? false;

        // استعادة الإحصائيات والتاريخ
        final savedCorrect = prefs.getInt('quiz_correct_count') ?? 0;
        final savedWrong = prefs.getInt('quiz_wrong_count') ?? 0;

        final savedHistoryString = prefs.getString('quiz_history');
        if (savedHistoryString != null) {
          final List<dynamic> decodedHistory = jsonDecode(savedHistoryString);
          _history = decodedHistory
              .map((e) => QuestionResult.fromJson(e))
              .toList();
        } else {
          _history = [];
        }

        // إذا كان هناك فهرس محفوظ، نبدأ منه، وإلا نبدأ من الصفر
        if (savedIndex != null && savedIndex < _allQuestions.length) {
          _currentIndex = savedIndex;
          _correctCount = savedCorrect;
          _wrongCount = savedWrong;
        } else {
          _currentIndex = 0;
          _correctCount = 0;
          _wrongCount = 0;
          _history = []; // Reset history if starting fresh
        }

        emit(
          QuizLoaded(
            currentQuestion: _allQuestions[_currentIndex],
            currentIndex: _currentIndex,
            totalQuestions: _allQuestions.length,
            correctCount: _correctCount,
            wrongCount: _wrongCount,
            history: _history,
            isShareWithHighlight: _isShareWithHighlight,
          ),
        );
      } else {
        emit(const QuizError("لا توجد أسئلة متاحة حالياً"));
      }
    } catch (e) {
      emit(QuizError("فشل تحميل الأسئلة: $e"));
    }
  }

  /// تحديث إعدادات المشاركة وحفظها
  Future<void> toggleShareHighlight(bool value) async {
    _isShareWithHighlight = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quiz_share_highlight', value);

    if (state is QuizLoaded) {
      emit((state as QuizLoaded).copyWith(isShareWithHighlight: value));
    }
  }

  /// دالة مساعدة لحفظ التقدم (الفهرس، الإحصائيات، والسجل)
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    // حفظ الفهرس الحالي
    await prefs.setInt('quiz_index', _currentIndex);
    // حفظ عدد الإجابات الصحيحة والخاطئة
    await prefs.setInt('quiz_correct_count', _correctCount);
    await prefs.setInt('quiz_wrong_count', _wrongCount);

    // حفظ سجل الإجابات كملف نصي JSON
    if (_history.isNotEmpty) {
      final historyJson = jsonEncode(_history.map((e) => e.toJson()).toList());
      await prefs.setString('quiz_history', historyJson);
    }
  }

  /// معالجة إجابة المستخدم
  /// Handle user answer selection
  void submitAnswer(Answer answer) {
    if (state is QuizLoaded) {
      final loadedState = state as QuizLoaded;
      if (loadedState.isAnswered) return; // Prevent multiple answers

      final isCorrect = answer.isCorrect;
      if (isCorrect) {
        _correctCount++;
      } else {
        _wrongCount++;
      }

      final result = QuestionResult(
        question: loadedState.currentQuestion,
        userAnswer: answer,
        isCorrect: isCorrect,
      );
      _history.add(result);

      // Show result (Color change) -> Then move next
      emit(
        loadedState.copyWith(
          selectedAnswer: answer,
          isAnswered: true,
          correctCount: _correctCount,
          wrongCount: _wrongCount,
          history: _history,
        ),
      );

      // Wait 1.5 seconds then move to next
      Future.delayed(const Duration(milliseconds: 1500), () {
        _nextQuestion();
      });
    }
  }

  /// الانتقال للسؤال التالي
  /// Move to next question
  void _nextQuestion() async {
    if (_currentIndex < _allQuestions.length - 1) {
      _currentIndex++;

      // حفظ التقدم الكامل
      await _saveProgress();

      emit(
        QuizLoaded(
          currentQuestion: _allQuestions[_currentIndex],
          currentIndex: _currentIndex,
          totalQuestions: _allQuestions.length,
          correctCount: _correctCount,
          wrongCount: _wrongCount,
          history: _history,
          selectedAnswer: null,
          isAnswered: false,
          isShareWithHighlight: _isShareWithHighlight,
        ),
      );
    } else {
      // عند الانتهاء، نحذف التقدم لكي يبدأ من جديد مستقبلاً
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('quiz_index');
      await prefs.remove('quiz_correct_count');
      await prefs.remove('quiz_wrong_count');
      await prefs.remove('quiz_history');

      // Note: We do NOT remove quiz_share_highlight preference as it's a global setting

      emit(
        QuizFinished(
          correctCount: _correctCount,
          wrongCount: _wrongCount,
          history: _history,
        ),
      );
    }
  }

  /// إعادة تعيين الاختبار
  /// Reset Quiz
  void resetQuiz() async {
    // إزالة جميع البيانات المحفوظة
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quiz_index');
    await prefs.remove('quiz_correct_count');
    await prefs.remove('quiz_wrong_count');
    await prefs.remove('quiz_history');

    _allQuestions.shuffle();
    _currentIndex = 0;
    _correctCount = 0;
    _wrongCount = 0;
    _history = [];
    if (_allQuestions.isNotEmpty) {
      emit(
        QuizLoaded(
          currentQuestion: _allQuestions[_currentIndex],
          currentIndex: _currentIndex,
          totalQuestions: _allQuestions.length,
          isShareWithHighlight: _isShareWithHighlight,
        ),
      );
    } else {
      loadQuestions();
    }
  }
}
