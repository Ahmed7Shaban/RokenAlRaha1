import 'dart:io';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:quran/quran.dart' as quran;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran/logic/cubit/ayah_bookmark_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_cubit.dart';

class AyahTranslationSheet extends StatefulWidget {
  final int surahNumber;
  final int verseNumber;

  /// 🔑 نص الآية الجاهز (مهم جدًا لتفادي الإكسبشن)
  final String? verseText;

  final VoidCallback? onClose;

  const AyahTranslationSheet({
    Key? key,
    required this.surahNumber,
    required this.verseNumber,
    this.verseText,
    this.onClose,
  }) : super(key: key);

  /// Helper to show the sheet
  static Future<void> show(
    BuildContext context, {
    required int surahNumber,
    required int verseNumber,
    String? verseText,
    VoidCallback? onClose,
  }) {
    // Capture Cubits from the parent context safely
    ReadingSettingsCubit? readingSettingsCubit;
    AyahBookmarkCubit? ayahBookmarkCubit;

    try {
      readingSettingsCubit = context.read<ReadingSettingsCubit>();
    } catch (_) {}

    try {
      ayahBookmarkCubit = context.read<AyahBookmarkCubit>();
    } catch (_) {}

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final child = AyahTranslationSheet(
          surahNumber: surahNumber,
          verseNumber: verseNumber,
          verseText: verseText,
          onClose: onClose,
        );

        final providers = <BlocProvider>[];

        if (readingSettingsCubit != null) {
          providers.add(
            BlocProvider<ReadingSettingsCubit>.value(
              value: readingSettingsCubit,
            ),
          );
        }

        if (ayahBookmarkCubit != null) {
          providers.add(
            BlocProvider<AyahBookmarkCubit>.value(value: ayahBookmarkCubit),
          );
        }

        if (providers.isNotEmpty) {
          return MultiBlocProvider(providers: providers, child: child);
        }

        return child;
      },
    );
  }

  @override
  State<AyahTranslationSheet> createState() => _AyahTranslationSheetState();
}

class _AyahTranslationSheetState extends State<AyahTranslationSheet> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  late quran.Translation _selectedTranslation;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _selectedTranslation = quran.Translation.enSaheeh;
  }

  // ===================== SAFE GETTERS =====================

  String _getArabicText() {
    if (widget.verseText != null && widget.verseText!.isNotEmpty) {
      return widget.verseText!;
    }

    try {
      return quran.getVerse(
        widget.surahNumber,
        widget.verseNumber,
        verseEndSymbol: true,
      );
    } catch (_) {
      return "﴿ آية غير متاحة ﴾";
    }
  }

  String _getTranslationText() {
    try {
      return quran.getVerseTranslation(
        widget.surahNumber,
        widget.verseNumber,
        translation: _selectedTranslation,
      );
    } catch (_) {
      return "Translation not available for this verse.";
    }
  }

  String _getSurahName() {
    try {
      return quran.getSurahName(widget.surahNumber);
    } catch (_) {
      return "";
    }
  }

  String _getTranslationName(quran.Translation translation) {
    final name = translation.toString().split('.').last;
    switch (name) {
      case 'enSaheeh':
        return 'English - Saheeh International';
      case 'trSaheeh':
        return 'Turkish - Saheeh';
      case 'mlAbdulHameed':
        return 'Malayalam - Abdul Hameed';
      case 'amh_muhammedsadiqan':
        return 'Amharic - Sadiqan';
      case 'ind_indonesianislam':
        return 'Indonesian - Islamic Affairs';
      case 'jpn_ryoichimita':
        return 'Japanese - Ryoichi Mita';
      case 'nld_fredleemhuis':
        return 'Dutch - Fred Leemhuis';
      case 'por_helminasr':
        return 'Portuguese - Helmi Nasr';
      case 'rus_ministryofawqaf':
        return 'Russian - Ministry of Awqaf';
      case 'tafseerMuyassar':
        return 'Tafseer - Al-Muyassar';
      case 'tafseerjalalayn':
        return 'Tafseer - Al-Jalalayn';
      case 'tafseerSiraj':
        return 'Tafseer - Al-Siraj';
      default:
        return name;
    }
  }

  // ===================== ACTIONS =====================

  Future<void> _handleCopy() async {
    final text =
        "﴿ ${_getArabicText()} ﴾\n\n${_getTranslationText()}\n\n— From Roken Al-Raha App";

    await Clipboard.setData(ClipboardData(text: text));

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("تم نسخ الآية")));
  }

  Future<void> _handleShare() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      await Future.delayed(const Duration(milliseconds: 50));

      final boundary =
          _repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) throw Exception("Boundary not found");

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/ayah_${widget.surahNumber}_${widget.verseNumber}.png',
      );

      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            "﴿ ${_getArabicText()} ﴾\n\n${_getTranslationText()}\n\n— From Roken Al-Raha App",
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Text(
                "${_getSurahName()} - آية ${widget.verseNumber}",
                style: GoogleFonts.amiri(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 16.h),

              RepaintBoundary(
                key: _repaintBoundaryKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      Text(
                        _getArabicText(),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 24.sp,
                          height: 1.8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _getTranslationText(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(fontSize: 16.sp, height: 1.5),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "From Roken Al-Raha App",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Dropdown
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<quran.Translation>(
                    value: _selectedTranslation,
                    isExpanded: true,
                    items: quran.Translation.values.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(_getTranslationName(t)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedTranslation = val);
                      }
                    },
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Actions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _handleCopy,
                        icon: const Icon(Icons.copy),
                        label: const Text("نسخ"),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSharing ? null : _handleShare,
                        icon: const Icon(Icons.share),
                        label: const Text("مشاركة"),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
