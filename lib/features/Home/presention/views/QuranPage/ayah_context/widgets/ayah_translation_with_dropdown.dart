import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran/quran.dart'; // Explicit import for Translation enum availability if needed separately
import '../widgets/components/ayah_sheet_drag_handle.dart';

class AyahTranslationWithCarousel extends StatefulWidget {
  final int surahNumber;
  final int initialVerseNumber;
  final VoidCallback? onClose;

  const AyahTranslationWithCarousel({
    Key? key,
    required this.surahNumber,
    required this.initialVerseNumber,
    this.onClose,
  }) : super(key: key);

  @override
  State<AyahTranslationWithCarousel> createState() =>
      _AyahTranslationWithCarouselState();
}

class _AyahTranslationWithCarouselState
    extends State<AyahTranslationWithCarousel> {
  late PageController _pageController;
  late int _currentVerseIndex; // 0-based index for PageView
  late int _totalVerses;

  // Default translation
  Translation _selectedTranslation = Translation.enSaheeh;
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _totalVerses = quran.getVerseCount(widget.surahNumber);
    // Ensure verse number is within valid range [1, total]
    // PageView uses 0-based index, so subtract 1
    int initialIndex = (widget.initialVerseNumber - 1).clamp(
      0,
      _totalVerses - 1,
    );
    _currentVerseIndex = initialIndex;
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _toArabicNumerals(int number) {
    const arabicDigits = ['٠', '۱', '۲', '۳', '٤', '٥', '٦', '۷', '۸', '۹'];
    return number
        .toString()
        .split('')
        .map((char) {
          int digit = int.tryParse(char) ?? 0;
          return arabicDigits[digit];
        })
        .join('');
  }

  String _getTranslationName(Translation t) {
    switch (t) {
      case Translation.enSaheeh:
        return "English (Saheeh)";
      case Translation.trSaheeh:
        return "Turkish (Saheeh)";
      case Translation.mlAbdulHameed:
        return "Malayalam (Abdul Hameed)";
      case Translation.amh_muhammedsadiqan:
        return "Amharic";
      case Translation.ind_indonesianislam:
        return "Indonesian";
      case Translation.jpn_ryoichimita:
        return "Japanese";
      case Translation.nld_fredleemhuis:
        return "Dutch";
      case Translation.por_helminasr:
        return "Portuguese";
      case Translation.rus_ministryofawqaf:
        return "Russian";
      case Translation.tafseerMuyassar:
        return "Tafseer Muyassar (Arabic)";
      case Translation.tafseerjalalayn:
        return "Tafseer Jalalayn (Arabic)";
      case Translation.tafseerSiraj:
        return "Tafseer Al-Siraj";
      default:
        return t.name;
    }
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  void _selectTranslation(Translation t) {
    setState(() {
      _selectedTranslation = t;
      _isDropdownOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen bounds for sizing constraints if needed, relying on ScreenUtil mostly
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Drag Handle
          const AyahSheetDragHandle(),

          // 2. Header & Controls
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Surah Name
                Text(
                  quran.getSurahName(widget.surahNumber),
                  style: GoogleFonts.amiri(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                // Translation Dropdown Button
                InkWell(
                  onTap: _toggleDropdown,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.translate_rounded,
                          size: 18.sp,
                          color: const Color(0xFFD4AF37),
                        ),
                        SizedBox(width: 8.w),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 120.w),
                          child: Text(
                            _getTranslationName(_selectedTranslation),
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          _isDropdownOpen
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 20.sp,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          // 3. Dropdown Selection Area (Animated)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isDropdownOpen
                ? Container(
                    constraints: BoxConstraints(maxHeight: 200.h),
                    margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      children: Translation.values.map((t) {
                        final isSelected = t == _selectedTranslation;
                        return InkWell(
                          onTap: () => _selectTranslation(t),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 10.h,
                            ),
                            color: isSelected
                                ? const Color(0xFFD4AF37).withOpacity(0.1)
                                : Colors.transparent,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _getTranslationName(t),
                                    style: GoogleFonts.cairo(
                                      fontSize: 13.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? const Color(0xFFD4AF37)
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_rounded,
                                    color: const Color(0xFFD4AF37),
                                    size: 18.sp,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // 4. Content Carousel
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _totalVerses,
              physics: const ClampingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentVerseIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final int verseNum = index + 1;

                // Fetch Data
                // Note: Using try-catch to handle potential missing translation data gracefully
                String arabicText;
                String translationText;

                try {
                  arabicText = quran.getVerse(
                    widget.surahNumber,
                    verseNum,
                    verseEndSymbol: true,
                  );
                } catch (e) {
                  arabicText = "Ayah not found";
                }

                try {
                  translationText = quran.getVerseTranslation(
                    widget.surahNumber,
                    verseNum,
                    translation: _selectedTranslation,
                  );
                } catch (e) {
                  translationText = "Translation not available for this verse.";
                }

                bool isLastVerse = index == _totalVerses - 1;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 40.h),
                  child: Column(
                    children: [
                      // Verse Number Badge
                      Container(
                        margin: EdgeInsets.only(bottom: 24.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${_toArabicNumerals(verseNum)}",
                          style: GoogleFonts.amiri(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                      ),

                      // Arabic Text
                      Text(
                        arabicText,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          // Using standard TextStyle for font family support if needed
                          fontFamily:
                              'Amiri', // Fallback or use standard Arabic font
                          fontSize: 26.sp,
                          height: 1.8,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 24.h),
                      Divider(
                        color: Colors.grey.shade200,
                        indent: 40.w,
                        endIndent: 40.w,
                      ),
                      SizedBox(height: 24.h),

                      // Translation Text
                      Text(
                        translationText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),

                      // Spacing for bottom interaction
                      SizedBox(height: 40.h),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
