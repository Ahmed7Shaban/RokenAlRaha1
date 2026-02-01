import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_view_page.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran/logic/cubit/ayah_bookmark_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/Khatma/logic/khatma_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/Khatma/logic/khatma_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/Khatma/presentation/views/widgets/daily_ward_item.dart';
import 'package:roken_al_raha/features/Home/presention/views/Khatma/data/models/khatma_model.dart';
import 'package:roken_al_raha/features/Home/presention/views/Khatma/data/models/daily_ward_model.dart';
import 'package:roken_al_raha/features/Home/presention/views/Khatma/presentation/views/widgets/khatma_share_card.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class KhatmaDetailsPage extends StatefulWidget {
  const KhatmaDetailsPage({Key? key}) : super(key: key);

  @override
  State<KhatmaDetailsPage> createState() => _KhatmaDetailsPageState();
}

class _KhatmaDetailsPageState extends State<KhatmaDetailsPage> {
  dynamic _suraJsonData;

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/surahs.json',
      );
      final data = await json.decode(response);
      setState(() {
        _suraJsonData = data;
      });
    } catch (e) {
      debugPrint("Error loading surahs.json: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF1A1A2E), // Dark theme background
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          "تفاصيل الختمة",
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<KhatmaCubit, KhatmaState>(
        builder: (context, state) {
          if (state is KhatmaLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.goldenYellow),
            );
          } else if (state is KhatmaError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is KhatmaLoaded) {
            if (state.activeKhatma == null) {
              return const Center(
                child: Text(
                  "لا توجد تفاصيل",
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else {
              return _buildKhatmaDetails(context, state);
            }
          }
          return Container();
        },
      ),
      floatingActionButton: BlocBuilder<KhatmaCubit, KhatmaState>(
        builder: (context, state) {
          if (state is KhatmaLoaded && state.activeKhatma != null) {
            // Logic to check if Delayed
            final active = state.activeKhatma!;
            // For simplicity, just show Edit options
            return FloatingActionButton.extended(
              backgroundColor: AppColors.goldenYellow,
              label: const Text(
                "خيارات",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: const Icon(Icons.settings, color: Colors.black),
              onPressed: () {
                _showRedistributeDialog(context, active.id);
              },
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildKhatmaDetails(BuildContext context, KhatmaLoaded state) {
    final khatma = state.activeKhatma!;
    final wards = state.wards;

    // Calculate progress
    double progress = 0;
    if (khatma.endPage > 0) {
      progress = khatma.lastReadPage / 604.0;
    }
    if (progress > 1.0) progress = 1.0;

    // Determine status
    bool isDelayed = khatma.delayedPages > 0;

    return Column(
      children: [
        // Header Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          khatma.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDelayed
                                ? Colors.redAccent.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDelayed
                                  ? Colors.redAccent
                                  : Colors.green,
                            ),
                          ),
                          child: Text(
                            isDelayed
                                ? "متأخر: ${khatma.delayedPages} صفحة"
                                : "على المسار الصحيح ✅",
                            style: TextStyle(
                              color: isDelayed
                                  ? Colors.redAccent
                                  : Colors.lightGreenAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6,
                          backgroundColor: Colors.white24,
                          color: AppColors.goldenYellow,
                        ),
                      ),
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "آخر صفحة: ${khatma.lastReadPage}",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    "متبقي: ${khatma.durationDays} يوم",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: wards.length,
            itemBuilder: (context, index) {
              final ward = wards[index];
              return DailyWardItem(
                ward: ward,
                onTap: () {
                  if (_suraJsonData != null) {
                    _navigateToQuran(context, ward.startPage);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("جاري تحميل البيانات...")),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _navigateToQuran(BuildContext context, int page) {
    final readingCubit = context.read<ReadingSettingsCubit>();
    final khatmaCubit = context.read<KhatmaCubit>();
    final currentKhatmaId =
        (khatmaCubit.state as KhatmaLoaded).activeKhatma!.id;

    AyahBookmarkCubit? bookmarkCubit;
    try {
      bookmarkCubit = context.read<AyahBookmarkCubit>();
    } catch (e) {
      // Ignore
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: readingCubit),
            if (bookmarkCubit != null) BlocProvider.value(value: bookmarkCubit),
            // We pass KhatmaCubit too implicitly as we use closure below?
            // No, the closure works in 'this' context, but we need to ensure the cubit is alive.
            // It is active in the Dashboard view.
          ],
          child: ScreenUtilInit(
            designSize: const Size(392.7, 800.7),
            child: QuranViewPage(
              pageNumber: page,
              jsonData: _suraJsonData,
              shouldHighlightText: false,
              highlightVerse: "",
              onPageChanged: (newPage) {
                // AUTOMATIC UPDATE
                khatmaCubit.updateLastRead(currentKhatmaId, newPage);
              },
            ),
          ),
        ),
      ),
    ).then((_) {
      // Check milestones when returning
      _checkMilestones(context, currentKhatmaId);
    });
  }

  void _checkMilestones(BuildContext context, String khatmaId) {
    final state = context.read<KhatmaCubit>().state;
    if (state is KhatmaLoaded && state.activeKhatma != null) {
      final k = state.activeKhatma!;
      // Simple check: Did we finish today's ward?
      try {
        final todayWard = state.wards.firstWhere((w) => w.isCurrentDay);
        // Logic: if lastReadPage >= todayWard.endPage AND we haven't shown popup today (optional check)
        // For now just check condition
        if (k.lastReadPage >= todayWard.endPage) {
          // Show celebration
          _showCelebrationDialog(context, k, todayWard);
        }
      } catch (e) {
        // No ward for today or already past
      }
    }
  }

  void _showCelebrationDialog(
    BuildContext context,
    KhatmaModel khatma,
    DailyWard ward,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2E2E42),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: AppColors.goldenYellow),
            SizedBox(width: 8),
            Text("أحسنت!", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "لقد أتممت وردك اليومي، تقبل الله منك.",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.share, color: Colors.black),
              label: const Text("مشاركة الإنجاز"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldenYellow,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
                _showShareDialog(context, khatma, ward);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showShareDialog(
    BuildContext context,
    KhatmaModel khatma,
    DailyWard ward,
  ) {
    // Capture the cubit from the parent context
    final cubit = context.read<KhatmaCubit>();

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: _ShareDialogWrapper(khatma: khatma, ward: ward),
      ),
    );
  }

  void _showRedistributeDialog(BuildContext context, String khatmaId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2E2E42),
        title: Text(
          "إدارة الختمة",
          style: GoogleFonts.tajawal(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "هل ترغب في إعادة توزيع الصفحات المتبقية على الأيام المتبقية؟\nسيتم اعتبار اليوم هو بداية جديدة للفترة المتبقية.",
          style: GoogleFonts.tajawal(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء", style: GoogleFonts.tajawal()),
          ),
          TextButton(
            onPressed: () {
              context.read<KhatmaCubit>().redistributeKhatma(khatmaId);
              Navigator.pop(context);
            },
            child: Text(
              "إعادة توزيع",
              style: GoogleFonts.tajawal(
                color: AppColors.goldenYellow,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareDialogWrapper extends StatefulWidget {
  final KhatmaModel khatma;
  final DailyWard? ward;

  const _ShareDialogWrapper({Key? key, required this.khatma, this.ward})
    : super(key: key);

  @override
  State<_ShareDialogWrapper> createState() => _ShareDialogWrapperState();
}

class _ShareDialogWrapperState extends State<_ShareDialogWrapper> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isLoading = false;

  Future<void> _shareImage() async {
    setState(() => _isLoading = true);
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final file = await File('${directory.path}/khatma_share.png').create();
        await file.writeAsBytes(image);

        await Share.shareXFiles([
          XFile(file.path),
        ], text: "تابعي ختمتي في تطبيق ركن الراحة");
      }
    } catch (e) {
      debugPrint("Error sharing: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress
    double progressPercent = 0;
    if (widget.khatma.endPage > 0) {
      progressPercent = (widget.khatma.lastReadPage / 604.0) * 100;
    }

    final totalCompleted = context.select<KhatmaCubit, int>((cubit) {
      if (cubit.state is KhatmaLoaded)
        return (cubit.state as KhatmaLoaded).totalCompleted;
      return 0;
    });

    return AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Screenshot(
            controller: _screenshotController,
            child: KhatmaShareCard(
              khatmaName: widget.khatma.name,
              progressPercent: progressPercent.toInt(),
              totalCompleted: totalCompleted,
              currentWard: widget.ward != null
                  ? "صفحة ${widget.ward!.startPage}-${widget.ward!.endPage}"
                  : "عام",
              isCompleted: widget.khatma.isCompleted,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator(color: AppColors.goldenYellow)
              else
                ElevatedButton.icon(
                  onPressed: _shareImage,
                  icon: const Icon(Icons.share, color: Colors.black),
                  label: const Text("مشاركة"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldenYellow,
                    foregroundColor: Colors.black,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
