import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/sharing/quran_splitter_logic.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/sharing/quran_image_generator.dart';

class QuranShareService {
  final QuranImageGenerator _imageGenerator = QuranImageGenerator();

  /// Main entry point to share a Quran page.
  /// Handles splitting, generating images, saving to temp, and invoking standard share.
  Future<void> sharePage(
    BuildContext context,
    int pageNumber,
    dynamic fullJsonData,
  ) async {
    // 1. Show Loading Indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("جاري تحضير الصفحة للمشاركة..."),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // 2. Prepare Data & Split
      final List<dynamic> dataAsList = fullJsonData as List<dynamic>;

      // Calculate chunks. 900 chars is a safe limit for high quality legible images.
      final chunks = QuranSplitterLogic.splitPageData(
        dataAsList,
        maxCharsPerPart: 900,
      );

      if (chunks.isEmpty) throw Exception("لا توجد بيانات لهذه الصفحة");

      // 3. Clean up old share files to keep storage clean
      final tempDir = await getTemporaryDirectory();
      await _cleanOldShareFiles(tempDir);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      List<XFile> filesToShare = [];

      // 4. Generate Images for each chunk
      for (int i = 0; i < chunks.length; i++) {
        final chunk = chunks[i];
        final isFirst = i == 0;
        final isLast = i == chunks.length - 1;

        final imageBytes = await _imageGenerator.generateImageBytes(
          context,
          pageIndex: pageNumber,
          fullJsonData: dataAsList,
          chunkData: chunk,
          isFirstChunk: isFirst,
          isLastChunk: isLast,
        );

        if (imageBytes != null) {
          final file = File(
            '${tempDir.path}/quran_share_${pageNumber}_part${i + 1}_$timestamp.png',
          );
          await file.writeAsBytes(imageBytes);
          filesToShare.add(XFile(file.path));
        } else {
          debugPrint("Failed to generate image for part ${i + 1}");
        }
      }

      // 5. Dismiss Loading
      if (context.mounted) Navigator.pop(context);

      // 6. Share
      if (filesToShare.isNotEmpty) {
        // We use a slight delay to ensure dialog closure animation is smooth
        await Future.delayed(const Duration(milliseconds: 200));

        await Share.shareXFiles(
          filesToShare,
          text: 'ركن الراحة - صفحة $pageNumber',
          subject: 'مشاركة صفحة قرآنية',
        );
      } else {
        _showError(context, "فشل إنشاء الصورة. يرجى المحاولة مرة أخرى.");
      }
    } catch (e) {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // Pop loading if error
      }
      debugPrint("Share Service Error: $e");
      _showError(context, "حدث خطأ أثناء المشاركة: $e");
    }
  }

  Future<void> _cleanOldShareFiles(Directory tempDir) async {
    try {
      final List<FileSystemEntity> files = tempDir.listSync();
      for (final file in files) {
        if (file is File && file.path.contains("quran_share_")) {
          // Verify if it's older than 1 hour or just delete all previous?
          // For safety, let's just delete all "quran_share_" files to keep it clean.
          try {
            await file.delete();
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint("Cleanup warning: $e");
    }
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
