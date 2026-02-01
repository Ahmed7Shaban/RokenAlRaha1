import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/last_read/logic/cubit/last_read_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/last_read/logic/cubit/last_read_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/last_read/data/models/last_read_model.dart';
import '../../quran_view_page.dart';

class QuranPageSelector extends StatelessWidget {
  const QuranPageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔌 Connect to LastReadCubit to get the current last read page
    return BlocBuilder<LastReadCubit, LastReadState>(
      builder: (context, state) {
        LastReadModel? lastRead;
        if (state is LastReadLoaded) {
          lastRead = state.lastRead;
        }

        return _QuranPageSelectorBody(lastRead: lastRead);
      },
    );
  }
}

class _QuranPageSelectorBody extends StatefulWidget {
  final LastReadModel? lastRead;

  const _QuranPageSelectorBody({this.lastRead});

  @override
  State<_QuranPageSelectorBody> createState() => _QuranPageSelectorBodyState();
}

class _QuranPageSelectorBodyState extends State<_QuranPageSelectorBody> {
  final ScrollController _scrollController = ScrollController();

  /// 📏 Constants for button size and spacing
  final double _itemSize = 50.0;
  final double _spacing = 12.0;

  @override
  void initState() {
    super.initState();
    // ⚡ Scroll to last read page after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToLastRead());
  }

  @override
  void didUpdateWidget(covariant _QuranPageSelectorBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastRead?.pageNumber != oldWidget.lastRead?.pageNumber) {
      _scrollToLastRead();
    }
  }

  void _scrollToLastRead() {
    if (widget.lastRead != null && _scrollController.hasClients) {
      final pageIndex = widget.lastRead!.pageNumber - 1;
      final offset =
          (pageIndex * (_itemSize + _spacing)) - (1.sw / 2) + (_itemSize / 2);

      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _itemSize + 24.h, // Height constraint for horizontal list
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 604,
        separatorBuilder: (context, index) => SizedBox(width: _spacing.w),
        itemBuilder: (context, index) {
          final int pageNum = index + 1;
          final bool isLastRead = widget.lastRead?.pageNumber == pageNum;

          return Center(child: _buildPageButton(context, pageNum, isLastRead));
        },
      ),
    );
  }

  Widget _buildPageButton(BuildContext context, int pageNum, bool isLastRead) {
    return InkWell(
      onTap: () => _onPageSelected(context, pageNum),
      borderRadius: BorderRadius.circular(_itemSize),
      child: Tooltip(
        message: "صفحة $pageNum", // Placeholder for future enhancements
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isLastRead ? _itemSize * 1.1 : _itemSize,
          height: isLastRead ? _itemSize * 1.1 : _itemSize,
          decoration: BoxDecoration(
            color: isLastRead ? AppColors.primaryColor : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isLastRead ? AppColors.primaryColor : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: [
              if (isLastRead)
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            "$pageNum",
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: isLastRead ? FontWeight.bold : FontWeight.w500,
              color: isLastRead ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  void _onPageSelected(BuildContext context, int pageNum) {
    bool shouldHighlight = false;
    String highlightVerse = "";

    // 🌟 Check if we need to highlight specific verse
    if (widget.lastRead != null && widget.lastRead!.pageNumber == pageNum) {
      shouldHighlight = true;
      // Format: " {Surah}{Ayah}"
      highlightVerse =
          " ${widget.lastRead!.surahNumber}${widget.lastRead!.ayahNumber}";
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
            highlightVerse: highlightVerse,
          ),
        ),
      ),
    );
  }
}
