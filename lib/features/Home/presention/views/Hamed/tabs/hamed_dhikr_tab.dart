import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../cubit/hamed_cubit.dart';
import '../cubit/hamed_state.dart';
import '../date/hamed_list.dart';

class HamedDhikrTab extends StatelessWidget {
  final Function(String text, int count) onShare;

  const HamedDhikrTab({super.key, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HamedCubit, HamedState>(
      builder: (context, state) {
        if (state is! HamedLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: hamdList.length,
          itemBuilder: (context, index) {
            final dhikr = hamdList[index];
            final count = state.dhikrCounts[index] ?? 0;

            return GestureDetector(
              onTap: () {
                context.read<HamedCubit>().incrementDhikr(index);
              },
              onLongPress: () => onShare(dhikr, count),
              child:
                  Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Counter Circle
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    border: Border.all(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$count',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Dhikr Text
                                Expanded(
                                  child: Text(
                                    dhikr,
                                    style: GoogleFonts.amiri(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => onShare(dhikr, count),
                                icon: const Icon(
                                  Icons.share,
                                  size: 18,
                                  color: AppColors.primaryColor,
                                ),
                                label: Text(
                                  "مشاركة كصورة",
                                  style: GoogleFonts.tajawal(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 400.ms,
                        delay: (index * 50).ms,
                      ),
            );
          },
        );
      },
    );
  }
}
