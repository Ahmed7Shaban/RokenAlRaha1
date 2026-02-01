import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:roken_al_raha/core/widgets/shared_branding_widget.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/models/hadith_book.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/models/hadith_content.dart';

class ShareLogicService {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> shareHadith(BuildContext context, HadithContent hadith, HadithBook book) async {
    // Define dimensions for high-quality social media vertical image (1080x1350)
    const double imageWidth = 1080;
    const double imageHeight = 1350;
    const double padding = 80;
    
    // Header for "Hadith of the day" or Book Name
    const double headerHeight = 200; 
    // Footer for Branding
    const double footerHeight = 250; 
    
    const double contentHeight = imageHeight - headerHeight - footerHeight - (padding * 2);
    const double contentWidth = imageWidth - (padding * 2);

    final textStyle = GoogleFonts.amiri(
      fontSize: 50, 
      color: Colors.white,
      height: 2.0, // Good line spacing for readability
    );

    // Split text into pages
    final List<String> pages = _splitText(
      hadith.hadith,
      textStyle,
      contentWidth,
      contentHeight,
    );
    
    List<XFile> files = [];
    
    try {
      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now().millisecondsSinceEpoch;

      for (int i = 0; i < pages.length; i++) {
        final pageText = pages[i];
        
        // Capture widget as image
        final imageBytes = await _screenshotController.captureFromWidget(
          _buildHadithCardWidget(
            bookName: book.name,
            text: pageText,
            pageIndex: i + 1,
            totalPages: pages.length,
            textStyle: textStyle,
          ),
          pixelRatio: 2.0, // High resolution
          delay: const Duration(milliseconds: 20),
          targetSize: const Size(imageWidth, imageHeight),
          context: context,
        );

        final file = File('${tempDir.path}/hadith_${now}_$i.png');
        await file.writeAsBytes(imageBytes);
        files.add(XFile(file.path));
      }

      if (files.isNotEmpty) {
        await Share.shareXFiles(
          files,
          text: "حديث شريف من كتاب ${book.name} \n\nتم المشاركة عبر تطبيق ركن الراحة",
        );
      }
    } catch (e) {
      debugPrint("Error generating share images: $e");
      // Fallback or error handling could be added here
    }
  }

  List<String> _splitText(
    String text,
    TextStyle style,
    double maxWidth,
    double maxHeight,
  ) {
    List<String> pages = [];
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.rtl,
    );

    textPainter.layout(maxWidth: maxWidth);

    // If fits in one page
    if (textPainter.height <= maxHeight) {
      return [text];
    }

    // Binary search/Iterative approach to splitting
    // This is a simplified split logic based on character count estimation and refined by Painter
    // A robust solution would loop through lines.
    
    String remainingText = text;
    while (remainingText.isNotEmpty) {
      // Create a painter for remaining text
      final painter = TextPainter(
        text: TextSpan(text: remainingText, style: style),
        textDirection: TextDirection.rtl,
      );
      painter.layout(maxWidth: maxWidth);
      
      if (painter.height <= maxHeight) {
        pages.add(remainingText);
        break;
      }

      // Find the character index that fits
      // We look for the offset at maxHeight
      final position = painter.getPositionForOffset(Offset(0, maxHeight));
      int end = position.offset;

      // Ensure we don't split words if possible
      // Backtrack to nearest space
      if (end < remainingText.length) {
        int lastSpace = remainingText.lastIndexOf(' ', end);
        if (lastSpace != -1 && lastSpace > end * 0.5) {
           end = lastSpace;
        }
      }

      // Safety check to avoid infinite loop if one word is too big or logic fails
      if (end == 0) {
        // Force split if a single char/word is somehow huge, or just take a chunk
        end = min(100, remainingText.length);
      }

      pages.add(remainingText.substring(0, end).trim());
      remainingText = remainingText.substring(end).trim();
    }

    return pages;
  }

  Widget _buildHadithCardWidget({
    required String bookName,
    required String text,
    required int pageIndex,
    required int totalPages,
    required TextStyle textStyle,
  }) {
    // Create a container with branding colors and design
    return Container(
      width: 1080,
      height: 1350,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withOpacity(0.9),
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background Pattern (Optional opacity shapes)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),
          
          Column(
            children: [
              const SizedBox(height: 80),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        bookName,
                        style: GoogleFonts.amiri(
                          fontSize: 40,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 60),

              // Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: Center(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: textStyle,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
              ),
              
              // Page Indicator
              if (totalPages > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    "$pageIndex / $totalPages",
                    style: GoogleFonts.roboto(
                      color: Colors.white54,
                      fontSize: 30,
                    ),
                  ),
                ),

              // Footer Branding
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 50, top: 30),
                color: Colors.black.withOpacity(0.1),
                child: const SharedBrandingWidget(
                  color: Colors.amber,
                  fontSize: 35,
                  withShadow: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
