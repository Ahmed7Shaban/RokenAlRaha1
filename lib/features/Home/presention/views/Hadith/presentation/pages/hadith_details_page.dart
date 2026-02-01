import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/hadith_logic/hadith_details_cubit.dart';

import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/models/hadith_book.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/repositories/hadith_repository.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/presentation/widgets/hadith_item.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/presentation/widgets/hadith_search_text_field.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class HadithDetailsPage extends StatelessWidget {
  final HadithBook book;
  final int? initialScrollIndex;

  const HadithDetailsPage({
    Key? key,
    required this.book,
    this.initialScrollIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HadithDetailsCubit(HadithRepository(), book)..loadHadiths(),
      child: _HadithDetailsView(
        book: book,
        initialScrollIndex: initialScrollIndex,
      ),
    );
  }
}

class _HadithDetailsView extends StatefulWidget {
  final HadithBook book;
  final int? initialScrollIndex;

  const _HadithDetailsView({
    Key? key,
    required this.book,
    this.initialScrollIndex,
  }) : super(key: key);

  @override
  State<_HadithDetailsView> createState() => _HadithDetailsViewState();
}

class _HadithDetailsViewState extends State<_HadithDetailsView> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final TextEditingController _searchController = TextEditingController();

  bool _isSearchVisible = false;
  bool _hasScrolledToInitial = false;

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_onScroll);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onScroll);
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Only save progress if we are NOT searching and NOT jumping to initial index
    if (_isSearchVisible) return;

    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      final firstIndex = positions
          .where((ItemPosition position) => position.itemTrailingEdge > 0)
          .reduce(
            (ItemPosition min, ItemPosition position) =>
                position.itemLeadingEdge < min.itemLeadingEdge ? position : min,
          )
          .index;

      context.read<HadithDetailsCubit>().saveProgress(firstIndex);

      // Mark visible items as read
      for (var position in positions) {
        if (position.itemLeadingEdge < 1.0 && position.itemTrailingEdge > 0.0) {
          // It's visible
          // We need to resolve actual hadith number.
          // Since we use filtered list, we must be careful if search is active (but we return if search active above)
          // If search is NOT active, filteredHadiths == allHadiths, so index maps correctly
          final cubit = context.read<HadithDetailsCubit>();
          final state = cubit.state;
          if (state is HadithDetailsLoaded) {
            // Assuming hadith number is index + 1 or stored in model. Using model number is safer.
            final hadith = state.filteredHadiths[position.index];
            if (hadith.number != null) {
              cubit.markAsRead(hadith.number!);
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible
            ? null // Title hidden when search is active if we want, but user asked for "TextField below the AppBar".
            // Actually, usually "below AppBar" means inside `bottom` or flexibleSpace.
            // Let's implement it as a bottom widget for the AppBar to increase height.
            : Text(
                widget.book.name,
                style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
              ),
        centerTitle: true,
        toolbarHeight: 100,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),

        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.expand_less : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  context.read<HadithDetailsCubit>().search('');
                }
              });
            },
          ),
        ],
        bottom: _isSearchVisible
            ? PreferredSize(
                preferredSize: Size.fromHeight(60.h),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                  child: HadithSearchTextField(
                    controller: _searchController,
                    hintText: "بحث في ${widget.book.name}...",
                    onChanged: (query) {
                      context.read<HadithDetailsCubit>().search(query);
                    },
                    onClear: () {
                      context.read<HadithDetailsCubit>().search('');
                    },
                  ),
                ),
              )
            : null,
      ),
      body: BlocConsumer<HadithDetailsCubit, HadithDetailsState>(
        listener: (context, state) {
          if (state is HadithDetailsLoaded && !_hasScrolledToInitial) {
            int targetIndex = widget.initialScrollIndex ?? state.lastReadIndex;
            if (targetIndex > 0) {
              Future.delayed(const Duration(milliseconds: 300), () {
                if (_itemScrollController.isAttached) {
                  if (targetIndex < state.filteredHadiths.length) {
                    _itemScrollController.jumpTo(index: targetIndex);
                  }
                  _hasScrolledToInitial = true;
                }
              });
            } else {
              _hasScrolledToInitial = true;
            }
          }
        },
        builder: (context, state) {
          if (state is HadithDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HadithDetailsError) {
            return Center(child: Text(state.message));
          } else if (state is HadithDetailsLoaded) {
            final hadiths = state.filteredHadiths;

            if (hadiths.isEmpty) {
              return Center(
                child: Text("لا توجد نتائج", style: GoogleFonts.cairo()),
              );
            }

            return ScrollablePositionedList.builder(
              itemCount: hadiths.length,
              itemScrollController: _itemScrollController,
              itemPositionsListener: _itemPositionsListener,
              padding: EdgeInsets.only(bottom: 20.h),
              itemBuilder: (context, index) {
                final hadith = hadiths[index];
                final isFav =
                    hadith.number != null &&
                    state.favorites.contains(hadith.number);
                final isRead =
                    hadith.number != null &&
                    state.readHadiths.contains(hadith.number);
                final note = (hadith.number != null)
                    ? state.notes[hadith.number]
                    : null;

                return HadithItem(
                  hadith: hadith,
                  index: index,
                  totalHadiths: widget.book.totalHadiths,
                  highlightQuery: _searchController.text,
                  isFavorite: isFav,
                  isRead: isRead,
                  note: note,
                  onToggleFavorite: () {
                    if (hadith.number != null) {
                      context.read<HadithDetailsCubit>().toggleFavorite(
                        hadith.number!,
                      );
                    }
                  },
                  onAddNote: () {
                    if (hadith.number != null) {
                      _showNoteDialog(context, hadith.number!, note);
                    }
                  },
                );
              },
            );
          }
          return Container();
        },
      ),
    );
  }

  void _showNoteDialog(
    BuildContext context,
    int hadithNumber,
    String? initialNote,
  ) {
    final TextEditingController noteController = TextEditingController(
      text: initialNote,
    );
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            "ملاحظة على الحديث",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: noteController,
            maxLines: 5,
            minLines: 3,
            decoration: InputDecoration(
              hintText: "أكتب ملاحظتك هنا...",
              hintStyle: GoogleFonts.cairo(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          actions: [
            if (initialNote != null && initialNote.isNotEmpty)
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (confirmContext) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        title: Text(
                          "تأكيد الحذف",
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                          "هل تريد حذف الملاحظة؟",
                          style: GoogleFonts.cairo(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(confirmContext),
                            child: Text(
                              "إلغاء",
                              style: GoogleFonts.cairo(color: Colors.grey),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context.read<HadithDetailsCubit>().deleteNote(
                                hadithNumber,
                              );
                              Navigator.pop(confirmContext);
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "تم حذف الملاحظة",
                                    style: GoogleFonts.cairo(),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              "تأكيد",
                              style: GoogleFonts.cairo(color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  "حذف الملاحظة",
                  style: GoogleFonts.cairo(color: Colors.red),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "إلغاء",
                style: GoogleFonts.cairo(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final note = noteController.text.trim();
                if (note.isNotEmpty) {
                  context.read<HadithDetailsCubit>().saveNote(
                    hadithNumber,
                    note,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "تم حفظ الملاحظة",
                        style: GoogleFonts.cairo(),
                      ),
                    ),
                  );
                } else if (initialNote != null) {
                  // If note is cleared, delete it.
                  context.read<HadithDetailsCubit>().deleteNote(hadithNumber);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "تم حذف الملاحظة",
                        style: GoogleFonts.cairo(),
                      ),
                    ),
                  );
                }
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text("حفظ", style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
