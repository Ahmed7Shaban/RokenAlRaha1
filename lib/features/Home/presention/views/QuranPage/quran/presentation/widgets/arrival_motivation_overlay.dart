import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';

class ArrivalMotivationOverlay extends StatefulWidget {
  final String surahName;
  final int ayahNumber;
  final int juzNumber;
  final String message;

  const ArrivalMotivationOverlay({
    Key? key,
    required this.surahName,
    required this.ayahNumber,
    required this.juzNumber,
    required this.message,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String surahName,
    required int ayahNumber,
    required int juzNumber,
  }) {
    // List of motivational messages
    final messages = [
      "بارك الله فيك، استمر في الارتقاء بكتاب الله.",
      "هنيئاً لك هذه الجلسة المباركة مع القرآن.",
      "القرآن نور للقلب، ونور للدرب.",
      "اقرأ وارتقِ، فإن منزلتك عند آخر آية تقرؤها.",
      "زادك الله حرصاً وتوفيقاً.",
      "طبت وطاب ممشاك وتبوأت من الجنة منزلاً.",
      "جعله الله حجة لك وشافعاً يوم القيامة.",
      "نور الله قلبك بنور القرآن.",
      "ما أجمل الثبات مع كلام الله.",
      "كل آية تقرؤها ترفعك درجة.",
      "سعيد من جعل القرآن رفيق دربه.",
      "رزقك الله لذة القرب من كتابه.",
      "القرآن حياةٌ للقلوب المطمئنة.",
      "طريقك مع القرآن طريق نور.",
      "استمرارك دليل إخلاصك، فاثبت.",
      "هنيئاً لقلبٍ اختار القرآن أنيساً.",
      "القرآن سلامٌ يسكن القلب.",
      "زادك الله بصيرةً وطمأنينة.",
      "من لازم القرآن علت منزلته.",
      "نور الآيات يبدد ظلمة الأيام.",
      "كل وقفة مع القرآن عبادة.",
      "بورك وقتك ما دمت مع كتاب الله.",
      "في كل تلاوة رفعة وطمأنينة.",
      "جعلك الله من أهل القرآن وخاصته.",
      "ما دمت مع القرآن فأنت في حفظ الله.",
    ];

    final randomMessage = messages[Random().nextInt(messages.length)];

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: curvedAnimation,
          child: FadeTransition(
            opacity: curvedAnimation,
            child: ArrivalMotivationOverlay(
              surahName: surahName,
              ayahNumber: ayahNumber,
              juzNumber: juzNumber,
              message: randomMessage,
            ),
          ),
        );
      },
    );
  }

  @override
  State<ArrivalMotivationOverlay> createState() =>
      _ArrivalMotivationOverlayState();
}

class _ArrivalMotivationOverlayState extends State<ArrivalMotivationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _scaleAnim = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🌿 Decoration / Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.spa_rounded,
                    size: 40,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  "أحسنت صنعاً!",
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Location Info
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "الجزء ${widget.juzNumber}",
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            "سورة ${widget.surahName}",
                            style: GoogleFonts.amiri(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "آية ${widget.ayahNumber}",
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Motivational Message
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    height: 1.6,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 24),

                // Dismiss Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "متابعة",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
