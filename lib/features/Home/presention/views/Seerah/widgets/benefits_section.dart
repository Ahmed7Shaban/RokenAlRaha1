import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_card.dart';
import 'salat_benefit_item.dart';

class BenefitsSection extends StatelessWidget {
  const BenefitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "💎 صيغ وفضائل",
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFD4AF37),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          const SalatBenefitItem(
            title: "الصيغة الإبراهيمية",
            content:
                "اللهم صل على محمد وعلى آل محمد كما صليت على إبراهيم وعلى آل إبراهيم إنك حميد مجيد...",
            note:
                "فضل الصلاة أمر الله تعالى: تُعد استجابةً مباشرة لأمر الله سبحانه في قوله: {يَا أَيُّهَا الَّذِينَ آمَنُوا صَلُّوا عَلَيْهِ وَسَلِّمُوا تَسْلِيمًا}",
          ),
          const Divider(color: Colors.white10, height: 1),
          const SalatBenefitItem(
            title: "الصيغة القصيرة",
            content: "اللهم صل وسلم على نبينا محمد",
            note: "سهلة للتكرار وتجلب البركة",
          ),
        ],
      ),
    );
  }
}
