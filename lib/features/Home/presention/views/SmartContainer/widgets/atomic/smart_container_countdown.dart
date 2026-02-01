import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'smart_container_helpers.dart';

class SmartContainerCountdown extends StatelessWidget {
  final Map<String, int> eventCountdowns;

  const SmartContainerCountdown({super.key, required this.eventCountdowns});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildEventItem("رمضان", eventCountdowns['Ramadan'] ?? 0),
            _buildDivider(),
            _buildEventItem("عيد الفطر", eventCountdowns['Eid Al-Fitr'] ?? 0),
            _buildDivider(),
            _buildEventItem("عيد الأضحى", eventCountdowns['Eid Al-Adha'] ?? 0),
            _buildDivider(),
            _buildEventItem(
              "المولد النبوي",
              eventCountdowns['Mawlid Al-Nabi'] ?? 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 25, color: Colors.white30);
  }

  Widget _buildEventItem(String title, int days) {
    return Flexible(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          children: [
            Text(
              SmartContainerHelpers.toArabicNums(days),
              style: GoogleFonts.tajawal(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
