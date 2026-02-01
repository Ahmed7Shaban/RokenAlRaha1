import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/hadith_logic/hadith_search_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/data/repositories/hadith_repository.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/presentation/pages/hadith_details_page.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/presentation/widgets/hadith_item.dart';
import 'package:roken_al_raha/features/Home/presention/views/Hadith/presentation/widgets/hadith_search_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../../core/theme/app_colors.dart';

class HadithSearchPage extends StatelessWidget {
  const HadithSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HadithSearchCubit(HadithRepository()),
      child: const _HadithSearchView(),
    );
  }
}

class _HadithSearchView extends StatefulWidget {
  const _HadithSearchView({Key? key}) : super(key: key);

  @override
  State<_HadithSearchView> createState() => _HadithSearchViewState();
}

class _HadithSearchViewState extends State<_HadithSearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: HadithSearchTextField(
          controller: _searchController,
          hintText: "بحث في كل الكتب المحملة...",
          onChanged: (query) {
            context.read<HadithSearchCubit>().search(query);
          },
          onClear: () {
            context.read<HadithSearchCubit>().search('');
          },
        ),
        backgroundColor: AppColors.primaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        toolbarHeight: 100,
      ),
      body: BlocBuilder<HadithSearchCubit, HadithSearchState>(
        builder: (context, state) {
          if (state is HadithSearchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HadithSearchError) {
            return Center(child: Text("حدث خطأ: ${state.message}"));
          } else if (state is HadithSearchLoaded) {
            if (state.results.isEmpty) {
              return const Center(child: Text("لا توجد نتائج مطابقة للبحث"));
            }
            return ListView.builder(
              itemCount: state.results.length,
              itemBuilder: (context, index) {
                final result = state.results[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 4.h,
                      ),
                      child: Text(
                        result.book.name,
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HadithDetailsPage(
                              book: result.book,
                              initialScrollIndex: result.hadith.number != null
                                  ? result.hadith.number! - 1
                                  : index, // Approximating index
                            ),
                          ),
                        );
                      },
                      child: HadithItem(
                        hadith: result.hadith,
                        index: index,
                        highlightQuery: state.query,
                      ),
                    ),
                  ],
                );
              },
            );
          }
          return Center(
            child: Text(
              "ابدأ البحث في الأحاديث المحملة",
              style: GoogleFonts.cairo(),
            ),
          );
        },
      ),
    );
  }
}
