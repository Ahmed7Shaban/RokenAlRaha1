import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quran/quran.dart' as quran;
import 'ayah_share_card.dart';

class AyahShareService {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> shareAyahAsImage(
    BuildContext context, {
    required int surahNumber,
    required int verseNumber,
    required String verseText,
    required Color backgroundColor,
    required Color textColor,
  }) async {
    // 1. Show loading
    // usage of rootNavigator: true ensures we are pushing to the top-most overlay,
    // avoiding issues with nested navigators.
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
      ),
    );

    try {
      // 2. Prepare Widget
      final surahName = quran.getSurahNameArabic(surahNumber);
      final widgetToCapture = AyahShareCard(
        surahNumber: surahNumber,
        verseNumber: verseNumber,
        verseText: verseText,
        surahName: surahName,
        backgroundColor: backgroundColor,
        textColor: textColor,
      );

      // 3. Capture
      final Uint8List imageBytes = await _screenshotController
          .captureFromWidget(
            widgetToCapture,
            delay: const Duration(milliseconds: 100),
            pixelRatio: 3.0,
            context: context,
          );

      // 4. Save to Temp
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = await File(
        '${tempDir.path}/ayah_share_$timestamp.png',
      ).create();
      await file.writeAsBytes(imageBytes);

      // 5. Hide Loading
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Small delay to ensure the dialog close animation finishes/doesn't conflict
      await Future.delayed(const Duration(milliseconds: 300));

      // 6. Share
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'آية من سورة $surahName\n$verseText',
        subject: 'مشاركة آية',
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      debugPrint("Ayah Share Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("حدث خطأ أثناء المشاركة: $e")));
      }
    }
  }
}
