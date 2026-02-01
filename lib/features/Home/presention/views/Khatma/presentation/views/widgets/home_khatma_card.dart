import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:roken_al_raha/features/Home/presention/views/Khatma/logic/khatma_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/Khatma/logic/khatma_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/Khatma/presentation/views/khatma_dashboard_view.dart';

class HomeKhatmaCard extends StatelessWidget {
  const HomeKhatmaCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KhatmaCubit, KhatmaState>(
      builder: (context, state) {
        if (state is KhatmaLoaded && state.activeKhatma != null) {
          final khatma = state.activeKhatma!;
          double progress = 0;
          if (khatma.endPage > 0) {
            progress = khatma.lastReadPage / 604.0;
          }
          if (progress > 1.0) progress = 1.0;

          final khatmaStatus = context
              .read<KhatmaCubit>()
              .calculateKhatmaStatus(khatma);
          Color statusColor = khatmaStatus.color;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: statusColor.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bookmark, color: statusColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          khatma.name,
                          style: GoogleFonts.tajawal(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Text(
                        khatmaStatus.message,
                        textAlign: TextAlign.end,
                        style: GoogleFonts.tajawal(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "آخر صفحة: ${khatma.lastReadPage}",
                      style: GoogleFonts.tajawal(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate simply to Dashboard or Details
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const KhatmaPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(
                        khatmaStatus.color == Colors.red ? "تدارك" : "استمرار",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
