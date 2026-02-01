import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../cubit/quiz_cubit.dart';
import '../cubit/quiz_state.dart';
import 'question_area.dart';
import 'quiz_header.dart';
import 'quiz_share_view.dart';
import 'stats_bottom_sheet.dart';

class QuizMainCard extends StatefulWidget {
  const QuizMainCard({super.key});

  @override
  State<QuizMainCard> createState() => _QuizMainCardState();
}

class _QuizMainCardState extends State<QuizMainCard> {
  Future<void> _handleShare(BuildContext context, QuizState state) async {
    if (state is! QuizLoaded) return;

    try {
      // 1. Capture Custom Widget using Global Settings (isShareWithHighlight)
      final ScreenshotController tempController = ScreenshotController();
      final Uint8List imageBytes = await tempController.captureFromWidget(
        Material(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: QuizShareView(
              question: state.currentQuestion,
              showCorrectAnswer: state.isShareWithHighlight,
            ),
          ),
        ),
        pixelRatio: 2.0,
        delay: const Duration(milliseconds: 10),
      );

      // 2. Save & Share
      final directory = await getApplicationDocumentsDirectory();
      final imagePath =
          '${directory.path}/quiz_share_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(imagePath);
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'هل يمكنك الإجابة على هذا السؤال؟ اختبر نفسك مع تطبيق ركن الراحة',
      );
    } catch (e) {
      debugPrint('Error sharing: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("فشلت المشاركة: $e")));
      }
    }
  }

  void _showShareSettings(BuildContext context) {
    // Capture the cubit from the current context before showing the sheet
    // to avoid ProviderNotFoundException
    final quizCubit = context.read<QuizCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (ctx) {
        // Wrap with BlocProvider.value to give access to the existing cubit
        return BlocProvider.value(
          value: quizCubit,
          child: BlocBuilder<QuizCubit, QuizState>(
            builder: (context, state) {
              final isHighlightEnabled = (state is QuizLoaded)
                  ? state.isShareWithHighlight
                  : false;

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "إعدادات المشاركة",
                      style: GoogleFonts.tajawal(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "إظهار الإجابة الصحيحة عند المشاركة",
                          style: GoogleFonts.tajawal(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Switch(
                          value: isHighlightEnabled,
                          activeColor: AppColors.primaryColor,
                          onChanged: (val) {
                            // Update Cubit state which saves to Prefs
                            quizCubit.toggleShareHighlight(val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isHighlightEnabled
                          ? "سيتم تمييز الإجابة الصحيحة باللون الأخضر في الصورة المشاركة."
                          : "ستظهر الخيارات بشكل محايد دون تمييز الإجابة.",
                      style: GoogleFonts.tajawal(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Pattern Overlay
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: Image.asset(
                  'assets/Images/ramadan.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: BlocBuilder<QuizCubit, QuizState>(
                builder: (context, state) {
                  if (state is QuizLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFD4AF37),
                      ),
                    );
                  } else if (state is QuizError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  } else if (state is QuizLoaded) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        QuizHeader(
                          correct: state.correctCount,
                          wrong: state.wrongCount,
                          onStatsTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled:
                                  true, // For better height control
                              builder: (_) =>
                                  StatsBottomSheet(history: state.history),
                            );
                          },
                          onSettingsTap: () => _showShareSettings(context),
                          onShareTap: () => _handleShare(context, state),
                        ),
                        const Divider(color: Colors.white12, height: 24),
                        QuestionArea(
                          question: state.currentQuestion,
                          selectedAnswer: state.selectedAnswer,
                          isAnswered: state.isAnswered,
                          onAnswerSelected: (answer) =>
                              context.read<QuizCubit>().submitAnswer(answer),
                        ),

                        // Question Counter
                        const SizedBox(height: 12),
                        Text(
                          "السؤال ${state.currentIndex + 1} من ${state.totalQuestions}",
                          style: GoogleFonts.tajawal(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    );
                  } else if (state is QuizFinished) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFFD4AF37),
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "أحسنت! أكملت الاختبار",
                            style: GoogleFonts.tajawal(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "أجبت بشكل صحيح على ${state.correctCount} من أصل ${state.correctCount + state.wrongCount}",
                            style: GoogleFonts.tajawal(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<QuizCubit>().resetQuiz(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.black,
                            ),
                            child: Text(
                              "إعادة الاختبار",
                              style: GoogleFonts.tajawal(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),

            // Branding Footer (Visible in Widget Only, not Share)
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Roken Al Raha  •  ركن الراحة",
                  style: GoogleFonts.tajawal(
                    fontSize: 8,
                    color: Colors.white12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
