import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'salat_formula_share_card.dart';

class SalatBenefitItem extends StatelessWidget {
  final String title;
  final String content;
  final String note;

  const SalatBenefitItem({
    super.key,
    required this.title,
    required this.content,
    required this.note,
  });

  Future<void> _shareFormula(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
      );

      final ScreenshotController screenshotController = ScreenshotController();
      final double pixelRatio = MediaQuery.of(context).devicePixelRatio;

      final Uint8List imageBytes = await screenshotController.captureFromWidget(
        SalatFormulaShareCard(title: title, content: content),
        delay: const Duration(milliseconds: 100),
        pixelRatio: pixelRatio > 2 ? pixelRatio : 3.0,
      );

      Navigator.pop(context); // Close loading

      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/formula_share_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await imagePath.writeAsBytes(imageBytes);

      await Share.shareXFiles([
        XFile(imagePath.path),
      ], text: '$title\n$content\nتطبيق ركن الراحة');
    } catch (e) {
      Navigator.pop(context); // Ensure loading closes on error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء المشاركة: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _shareFormula(context),
                icon: const Icon(
                  Icons.share,
                  color: Color(0xFFD4AF37),
                  size: 20,
                ),
                tooltip: "مشاركة كصورة",
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: GoogleFonts.amiri(
              color: Colors.white70,
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              note,
              style: GoogleFonts.tajawal(
                color: const Color(0xFFD4AF37),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
