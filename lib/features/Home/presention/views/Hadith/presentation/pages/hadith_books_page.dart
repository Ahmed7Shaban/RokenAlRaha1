import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/hadith_logic/hadith_books_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/repositories/hadith_repository.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/presentation/pages/hadith_details_page.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/presentation/pages/search/hadith_search_page.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/presentation/widgets/hadith_book_card.dart';

import 'package:roken_al_raha/features/Home/presention/views/Hadith/presentation/pages/favorites/hadith_favorites_page.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../widgets/ramadan_background.dart';

class HadithBooksPage extends StatefulWidget {
  const HadithBooksPage({Key? key}) : super(key: key);

  @override
  State<HadithBooksPage> createState() => _HadithBooksPageState();
}

class _HadithBooksPageState extends State<HadithBooksPage> {
  // Track which book we are trying to open to auto-navigate after download
  String? _pendingOpenBookId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HadithBooksCubit(HadithRepository())..loadBooks(),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "الأحاديث النبوية",
            style: GoogleFonts.amiri(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primaryColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          toolbarHeight: 100,
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HadithFavoritesPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HadithSearchPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: RamadanBackground(
          child: BlocConsumer<HadithBooksCubit, HadithBooksState>(
            listener: (context, state) {
              if (state is HadithBooksLoaded) {
                if (state.downloadError != null &&
                    state.downloadingBookId != null) {
                  // Show error snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.downloadError ?? "حدث خطأ")),
                  );
                  // Clear the error so it doesn't persist
                  context.read<HadithBooksCubit>().clearError(
                    state.downloadingBookId!,
                  );
                  _pendingOpenBookId = null;
                }

                if (_pendingOpenBookId != null) {
                  // Check if our pending book is now downloaded and NOT downloading anymore
                  try {
                    final book = state.books.firstWhere(
                      (b) => b.id == _pendingOpenBookId,
                    );
                    if (book.isDownloaded &&
                        state.downloadingBookId != book.id) {
                      _pendingOpenBookId = null;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HadithDetailsPage(book: book),
                        ),
                      ).then((_) {
                        if (context.mounted) {
                          context.read<HadithBooksCubit>().loadBooks();
                        }
                      });
                    }
                  } catch (_) {}
                }
              }
            },
            builder: (context, state) {
              if (state is HadithBooksLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is HadithBooksError) {
                return Center(child: Text("خطأ: ${state.message}"));
              } else if (state is HadithBooksLoaded) {
                final books = state.books;
                if (books.isEmpty) {
                  return const Center(child: Text("لا توجد كتب متاحة"));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return HadithBookCard(
                      book: book,
                      onTap: () {
                        if (book.isDownloaded) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HadithDetailsPage(book: book),
                            ),
                          ).then((_) {
                            if (context.mounted) {
                              context.read<HadithBooksCubit>().loadBooks();
                            }
                          });
                        } else {
                          // Auto Download
                          _pendingOpenBookId = book.id;
                          context.read<HadithBooksCubit>().downloadBook(book);
                        }
                      },
                    );
                  },
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
