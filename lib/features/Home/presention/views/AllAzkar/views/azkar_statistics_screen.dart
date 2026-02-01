import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../models/azkar_stats_service.dart';

class AzkarStatisticsScreen extends StatefulWidget {
  const AzkarStatisticsScreen({super.key});

  @override
  State<AzkarStatisticsScreen> createState() => _AzkarStatisticsScreenState();
}

class _AzkarStatisticsScreenState extends State<AzkarStatisticsScreen> {
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final count = await AzkarStatsService.getTotal();
    setState(() => _totalCount = count);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("إحصائيات الأذكار"),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Total Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryColor, Color(0xFF7E72B7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.show_chart, color: Colors.white, size: 40),
                  const SizedBox(height: 10),
                  const Text(
                    "مجموع الذكر المنجز",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "$_totalCount",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "استمر في الطاعة 🚀",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Badges / Gamification (Mock)
            _buildSectionTitle("الأوسمة"),
            const SizedBox(height: 12),
            _buildBadges(),

            const SizedBox(height: 24),

            // Weekly Chart (Mock)
            _buildSectionTitle("نشاطك هذا الأسبوع"),
            const SizedBox(height: 12),
            Container(
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (index) {
                  final day = [
                    "السبت",
                    "الأحد",
                    "الاثنين",
                    "الثلاثاء",
                    "الأربعاء",
                    "الخميس",
                    "الجمعة",
                  ][index];
                  final height = (index * 20.0 + 30) % 100 + 20; // Mock data
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 12,
                        height: height,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        day,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBadges() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildBadgeItem(Icons.verified, "المواظب", true),
        _buildBadgeItem(Icons.star, "المتميز", _totalCount > 1000),
        _buildBadgeItem(Icons.workspace_premium, "ختمة", _totalCount > 5000),
      ],
    );
  }

  Widget _buildBadgeItem(IconData icon, String label, bool unlocked) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: unlocked ? Colors.amber.shade100 : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: unlocked ? Colors.amber.shade700 : Colors.grey,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: unlocked ? Colors.black87 : Colors.grey,
            fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
