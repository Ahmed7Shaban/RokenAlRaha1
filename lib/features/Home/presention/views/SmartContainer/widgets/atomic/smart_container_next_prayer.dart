import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/smart_container_cubit.dart';
import '../prayer_list_sheet.dart';
import 'smart_container_helpers.dart';

class SmartContainerNextPrayer extends StatelessWidget {
  final PrayerTimes? prayerTimes;
  final dynamic nextPrayer;
  final Duration timeUntilNextPrayer;

  const SmartContainerNextPrayer({
    super.key,
    required this.prayerTimes,
    required this.nextPrayer,
    required this.timeUntilNextPrayer,
  });

  @override
  Widget build(BuildContext context) {
    if (prayerTimes == null) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (_) => BlocProvider.value(
              value: context.read<SmartContainerCubit>(),
              child: PrayerListSheet(prayerTimes: prayerTimes!),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white30, width: 1),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Right: Prayer Name
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_filled,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        nextPrayer != null
                            ? 'الصلاة القادمة: ${SmartContainerHelpers.mapPrayerNameArabic(nextPrayer!)}'
                            : 'جاري الحساب...',
                        style: GoogleFonts.tajawal(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),
                  // Left: Countdown
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'باقي: ${SmartContainerHelpers.toArabicNumsStr(SmartContainerHelpers.formatDuration(timeUntilNextPrayer))}',
                        style: GoogleFonts.tajawal(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white70,
                        size: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
