import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/last_read/logic/cubit/last_read_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/last_read/logic/cubit/last_read_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/last_read/data/models/last_read_model.dart';
import '../../quran_view_page.dart';

class PagesGridView extends StatelessWidget {
  const PagesGridView({super.key});

  @override
  Widget build(BuildContext context) {
    // We want a list of 1 to 604. 604 items.
    // GridView.builder is appropriate.
    // 3 columns? Or 4?
    // Numbers are small.
    // Grid view.

    // Scroll to Last Read?
    // We can use ScrollController but with ListView/GridView builder, accurate scroll to index requires knowledge of item height?
    // Grid items are equal height.
    // We can use ScrollController.animateTo(itemHeight * (index~/crossAxisCount)) after build.

    // We use a Builder or PostFrameCallback to scroll to initial position if possible.
    // Or better: Use scroll_to_index package if available?
    // I will stick to basic scrolling if "Last Read" is available.

    return BlocListener<LastReadCubit, LastReadState>(
      listener: (context, state) {
        if (state is LastReadLoaded && state.lastRead != null) {
          // Scroll to page logic if needed dynamically
        }
      },
      child: BlocBuilder<LastReadCubit, LastReadState>(
        builder: (context, state) {
          LastReadModel? lastRead;
          if (state is LastReadLoaded) {
            lastRead = state.lastRead;
          }

          // Calculate initial scroll offset?
          // Only if this widget is just built.
          // However, `BlocBuilder` might rebuild.
          // Ideally, we do this in `initState`.
          // I'll convert to StatefulWidget for Scroll Logic.
          return _PagesGridBody(lastRead: lastRead);
        },
      ),
    );
  }
}

class _PagesGridBody extends StatefulWidget {
  final LastReadModel? lastRead;
  const _PagesGridBody({this.lastRead});

  @override
  State<_PagesGridBody> createState() => _PagesGridBodyState();
}

class _PagesGridBodyState extends State<_PagesGridBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.lastRead != null && widget.lastRead!.pageNumber > 20) {
        // Simple approximation: Height of row approx 60.
        // ScreenUtil height might differ.
        // Let's assume a safe scroll or use ensureVisible if keys were used.
        // Manual calculation:
        // Index = page - 1.
        // Row = Index ~/ 4.
        // Offset = Row * (ItemHeight + Spacing).
        // Let's assume ItemAspectRatio 1.5, Width = ScreenWidth/4. Height = Width/1.5.

        double screenWidth = 1.sw; // roughly
        // Padding 16 on sides?
        double availableWidth = screenWidth - 32;
        double itemWidth = availableWidth / 4;
        double itemHeight = itemWidth / 1.3;
        double spacing = 12;

        int row = (widget.lastRead!.pageNumber - 1) ~/ 4;
        double offset = row * (itemHeight + spacing);

        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
            offset.clamp(0.0, _scrollController.position.maxScrollExtent),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 604,
        itemBuilder: (context, index) {
          final int pageNum = index + 1;
          final bool isSelected = (widget.lastRead?.pageNumber == pageNum);

          return InkWell(
            onTap: () {
              // Determine if this page is the last read page
              bool isLastReadPage = (widget.lastRead?.pageNumber == pageNum);
              String highlight = "";
              bool shouldHighlight = false;

              if (isLastReadPage && widget.lastRead != null) {
                // Construct ID: " {surah}{ayah}"
                // Wait, `highlightVerse` format in other files (JuzCard) was: ` " ${surah}${ayah}"`.
                // Let's match it.
                highlight =
                    " ${widget.lastRead!.surahNumber}${widget.lastRead!.ayahNumber}";
                shouldHighlight = true;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScreenUtilInit(
                    designSize: const Size(392.7, 800.7),
                    child: QuranViewPage(
                      pageNumber: pageNum,
                      jsonData: const [],
                      shouldHighlightText: shouldHighlight,
                      highlightVerse: highlight,
                    ),
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(50),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        // Subtle shadow for non-selected
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              alignment: Alignment.center,
              child: Text(
                "$pageNum",
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
