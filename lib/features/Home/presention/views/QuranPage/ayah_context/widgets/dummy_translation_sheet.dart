import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/ayah_sheet_drag_handle.dart';

class DummyTranslationSheet extends StatefulWidget {
  const DummyTranslationSheet({Key? key}) : super(key: key);

  @override
  State<DummyTranslationSheet> createState() => _DummyTranslationSheetState();
}

class _DummyTranslationSheetState extends State<DummyTranslationSheet> {
  // Hardcoded constraints
  static const int _totalVerses = 7;

  // State variables
  int _currentVerse = 1; // 1-based index for display
  String _selectedTranslation = "English - Saheeh International";
  bool _isDropdownOpen = false;
  late PageController _pageController;

  // Mock Data
  final Map<String, String> _translationOptions = {
    "English - Saheeh International":
        "All praise is due to Allah, Lord of the worlds.",
    "English - Clear Quran": "All praise is for Allah—Lord of all worlds.",
    "French - Hamidullah": "Louange à Allah, Seigneur de l'univers.",
    "Urdu - Maududi": "تعریف اللہ ہی کے لیے ہے جو تمام کائنات کا رب ہے",
  };

  // Mock Arabic Text (Static for testing)
  final String _arabicText = "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ";

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentVerse = index + 1;
    });
  }

  void _onTranslationSelected(String key) {
    setState(() {
      _selectedTranslation = key;
      _isDropdownOpen = false;
    });
  }

  // Visual helper for Arabic numerals (Fake/Simple mapping)
  String _getArabicVerseNum(int num) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return num.toString().split('').map((e) => digits[int.parse(e)]).join('');
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
          // 1. Drag Handle
          const AyahSheetDragHandle(),

          // 2. Header (Surah Name + Dropdown)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Mock Surah Name
                Text(
                  "Al-Fatiha",
                  style: GoogleFonts.amiri(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                // Custom Dropdown Button
                InkWell(
                  onTap: () =>
                      setState(() => _isDropdownOpen = !_isDropdownOpen),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.language,
                          size: 18.sp,
                          color: const Color(0xFFD4AF37),
                        ),
                        SizedBox(width: 8.w),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 140.w),
                          child: Text(
                            _selectedTranslation
                                .split(' - ')
                                .first, // Show short name
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          _isDropdownOpen
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
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

          // 3. Dropdown Selection List (Overlay/Animated View)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: _isDropdownOpen
                ? Container(
                    constraints: BoxConstraints(maxHeight: 180.h),
                    margin: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: _translationOptions.keys.map((key) {
                        final isSelected = key == _selectedTranslation;
                        return ListTile(
                          dense: true,
                          title: Text(
                            key,
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFFD4AF37)
                                  : Colors.black87,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: const Color(0xFFD4AF37),
                                  size: 18.sp,
                                )
                              : null,
                          onTap: () => _onTranslationSelected(key),
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
              physics:
                  const ClampingScrollPhysics(), // Disables out-of-bounds bouncing
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                // Determine Visual State based on fake data
                final bool isFirst = index == 0;
                final bool isLast = index == _totalVerses - 1;

                // Construct display text variations for "testing" visual changes
                final String translationContent =
                    "${_translationOptions[_selectedTranslation]} (Verse ${index + 1})";

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
                  child: Column(
                    children: [
                      // Verse Pill
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getArabicVerseNum(index + 1),
                          style: TextStyle(
                            fontFamily:
                                'Amiri', // Assuming Font exists, fallback ok
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Arabic Text
                      Text(
                        _arabicText,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 28.sp,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),

                      SizedBox(height: 24.h),
                      Divider(
                        indent: 40.w,
                        endIndent: 40.w,
                        color: Colors.grey.shade200,
                      ),
                      SizedBox(height: 24.h),

                      // Translation Text
                      Text(
                        translationContent,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          height: 1.5,
                          color: Colors.grey.shade800,
                        ),
                      ),

                      // Hint text for navigation limits
                      if (isFirst || isLast)
                        Padding(
                          padding: EdgeInsets.only(top: 20.h),
                          child: Text(
                            isFirst
                                ? "Swipe Left Disabled (Start)"
                                : "Swipe Right Disabled (End)",
                            style: GoogleFonts.cairo(
                              fontSize: 10.sp,
                              color: Colors.red.shade300,
                            ),
                          ),
                        ),
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
