import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'components/ayah_sheet_drag_handle.dart';

class AyahTranslationCarousel extends StatefulWidget {
  final int surahNumber;
  final int initialVerseNumber;

  const AyahTranslationCarousel({
    Key? key,
    required this.surahNumber,
    required this.initialVerseNumber,
  }) : super(key: key);

  @override
  State<AyahTranslationCarousel> createState() =>
      _AyahTranslationCarouselState();
}

class _AyahTranslationCarouselState extends State<AyahTranslationCarousel> {
  late PageController _pageController;
  late int _currentVerse;
  late int _totalVerses;

  @override
  void initState() {
    super.initState();
    _totalVerses = quran.getVerseCount(widget.surahNumber);
    // Ensure initial verse is valid for the controller
    int initialPage = (widget.initialVerseNumber - 1).clamp(
      0,
      _totalVerses - 1,
    );
    _currentVerse = initialPage + 1;
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AyahSheetDragHandle(),

          // Header showing Surah and Navigation Hint
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              children: [
                Text(
                  quran.getSurahName(widget.surahNumber),
                  style: GoogleFonts.amiri(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFD4AF37,
                    ).withOpacity(0.2), // Gold tint
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Verse $_currentVerse", // Arabic numerals (Western 0-9)
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey[300]),

          // Flexible PageView
          Flexible(
            child: SizedBox(
              height: 300.h, // Fixed height constraint for the scrollable area
              child: PageView.builder(
                controller: _pageController,
                itemCount: _totalVerses,
                physics:
                    const ClampingScrollPhysics(), // Disables 'bounce' past edges
                onPageChanged: (index) {
                  setState(() {
                    _currentVerse = index + 1;
                  });
                },
                itemBuilder: (context, index) {
                  final int verseNum = index + 1;
                  final String translation = quran.getVerseTranslation(
                    widget.surahNumber,
                    verseNum,
                  );

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translation,
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            height: 1.6,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
