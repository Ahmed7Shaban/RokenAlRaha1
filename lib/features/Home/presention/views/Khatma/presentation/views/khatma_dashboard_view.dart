import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import 'package:roken_al_raha/features/Home/presention/views/Khatma/logic/khatma_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/Khatma/logic/khatma_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/Khatma/presentation/views/widgets/create_khatma_bottom_sheet.dart';
import 'package:roken_al_raha/features/Home/presention/views/Khatma/presentation/views/khatma_view.dart';
import 'package:roken_al_raha/features/Home/presention/views/Khatma/data/repositories/khatma_repository.dart';

import 'package:roken_al_raha/features/Home/presention/views/Khatma/data/models/khatma_model.dart';

class KhatmaDashboardView extends StatelessWidget {
  const KhatmaDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure Cubit is provided if not already.
    // Ideally provided at App level or Page level.
    // Assuming passed from 'KhatmaPage' wrapper if used, OR we provide it here locally for testing.
    return Scaffold(
      //backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          "ختماتي",
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: 100,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<KhatmaCubit, KhatmaState>(
        builder: (context, state) {
          if (state is KhatmaLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.goldenYellow),
            );
          }

          List<dynamic> khatmas = [];
          if (state is KhatmaLoaded) {
            khatmas = state.khatmas;
          }

          if (khatmas.isEmpty) {
            return _buildEmptyState(context);
          }

          int streak = 0;
          int total = 0;
          if (state is KhatmaLoaded) {
            streak = state.streak;
            total = state.totalCompleted;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatsHeader(context, streak, total),
              const SizedBox(height: 24),
              ...khatmas
                  .map(
                    (k) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildKhatmaCard(context, k),
                    ),
                  )
                  .toList(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Color.fromARGB(255, 255, 255, 255)),
        label: Text(
          "ختمة جديدة",
          style: GoogleFonts.cairo(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => BlocProvider.value(
              value: context.read<KhatmaCubit>(),
              child: const CreateKhatmaBottomSheet(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/EmptyList.json',
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            "لا توجد ختمات حالياً",
            style: GoogleFonts.tajawal(
              color: AppColors.primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "ابدأ ختمة جديدة الآن واستمر في طاعتك، اجعل القرآن رفيقك اليومي.",
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context, int streak, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldenYellow,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            "ختمات مكتملة",
            "$total",
            Icons.check_circle_outline,
            Colors.greenAccent,
          ),
          Container(width: 1, height: 40, color: Colors.white10),
          _buildStatItem(
            "أيام متتالية",
            "$streak 🔥",
            Icons.local_fire_department,
            Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.cairo(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildKhatmaCard(BuildContext context, KhatmaModel khatma) {
    bool isCompleted = khatma.isCompleted;
    double progress = 0;
    if (khatma.endPage > 0) {
      progress = khatma.lastReadPage / 604.0;
    }
    if (progress > 1.0) progress = 1.0;

    // Use the Cubit's central logic for status
    final status = context.read<KhatmaCubit>().calculateKhatmaStatus(khatma);

    return Dismissible(
      key: Key(khatma.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "تأكيد الحذف",
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              content: Text(
                "هل أنت متأكد من حذف هذه الختمة؟",
                style: GoogleFonts.cairo(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    "إلغاء",
                    style: GoogleFonts.cairo(color: Colors.white60),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    "حذف",
                    style: GoogleFonts.cairo(
                      color: AppColors.goldenYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        context.read<KhatmaCubit>().deleteKhatma(khatma.id);
      },
      child: GestureDetector(
        onTap: () {
          // Set as active then navigate to Details
          context.read<KhatmaCubit>().setActiveKhatma(khatma.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<KhatmaCubit>(),
                child: const KhatmaDetailsPage(),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: status.color, // Dynamic Border Color
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          khatma.name,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status.message,
                          style: GoogleFonts.tajawal(
                            // Updated Font
                            color: status.color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCircularProgress(progress),
                ],
              ),
              const SizedBox(height: 12),
              // Reminder Times display
              if (khatma.remindersEnabled &&
                  khatma.reminderTimes.isNotEmpty) ...[
                const Divider(color: Colors.white10),
                Row(
                  children: [
                    const Icon(
                      Icons.alarm,
                      size: 14,
                      color: AppColors.goldenYellow,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "تذكيرات: ${khatma.reminderTimes.join(', ')}",
                        style: GoogleFonts.cairo(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "صفحة ${khatma.lastReadPage}",
                    style: GoogleFonts.cairo(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  if (!isCompleted)
                    Text(
                      "متبقي ${khatma.durationDays} يوم",
                      style: GoogleFonts.cairo(
                        color: AppColors.goldenYellow,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularProgress(double percent) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: percent,
            strokeWidth: 4,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.goldenYellow,
            ),
          ),
          Center(
            child: Text(
              "${(percent * 100).toInt()}%",
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Wrapper to provide Cubit to Dashboard
// Wrapper to provide Cubit to Dashboard
class KhatmaPage extends StatelessWidget {
  const KhatmaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KhatmaCubit(KhatmaRepository())..loadKhatmas(),
      child: const KhatmaDashboardView(),
    );
  }
}
