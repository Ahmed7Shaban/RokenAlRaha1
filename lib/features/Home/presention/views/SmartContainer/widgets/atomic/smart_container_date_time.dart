import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' as intl;
import 'smart_container_helpers.dart';

class SmartContainerDateTime extends StatelessWidget {
  final HijriCalendar hijriDate;
  final DateTime currentTime;

  const SmartContainerDateTime({
    super.key,
    required this.hijriDate,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                SmartContainerHelpers.formatHijriDate(hijriDate),
                style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                SmartContainerHelpers.toArabicNumsStr(
                  intl.DateFormat('EEEE, d MMMM', 'ar').format(currentTime),
                ),
                style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),

          // Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                SmartContainerHelpers.toArabicNumsStr(
                      intl.DateFormat('h:mm', 'en').format(currentTime),
                    ) +
                    (currentTime.hour >= 12 ? " م" : " ص"),
                style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                currentTime.hour >= 6 && currentTime.hour < 18
                    ? Icons.wb_sunny_rounded
                    : Icons.nights_stay_rounded,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
