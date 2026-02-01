import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:roken_al_raha/core/widgets/shared_branding_widget.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import '../../tafsir/presentation/utils/tafsir_image_generator.dart';
import '../../tafsir/presentation/cubit/tafsir_cubit.dart';
import '../../tafsir/presentation/cubit/tafsir_state.dart';
import '../../tafsir/data/repository/tafsir_download_repository.dart';
import '../../tafsir/data/models/translation_data.dart';

class AyahE3rabSheet extends StatelessWidget {
  final int surahNumber;
  final int verseNumber;

  const AyahE3rabSheet({
    Key? key,
    required this.surahNumber,
    required this.verseNumber,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required int surahNumber,
    required int verseNumber,
  }) {
    // Provide a fresh Cubit instance for this sheet
    // We access the existing repository from the main context
    // Create a new instance to ensure availability regardless of parent context
    final repository = TafsirDownloadRepository();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider(
        create: (context) => TafsirCubit(repository)..init(),
        child: AyahE3rabSheet(
          surahNumber: surahNumber,
          verseNumber: verseNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _AyahE3rabSheetView(
      initialSurah: surahNumber,
      initialVerse: verseNumber,
    );
  }
}

class _AyahE3rabSheetView extends StatefulWidget {
  final int initialSurah;
  final int initialVerse;

  const _AyahE3rabSheetView({
    required this.initialSurah,
    required this.initialVerse,
  });

  @override
  State<_AyahE3rabSheetView> createState() => _AyahE3rabSheetViewState();
}

class _AyahE3rabSheetViewState extends State<_AyahE3rabSheetView> {
  late int _currentSurah;
  late int _currentVerse;

  bool _isSharing = false;

  final String _e3rabName = "إعراب كلمات القرآن الكريم";
  final String _e3rabUrl =
      "https://raw.githubusercontent.com/noureddin/Quran-App-Data/main/Tafaseer/e3rab.json";

  @override
  void initState() {
    super.initState();
    _currentSurah = widget.initialSurah;
    _currentVerse = widget.initialVerse;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadE3rab();
    });
  }

  void _checkAndLoadE3rab() {
    final cubit = context.read<TafsirCubit>();

    final data = TranslationData(
      name: _e3rabName,
      url: _e3rabUrl,
      isDownloaded: true,
    );

    // Try to load directly. Cubit handles failure if file doesn't exist.
    cubit.selectTafsir(data);
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
        // SafeArea for bottom swipes
        child: BlocBuilder<TafsirCubit, TafsirState>(
          builder: (context, state) {
            // 1. Check if E3rab is active/loaded
            final bool isE3rabLoaded =
                state.selectedTafsir?.name == _e3rabName &&
                state.currentTafsirMap.isNotEmpty;

            // 2. Check if Downloading
            final bool isDownloading =
                state.downloadStatuses[_e3rabName] ==
                DownloadStatus.downloading;

            // 3. UI Decisions
            if (isDownloading) {
              final progress = state.downloadProgress[_e3rabName] ?? 0.0;
              return _buildLoading(progress);
            }

            if (!isE3rabLoaded) {
              return _buildDownloadPrompt();
            }

            // 4. Content Display (Loaded)
            final content = context.read<TafsirCubit>().getTafsirForAyah(
              _currentSurah,
              _currentVerse,
            );

            final textContent =
                content?.text ?? "لا يوجد إعراب متاح لهذه الآية.";

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const _DragHandle(),

                // Header
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Center(
                    child: Text(
                      "إعراب الآية",
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                const Divider(height: 1),

                // Content Area
                Flexible(
                  fit: FlexFit.loose,
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! < 0) {
                        _nextVerse();
                      } else if (details.primaryVelocity! > 0) {
                        _prevVerse();
                      }
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        color: const Color(
                          0xFFFDFDFD,
                        ), // Ensure background for touch
                        padding: EdgeInsets.all(24.w),
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
                            SizedBox(height: 24.h),

                            // E3rab Text
                            Text(
                              textContent,
                              textAlign: TextAlign.justify,
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.amiri(
                                fontSize: 18.sp,
                                height: 2.0,
                                color: Colors.black87,
                              ),
                            ),

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
                ),

                // Actions
                _E3rabActions(
                  textToCopy: textContent,
                  onShare: () async {
                    if (_isSharing) return;
                    setState(() => _isSharing = true);
                    try {
                      final verseText = quran.getVerse(
                        _currentSurah,
                        _currentVerse,
                      );
                      final surahName = quran.getSurahNameArabic(_currentSurah);

                      final files =
                          await TafsirImageGenerator.generateCardImage(
                            surahNumber: _currentSurah,
                            surahName: surahName,
                            verseNumber: _currentVerse,
                            verseText: verseText,
                            contentText: textContent,
                            title: "إعراب الآية",
                            context: context,
                          );

                      if (files.isNotEmpty) {
                        await Share.shareXFiles(
                          files,
                          text: "إعراب الآية $_currentVerse من $surahName",
                        );
                      }
                    } catch (e) {
                      debugPrint("Share error: $e");
                    } finally {
                      if (mounted) setState(() => _isSharing = false);
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDownloadPrompt() {
    return Container(
      // Ensure minimum height for bottom sheet feel
      height: 0.4.sh,
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _DragHandle(),
          const Spacer(),
          const Icon(Icons.menu_book_rounded, size: 48, color: Colors.brown),
          SizedBox(height: 16.h),
          Text(
            "إعراب كلمات القرآن الكريم",
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "يلزم تحميل ملف الإعراب أولاً للعرض",
            style: GoogleFonts.cairo(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              final cubit = context.read<TafsirCubit>();
              final e3rabData = TranslationData(
                name: _e3rabName,
                url: _e3rabUrl,
                isDownloaded: false,
              );
              cubit.downloadTafsir(e3rabData).then((_) {
                if (cubit.state.downloadStatuses[_e3rabName] ==
                    DownloadStatus.downloaded) {
                  cubit.selectTafsir(e3rabData..isDownloaded = true);
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.download_rounded),
            label: Text(
              "تحميل الإعراب",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLoading(double progress) {
    return Container(
      height: 0.3.sh,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _DragHandle(),
          const Spacer(),
          CircularProgressIndicator(
            value: progress,
            color: AppColors.primaryColor,
          ),
          SizedBox(height: 16.h),
          Text(
            "جار التحميل... ${(progress * 100).toInt()}%",
            style: GoogleFonts.cairo(fontSize: 16.sp),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// --- Helpers ---

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
        fontSize:
            22.sp, // Slightly smaller than Tafsir main text to fit context
        fontWeight: FontWeight.bold,
        height: 1.8,
        color: Colors.black87,
      ),
    );
  }
}

class _E3rabActions extends StatelessWidget {
  final String textToCopy;
  final VoidCallback onShare;
  const _E3rabActions({required this.textToCopy, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: textToCopy));
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("تم النسخ")));
                }
              },
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
                // Use consistent color
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.share_rounded, size: 20),
              label: Text(
                "مشاركة كصورة",
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
