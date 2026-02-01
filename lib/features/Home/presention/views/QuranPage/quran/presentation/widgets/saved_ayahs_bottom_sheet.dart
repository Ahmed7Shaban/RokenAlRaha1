import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;

import '../../../../../../../../core/theme/app_colors.dart';
import '../../../quran_view_page.dart';
import '../../logic/cubit/ayah_bookmark_cubit.dart';
import '../../logic/cubit/ayah_bookmark_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran_settings/logic/cubit/reading_settings_cubit.dart';
import 'saved_ayah_item.dart';

class SavedAyahsBottomSheet extends StatelessWidget {
  final List<dynamic> jsonData;

  const SavedAyahsBottomSheet({Key? key, required this.jsonData})
    : super(key: key);

  static void show(BuildContext context, {required List<dynamic> jsonData}) {
    // Capture cubits safely
    AyahBookmarkCubit? bookmarkCubit;
    ReadingSettingsCubit? readingSettingsCubit;

    try {
      bookmarkCubit = context.read<AyahBookmarkCubit>();
    } catch (_) {}

    try {
      readingSettingsCubit = context.read<ReadingSettingsCubit>();
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final child = SavedAyahsBottomSheet(jsonData: jsonData);
        final providers = <BlocProvider>[];

        if (bookmarkCubit != null) {
          providers.add(
            BlocProvider<AyahBookmarkCubit>.value(value: bookmarkCubit),
          );
        }
        if (readingSettingsCubit != null) {
          providers.add(
            BlocProvider<ReadingSettingsCubit>.value(
              value: readingSettingsCubit,
            ),
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
  Widget build(BuildContext context) {
    return Container(
      height: 0.6.sh, // ~Half screen (60%)
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // 1. Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),

          // 2. Header
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "الآيات المحفوظة",
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                Icon(Icons.bookmarks_rounded, color: AppColors.primaryColor),
              ],
            ),
          ),
          const Divider(height: 1),

          // 3. List
          Expanded(
            child: BlocBuilder<AyahBookmarkCubit, AyahBookmarkState>(
              builder: (context, state) {
                if (state is AyahBookmarkLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AyahBookmarkLoaded) {
                  if (state.bookmarks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 48.sp,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "لا توجد آيات محفوظة بعد",
                            style: GoogleFonts.cairo(
                              color: Colors.grey.shade500,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Sort bookmarks by timestamp (newest first) or by location?
                  // Usually newest first is better for "Bookmarks".
                  final sortedBookmarks = List.of(state.bookmarks)
                    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: sortedBookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = sortedBookmarks[index];
                      return SavedAyahItem(
                        bookmark: bookmark,
                        onDelete: () {
                          // Call Cubit
                          context.read<AyahBookmarkCubit>().removeBookmark(
                            bookmark.surahNumber,
                            bookmark.verseNumber,
                          );
                        },
                        onTap: () {
                          // Capture the cubit instances before popping
                          final readingSettingsCubit = context
                              .read<ReadingSettingsCubit>();
                          final ayahBookmarkCubit = context
                              .read<AyahBookmarkCubit>();

                          // Navigation Logic
                          Navigator.pop(context); // Close sheet

                          final pageNumber = quran.getPageNumber(
                            bookmark.surahNumber,
                            bookmark.verseNumber,
                          );

                          // Important: Format highlightVerse exactly as quran_verse.dart expects
                          // Usually: " surahNumberverseNumber" or similar ID?
                          // Checking buildQuranVerseSpan: `final String verseId = " $surah$verseIndex";`
                          // Yes, space + surah + verse.
                          final String highlightId =
                              " ${bookmark.surahNumber}${bookmark.verseNumber}";

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(
                                    value: readingSettingsCubit,
                                  ),
                                  BlocProvider.value(value: ayahBookmarkCubit),
                                ],
                                child: ScreenUtilInit(
                                  designSize: const Size(392.7, 800.7),
                                  child: QuranViewPage(
                                    shouldHighlightText: true,
                                    highlightVerse: highlightId,
                                    jsonData: jsonData,
                                    pageNumber: pageNumber,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }

                if (state is AyahBookmarkError) {
                  return Center(child: Text(state.message));
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
