import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screenshot/screenshot.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/sharing/quran_share_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/data/models/reading_theme_model.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran/logic/cubit/ayah_bookmark_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran/logic/cubit/ayah_bookmark_state.dart';

// ... imports ...

class QuranImageGenerator {
  final ScreenshotController _screenshotController = ScreenshotController();

  /// Generates an image for a specific chunk of data.
  /// Retries with lower pixel ratios if the default fails (e.g. OOM or texture limit).
  Future<Uint8List?> generateImageBytes(
    BuildContext context, {
    required int pageIndex,
    required dynamic fullJsonData,
    required List<dynamic> chunkData,
    required bool isFirstChunk,
    required bool isLastChunk,
    ReadingSettingsCubit? readingCubit,
    AyahBookmarkCubit? bookmarkCubit,
  }) async {
    // Determine pixel ratios to try.
    // If it's a split part, we can probably safely use 2.0 or 1.5.
    // If it's a huge single page, we might start lower.
    final ratiosToTry = [2.0, 1.5, 1.0];

    for (final ratio in ratiosToTry) {
      try {
        final image = await _captureConfiguredWidget(
          context,
          ratio: ratio,
          pageIndex: pageIndex,
          fullJsonData: fullJsonData,
          chunkData: chunkData,
          isFirstChunk: isFirstChunk,
          isLastChunk: isLastChunk,
          readingCubit: readingCubit,
          bookmarkCubit: bookmarkCubit,
        );
        return image;
      } catch (e) {
        debugPrint("Failed to capture image at ratio $ratio: $e");
        // Continue to next ratio
      }
    }
    return null;
  }

  Future<Uint8List> _captureConfiguredWidget(
    BuildContext context, {
    required double ratio,
    required int pageIndex,
    required dynamic fullJsonData,
    required List<dynamic> chunkData,
    required bool isFirstChunk,
    required bool isLastChunk,
    ReadingSettingsCubit? readingCubit,
    AyahBookmarkCubit? bookmarkCubit,
  }) {
    const double logicalWidth = 392.0;

    // Use static fixed Cubits for shared image
    final fixedReadingCubit = StaticReadingSettingsCubit();
    final fixedBookmarkCubit = StaticAyahBookmarkCubit();

    final widgetToCapture = RepaintBoundary(
      child: Theme(
        data: Theme.of(context).copyWith(
          scaffoldBackgroundColor: Colors.white,
          textTheme: Theme.of(context).textTheme.apply(
            bodyColor: Colors.black,
            displayColor: Colors.black,
          ),
        ),
        child: MediaQuery(
          data: MediaQueryData(
            size: const Size(
              logicalWidth,
              100000,
            ), // Infinite height constraint
            devicePixelRatio: ratio,
            textScaler: TextScaler.noScaling,
          ),
          child: Builder(
            builder: (ctx) {
              // Re-init ScreenUtil for this isolated context
              ScreenUtil.init(
                ctx,
                designSize: const Size(392.7, 800.7),
                minTextAdapt: true,
              );

              final content = SharePageLayout(
                pageIndex: pageIndex,
                fullJsonData: fullJsonData,
                chunkData: chunkData,
                isFirstChunk: isFirstChunk,
                isLastChunk: isLastChunk,
              );

              return MultiBlocProvider(
                providers: [
                  BlocProvider<ReadingSettingsCubit>.value(
                    value: fixedReadingCubit,
                  ),
                  BlocProvider<AyahBookmarkCubit>.value(
                    value: fixedBookmarkCubit,
                  ),
                ],
                child: content,
              );
            },
          ),
        ),
      ),
    );

    return _screenshotController
        .captureFromWidget(
          widgetToCapture,
          context: context,
          delay: const Duration(milliseconds: 100), // Small delay for rendering
          pixelRatio: ratio,
          targetSize: null, // Let it calculate based on content
        )
        .whenComplete(() {
          fixedReadingCubit.close();
          fixedBookmarkCubit.close();
        });
  }
}

// --- Static Cubits for Shared Image ---

class StaticReadingSettingsCubit extends Cubit<ReadingSettingsState>
    implements ReadingSettingsCubit {
  StaticReadingSettingsCubit()
    : super(
        const ReadingSettingsLoaded(
          theme: ReadingTheme(
            id: -999,
            name: "Share",
            backgroundColor: Colors.white,
            textColor: Colors.black,
          ),
          scrollMode: ReadingScrollMode.vertical,
        ),
      );

  // Implement abstract members if necessary, or just override used methods to do nothing
  @override
  Future<void> loadSettings() async {}
  @override
  Future<void> updateTheme(ReadingTheme newTheme) async {}
  @override
  Future<void> updateScrollMode(ReadingScrollMode newMode) async {}
}

class StaticAyahBookmarkCubit extends Cubit<AyahBookmarkState>
    implements AyahBookmarkCubit {
  StaticAyahBookmarkCubit() : super(const AyahBookmarkLoaded([], {}));

  @override
  Future<void> loadBookmarks() async {}
  @override
  Future<void> removeBookmark(int surah, int verse) async {}
  @override
  Future<void> toggleBookmark(int surah, int verse, int colorValue) async {}
}
