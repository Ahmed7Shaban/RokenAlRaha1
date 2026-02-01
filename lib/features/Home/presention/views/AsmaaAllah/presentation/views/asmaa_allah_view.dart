import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:roken_al_raha/core/widgets/shared_branding_widget.dart';
import '../../logic/asmaa_allah_cubit.dart';
import '../../logic/asmaa_allah_state.dart';
import '../widgets/allah_name_card.dart';

class AsmaaAllahView extends StatelessWidget {
  static const String routeName = '/AsmaaAllah';

  const AsmaaAllahView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AsmaaAllahCubit()..loadNames(),
      child: const _AsmaaAllahBody(),
    );
  }
}

class _AsmaaAllahBody extends StatelessWidget {
  const _AsmaaAllahBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "أسماء الله الحسنى",
          style: GoogleFonts.amiri(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: BlocBuilder<AsmaaAllahCubit, AsmaaAllahState>(
        builder: (context, state) {
          if (state is AsmaaAllahLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          } else if (state is AsmaaAllahError) {
            return Center(child: Text(state.message));
          } else if (state is AsmaaAllahLoaded) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 items per row
                          childAspectRatio: 1.1, // Slightly wider than square
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return AllahNameCard(
                            nameModel: state.names[index],
                            index: index,
                          )
                          .animate(delay: (30 * index).ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0);
                    }, childCount: state.names.length),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(child: SharedBrandingWidget()),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
