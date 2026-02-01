import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../cubit/quiz_state.dart';
import 'quiz_share_view.dart';
import 'achievement_share_view.dart';
import '../quiz_model.dart'; // Ensure imports are correct

class StatsBottomSheet extends StatelessWidget {
  final List<QuestionResult> history;

  const StatsBottomSheet({super.key, required this.history});

  /// Share a specific question item
  Future<void> _shareItem(BuildContext context, QuestionResult item) async {
    try {
      // 1. Capture Image using QuizShareView
      final ScreenshotController controller = ScreenshotController();
      final Uint8List imageBytes = await controller.captureFromWidget(
        Material(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: QuizShareView(result: item),
          ),
        ),
        pixelRatio: 2.0,
        delay: const Duration(milliseconds: 10),
      );

      // 2. Save & Share
      await _saveAndShare(
        imageBytes,
        'انظر إلى إجابتي على هذا السؤال في ركن الراحة!',
      );
    } catch (e) {
      _showError(context, e);
    }
  }

  /// Share general achievement stats
  Future<void> _shareGeneralStats(BuildContext context) async {
    try {
      // Calculate stats
      final int total = history.length;
      final int correct = history.where((i) => i.isCorrect).length;
      final int wrong = total - correct;

      // 1. Capture Image using AchievementShareView
      final ScreenshotController controller = ScreenshotController();
      final Uint8List imageBytes = await controller.captureFromWidget(
        Material(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: AchievementShareView(
              totalAnswered: total,
              correctCount: correct,
              wrongCount: wrong,
            ),
          ),
        ),
        pixelRatio: 2.0,
        delay: const Duration(milliseconds: 10),
      );

      // 2. Save & Share
      await _saveAndShare(
        imageBytes,
        'لقد أجبت على $total أسئلة في مسابقة ركن الراحة! هل يمكنك التغلب علي؟',
      );
    } catch (e) {
      _showError(context, e);
    }
  }

  Future<void> _saveAndShare(Uint8List bytes, String text) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath =
        '${directory.path}/share_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(imagePath);
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(imagePath)], text: text);
  }

  void _showError(BuildContext context, Object e) {
    debugPrint("Sharing failed: $e");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("فشلت المشاركة: $e")));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E), // Dark grey background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(top: 16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            "سجل الإجابات",
            style: GoogleFonts.tajawal(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          Expanded(
            child: history.isEmpty
                ? Center(
                    child: Text(
                      "لا توجد إجابات مسجلة بعد",
                      style: GoogleFonts.tajawal(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      // Reverse index to show latest first
                      final item = history[history.length - 1 - index];
                      final isCorrect = item.isCorrect;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCorrect
                                ? Colors.green.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors
                                .transparent, // Remove line between title and children
                          ),
                          child: ExpansionTile(
                            iconColor: AppColors.primaryColor,
                            collapsedIconColor: Colors.white54,
                            leading: Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                            ),
                            title: Text(
                              item.question.q,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.tajawal(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Question Full Text
                                    Text(
                                      item.question.q,
                                      style: GoogleFonts.tajawal(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // User Answer
                                    _buildAnswerRow(
                                      "إجابتك:",
                                      item.userAnswer.answer,
                                      isCorrect
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                    ),

                                    // Correct Answer (if wrong)
                                    if (!isCorrect) ...[
                                      const SizedBox(height: 8),
                                      _buildAnswerRow(
                                        "الإجابة الصحيحة:",
                                        item.question.answers
                                            .firstWhere((a) => a.isCorrect)
                                            .answer,
                                        Colors.greenAccent,
                                      ),
                                    ],

                                    const SizedBox(height: 16),
                                    // Share Item Button
                                    Center(
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _shareItem(context, item),
                                        icon: const Icon(Icons.share, size: 18),
                                        label: Text(
                                          "مشاركة النتيجة",
                                          style: GoogleFonts.tajawal(),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryColor,
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // General Statistics Share Button
          if (history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _shareGeneralStats(context),
                  icon: const Icon(
                    Icons.emoji_events_outlined,
                    color: Colors.white,
                  ),
                  label: Text(
                    "مشاركة بطاقة الإنجاز",
                    style: GoogleFonts.tajawal(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerRow(String label, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label ",
          style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 12),
        ),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.tajawal(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
