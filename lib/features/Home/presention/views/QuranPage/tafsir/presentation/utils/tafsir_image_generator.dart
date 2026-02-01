import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class TafsirImageGenerator {
  /// Generates images for the given Tafsir text, splitting it into multiple pages if necessary.
  /// Generates a single card-style image for the given Tafsir text.
  /// The image height is dynamic based on content length.
  /// Generates a single card-style image for sharing content (Tafsir, I'raab, etc.)
  /// The image height is dynamic based on content length.
  /// Generates card-style images for sharing content.
  /// Automatically splits into multiple images if content is too long.
  static Future<List<XFile>> generateCardImage({
    required int surahNumber,
    required String surahName,
    required int verseNumber,
    required String verseText,
    required String contentText,
    required String title,
    required BuildContext context,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final cleanContent = contentText.trim();

    // --- Configuration ---
    const double canvasWidth = 1080.0;
    const double maxCanvasHeight = 1920.0; // Max vertical resolution per part
    const double cardMargin = 60.0;
    const double cardPadding = 60.0;
    const double cardWidth = canvasWidth - (cardMargin * 2);
    const double contentWidth = cardWidth - (cardPadding * 2);

    // --- Colors ---
    const Color canvasBgColor = Color(0xFFF2F2F2);
    const Color cardBgColor = Colors.white;
    const Color textColor = Color(0xFF2D2D2D);
    const Color accentColor = Color(0xFF5d5491);
    const Color goldColor = Color(0xFFD4AF37);

    // --- Static Elements (Texts) ---

    // 1. Top Header (Surah + Verse) - Only on Page 1
    final topHeaderPara = _buildTextParagraph(
      "$surahName - الآية $verseNumber",
      width: contentWidth,
      fontSize: 32,
      fontFamily: 'Amiri',
      fontWeight: FontWeight.bold,
      color: Colors.grey,
      textAlign: TextAlign.center,
    );

    // 2. Verse Text - Only on Page 1
    final versePara = _buildTextParagraph(
      verseText,
      width: contentWidth,
      fontSize: 48,
      fontFamily: 'Amiri',
      fontWeight: FontWeight.bold,
      color: Colors.black,
      textAlign: TextAlign.center,
      height: 1.6,
    );

    // 3. Title (e.g. Tafsir) - On Page 1. Sub-pages get "Follows..."
    final titlePara = _buildTextParagraph(
      title,
      width: contentWidth,
      fontSize: 36,
      fontFamily: 'Amiri',
      fontWeight: FontWeight.bold,
      color: accentColor,
      textAlign: TextAlign.center,
    );

    // 4. Footer Texts (Branding) - On ALL Pages
    final footerTitlePara = _buildTextParagraph(
      "ركن الراحة",
      width: contentWidth,
      fontSize: 40,
      fontFamily: 'Amiri',
      fontWeight: FontWeight.bold,
      color: goldColor,
      textAlign: TextAlign.center,
    );
    final footerSubPara = _buildTextParagraph(
      "من تطبيق",
      width: contentWidth,
      fontSize: 24,
      fontFamily: 'Amiri',
      color: goldColor.withOpacity(0.8),
      textAlign: TextAlign.center,
    );

    // --- Height Calculations ---
    final double topHeaderH = topHeaderPara.height + 30;
    final double verseH = versePara.height + 50;
    final double titleH = titlePara.height + 30;
    final double footerH =
        footerTitlePara.height + footerSubPara.height + 60; // Extra padding

    // Calculate strict content area heights
    // Page 1 available content height
    final double page1StaticH =
        cardPadding +
        topHeaderH +
        verseH +
        titleH +
        footerH +
        cardPadding +
        (cardMargin * 2);
    final double page1MaxContentH = maxCanvasHeight - page1StaticH;

    // Subsequent pages available content height (Header is simpler)
    final double subPageHeaderH = 100.0; // "Follows..." header
    final double subPageStaticH =
        cardPadding + subPageHeaderH + footerH + cardPadding + (cardMargin * 2);
    final double subPageMaxContentH = maxCanvasHeight - subPageStaticH;

    // --- Split Text Logic ---
    List<String> textChunks = [];
    String remainingText = cleanContent;
    bool isFirstPage = true;

    // Loop to chunk text
    while (remainingText.isNotEmpty) {
      double availableH = isFirstPage ? page1MaxContentH : subPageMaxContentH;

      // If page 1, we might fit EVERYTHING in less than max height.
      // But initially, let's see how much fits in 'availableH'.

      final textPainter = TextPainter(
        text: TextSpan(
          text: remainingText,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 34,
            height: 1.8,
            color: textColor,
          ),
        ),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
      );
      textPainter.layout(maxWidth: contentWidth);

      if (textPainter.height <= availableH) {
        // Fits completely!
        textChunks.add(remainingText);
        break;
      } else {
        // Doesn't fit, need to find split index
        final splitIndex = _findSplitOffset(
          textPainter,
          availableH,
          remainingText,
        );
        final chunk = remainingText.substring(0, splitIndex).trim();
        textChunks.add(chunk);

        remainingText = remainingText.substring(splitIndex).trim();
        isFirstPage = false;

        // Safety break to prevent infinite loops if text is huge or logic fail
        if (textChunks.length > 20) break;
      }
    }

    // --- Generate Images ---
    List<XFile> generatedFiles = [];

    for (int i = 0; i < textChunks.length; i++) {
      final isPage1 = (i == 0);
      final chunkText = textChunks[i];

      // Re-measure content height for this specific chunk (it might be smaller than max)
      final chunkPara = _buildTextParagraph(
        chunkText,
        width: contentWidth,
        fontSize: 34,
        fontFamily: 'Amiri',
        color: textColor,
        height: 1.8,
        textAlign: TextAlign.justify,
      );

      // Prepare Page Header (Sub-page)
      final subHeaderPara = _buildTextParagraph(
        "تابع $title ... (${i + 1}/${textChunks.length})",
        width: contentWidth,
        fontSize: 28,
        fontFamily: 'Amiri',
        color: Colors.grey,
        textAlign: TextAlign.center,
      );

      // Calculate Dynamic Height for this Canvas
      double totalContentH = 0;
      if (isPage1) {
        totalContentH =
            cardPadding +
            topHeaderH +
            verseH +
            titleH +
            chunkPara.height +
            60 +
            footerH +
            cardPadding;
      } else {
        totalContentH =
            cardPadding +
            subPageHeaderH +
            chunkPara.height +
            60 +
            footerH +
            cardPadding;
      }

      double finalCanvasHeight = totalContentH + (cardMargin * 2);

      // Draw
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, canvasWidth, finalCanvasHeight),
      );

      // 1. Background
      canvas.drawColor(canvasBgColor, BlendMode.src);

      // 2. Card
      final cardRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cardMargin, cardMargin, cardWidth, totalContentH),
        const Radius.circular(40),
      );
      canvas.drawShadow(
        Path()..addRRect(cardRect),
        Colors.black.withOpacity(0.15),
        16.0,
        true,
      );
      canvas.drawRRect(cardRect, Paint()..color = cardBgColor);

      // 3. Content
      double currentY = cardMargin + cardPadding; // Start Y

      if (isPage1) {
        // Top Header
        canvas.drawParagraph(
          topHeaderPara,
          Offset(cardMargin + cardPadding, currentY),
        );
        currentY += topHeaderH;

        // Verse
        canvas.drawParagraph(
          versePara,
          Offset(cardMargin + cardPadding, currentY),
        );
        currentY += verseH;

        // Divider
        final dividerPaint = Paint()
          ..color = goldColor.withOpacity(0.2)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

        canvas.drawLine(
          Offset(cardMargin + cardPadding + 100, currentY - 20),
          Offset(canvasWidth - cardMargin - cardPadding - 100, currentY - 20),
          dividerPaint,
        );

        // Title
        canvas.drawParagraph(
          titlePara,
          Offset(cardMargin + cardPadding, currentY),
        );
        currentY += titleH;
      } else {
        // Sub Page Header
        canvas.drawParagraph(
          subHeaderPara,
          Offset(cardMargin + cardPadding, currentY),
        );
        currentY += subPageHeaderH;
      }

      // Chunk Content
      canvas.drawParagraph(
        chunkPara,
        Offset(cardMargin + cardPadding, currentY),
      );
      currentY += chunkPara.height + 60; // Spacing before footer

      // Footer
      // Line
      final footerLinePaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(canvasWidth / 2 - 80, 0),
          Offset(canvasWidth / 2 + 80, 0),
          [goldColor.withOpacity(0), goldColor, goldColor.withOpacity(0)],
          [0.0, 0.5, 1.0],
        )
        ..strokeWidth = 2;

      canvas.drawLine(
        Offset(canvasWidth / 2 - 80, currentY),
        Offset(canvasWidth / 2 + 80, currentY),
        footerLinePaint,
      );
      currentY += 20;

      canvas.drawParagraph(
        footerSubPara,
        Offset(cardMargin + cardPadding, currentY),
      );
      currentY += footerSubPara.height;

      canvas.drawParagraph(
        footerTitlePara,
        Offset(cardMargin + cardPadding, currentY),
      );

      // Save
      final picture = recorder.endRecording();
      final img = await picture.toImage(
        canvasWidth.toInt(),
        finalCanvasHeight.toInt(),
      );
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final path =
            '${tempDir.path}/share_${DateTime.now().millisecondsSinceEpoch}_$i.png';
        final file = File(path);
        await file.writeAsBytes(byteData.buffer.asUint8List());
        generatedFiles.add(XFile(path));
      }
    }

    return generatedFiles;
  }

  static int _findSplitOffset(
    TextPainter painter,
    double maxHeight,
    String text,
  ) {
    // Scan line metrics to find where height exceeds max
    final lines = painter.computeLineMetrics();
    double h = 0;
    int lineIndex = 0;
    for (int i = 0; i < lines.length; i++) {
      if (h + lines[i].height > maxHeight) break;
      h += lines[i].height;
      lineIndex = i;
    }

    // Get offset for the end of that line
    final line = lines[lineIndex];
    // We want the end of line 'lineIndex'.
    // getPositionForOffset with an offset at the bottom-left (since RTL text usually flows)
    // or just checking the range of text in that line if available.
    // TextPainter doesn't give line ranges directly easily in all versions.
    // Use getPositionForOffset at (width, line.baseline) ??

    // Attempt to approximate via offset
    // A heuristic: The text that fits corresponds roughly to area ratio? No, dangerous.

    // Better: use getPositionForOffset.
    // In RTL, the end of the line is visually at the left (x=0) if it fills width,
    // or we can probe multiple points.
    // Ideally, we just grab the text position at the END of the last visible line.

    // Try accessing the boundary of the line.
    // Since we don't have easy line range, let's use the offset of the character at the very end of this visual line.
    // We can probe (contentWidth, line.baseline) (LTR) or (0, line.baseline) (RTL)?

    // Let's assume RTL paragraphs alignment.
    // Position 0, baseline -> likely end of line for some RTL.
    // Let's rely on basic text length proportion if all else fails, but let's try getPositionForOffset.

    final pos = painter.getPositionForOffset(Offset(0, line.baseline));
    int split = pos.offset;

    // Safety corrections
    if (split > text.length) split = text.length;
    if (split <= 0) {
      // Fallback: estimate
      return (text.length * (maxHeight / painter.height)).floor();
    }

    // Adjust to nearest whitespace
    if (split < text.length) {
      final space = text.lastIndexOf(' ', split);
      if (space != -1 && space > split * 0.7) split = space;
    }

    return split;
  }

  static ui.Paragraph _buildTextParagraph(
    String text, {
    required double width,
    required double fontSize,
    Color color = Colors.black,
    String fontFamily = 'Amiri',
    FontWeight fontWeight = FontWeight.normal,
    TextAlign textAlign = TextAlign.start,
    double height = 1.0,
  }) {
    final builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: textAlign,
        textDirection: TextDirection.rtl,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: fontWeight,
        height: height,
      ),
    );
    builder.pushStyle(ui.TextStyle(color: color, fontSize: fontSize));
    builder.addText(text);
    return builder.build()..layout(ui.ParagraphConstraints(width: width));
  }
}
