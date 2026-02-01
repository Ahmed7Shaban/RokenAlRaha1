import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:roken_al_raha/core/widgets/shared_branding_widget.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/repository/tafsir_download_repository.dart';
import '../cubit/tafsir_cubit.dart';
import '../cubit/tafsir_state.dart';
import '../utils/tafsir_image_generator.dart';
import 'tafsir_selector.dart';

class AyahTafsirSheet extends StatelessWidget {
  final int surahNumber;
  final int verseNumber;

  const AyahTafsirSheet({
    Key? key,
    required this.surahNumber,
    required this.verseNumber,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required int surahNumber,
    required int verseNumber,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          AyahTafsirSheet(surahNumber: surahNumber, verseNumber: verseNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Instantiate Repository and Cubit here.
    // Ideally Repository is a singleton, but for this scope we create it.
    final repository = TafsirDownloadRepository();

    return BlocProvider(
      create: (context) => TafsirCubit(repository)..init(),
      child: _AyahTafsirSheetView(
        initialSurah: surahNumber,
        initialVerse: verseNumber,
      ),
    );
  }
}

class _AyahTafsirSheetView extends StatefulWidget {
  final int initialSurah;
  final int initialVerse;

  const _AyahTafsirSheetView({
    required this.initialSurah,
    required this.initialVerse,
  });

  @override
  State<_AyahTafsirSheetView> createState() => _AyahTafsirSheetViewState();
}

class _AyahTafsirSheetViewState extends State<_AyahTafsirSheetView> {
  late int _currentSurah;
  late int _currentVerse;
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _currentSurah = widget.initialSurah;
    _currentVerse = widget.initialVerse;
  }

  void _nextVerse() {
    int nextVerse = _currentVerse + 1;
    int nextSurah = _currentSurah;
    if (nextVerse > quran.getVerseCount(_currentSurah)) {
      nextSurah++;
      if (nextSurah > 114) return;
      nextVerse = 1;
    }
    setState(() {
      _currentSurah = nextSurah;
      _currentVerse = nextVerse;
    });
  }

  void _prevVerse() {
    int prevVerse = _currentVerse - 1;
    int prevSurah = _currentSurah;
    if (prevVerse < 1) {
      prevSurah--;
      if (prevSurah < 1) return;
      prevVerse = quran.getVerseCount(prevSurah);
    }
    setState(() {
      _currentSurah = prevSurah;
      _currentVerse = prevVerse;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDFDFD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _DragHandle(),

            // Header with Selector
            BlocBuilder<TafsirCubit, TafsirState>(
              builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: TafsirSelector(
                    tafsirs: state.availableTafsirs,
                    selectedTafsir: state.selectedTafsir,
                    downloadProgress: state.downloadProgress,
                    downloadStatuses: state.downloadStatuses,
                    onSelect: (tafsir) {
                      context.read<TafsirCubit>().selectTafsir(tafsir);
                    },
                    onDownload: (tafsir) {
                      context.read<TafsirCubit>().downloadTafsir(tafsir);
                    },
                  ),
                );
              },
            ),

            // Content
            Flexible(
              fit: FlexFit.loose,
              child: BlocBuilder<TafsirCubit, TafsirState>(
                builder: (context, state) {
                  // Show Error if any
                  if (state.errorMessage != null &&
                      state.downloadStatuses.values.every(
                        (s) => s != DownloadStatus.downloading,
                      )) {
                    // Only show full error if not downloading (simple logic for now)
                  }

                  // Get Text
                  final content = context.read<TafsirCubit>().getTafsirForAyah(
                    _currentSurah,
                    _currentVerse,
                  );

                  final text =
                      content?.text ??
                      (state.selectedTafsir == null
                          ? "اختر تفسيراً لعرضه"
                          : "النص غير متوفر لهذه الآية");

                  return GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! < 0)
                        _nextVerse();
                      else if (details.primaryVelocity! > 0)
                        _prevVerse();
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: RepaintBoundary(
                        key: _repaintBoundaryKey,
                        child: Container(
                          color: const Color(0xFFFDFDFD),
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _VerseHeader(
                                surah: _currentSurah,
                                verse: _currentVerse,
                              ),
                              SizedBox(height: 12.h),
                              _VerseText(
                                surah: _currentSurah,
                                verse: _currentVerse,
                              ),
                              SizedBox(height: 20.h),
                              const Divider(),
                              SizedBox(height: 10.h),

                              _TafsirText(text: text),

                              SizedBox(height: 30.h),
                              if (_isSharing)
                                Center(
                                  child: SharedBrandingWidget(
                                    fontSize: 14.sp,
                                    withShadow: false,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Actions
            BlocBuilder<TafsirCubit, TafsirState>(
              builder: (context, state) {
                final content = context.read<TafsirCubit>().getTafsirForAyah(
                  _currentSurah,
                  _currentVerse,
                );
                final text = content?.text;

                return _TafsirActions(
                  textToCopy: text,
                  onShare: () async {
                    if (_isSharing) return;
                    setState(() => _isSharing = true);
                    try {
                      final verseText = quran.getVerse(
                        _currentSurah,
                        _currentVerse,
                      );
                      final surahName = quran.getSurahNameArabic(_currentSurah);

                      final files = await TafsirImageGenerator.generateCardImage(
                        surahNumber: _currentSurah,
                        surahName: surahName,
                        verseNumber: _currentVerse,
                        verseText: verseText,
                        contentText: text ?? "",
                        title:
                            "التفسير", // Or dynamic based on selected tafsir name
                        context: context,
                      );

                      if (files.isNotEmpty) {
                        await Share.shareXFiles(
                          files,
                          text: "تفسير الآية $_currentVerse من $surahName",
                        );
                      }
                    } catch (e) {
                      debugPrint("Share Error: $e");
                    } finally {
                      if (mounted) setState(() => _isSharing = false);
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.h),
        width: 48.w,
        height: 5.h,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _VerseHeader extends StatelessWidget {
  final int surah;
  final int verse;
  const _VerseHeader({required this.surah, required this.verse});
  @override
  Widget build(BuildContext context) {
    return Text(
      "${quran.getSurahNameArabic(surah)} - الآية $verse",
      style: GoogleFonts.amiri(
        fontSize: 16.sp,
        color: const Color(0xFF8A8A8A),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _VerseText extends StatelessWidget {
  final int surah;
  final int verse;
  const _VerseText({required this.surah, required this.verse});
  @override
  Widget build(BuildContext context) {
    return Text(
      quran.getVerse(surah, verse, verseEndSymbol: true),
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        height: 1.8,
        color: Colors.black87,
      ),
    );
  }
}

class _TafsirText extends StatelessWidget {
  final String text;
  const _TafsirText({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl,
      style: GoogleFonts.amiri(
        fontSize: 18.sp,
        height: 1.8,
        color: Colors.black87,
      ),
    );
  }
}

class _TafsirActions extends StatelessWidget {
  final String? textToCopy;
  final VoidCallback onShare;
  const _TafsirActions({required this.textToCopy, required this.onShare});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: textToCopy != null
                  ? () async {
                      await Clipboard.setData(ClipboardData(text: textToCopy!));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Copied!")),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2F2F2),
                foregroundColor: Colors.black87,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.copy_rounded, size: 20),
              label: Text(
                "نسخ",
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onShare,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.share_rounded, size: 20),
              label: Text(
                "مشاركة",
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
