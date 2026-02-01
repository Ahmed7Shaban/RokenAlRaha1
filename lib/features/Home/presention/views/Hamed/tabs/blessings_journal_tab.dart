import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../../../core/theme/app_colors.dart';
import '../cubit/hamed_cubit.dart';
import '../cubit/hamed_state.dart';

class BlessingsJournalTab extends StatelessWidget {
  final Function(String text, int count) onShare;

  const BlessingsJournalTab({super.key, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBlessingDialog(context),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: Text(
          'أضف نعمة',
          style: GoogleFonts.tajawal(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<HamedCubit, HamedState>(
        builder: (context, state) {
          if (state is! HamedLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.blessings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.volunteer_activism, // Heart-hand icon
                    size: 80,
                    color: AppColors.primaryColor.withOpacity(0.3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'سجل نعم الله عليك',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'ابدأ اليوم بكتابة نعمة استشعرتها',
                    style: GoogleFonts.tajawal(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.blessings.length + 1, // +1 for Header
            itemBuilder: (context, index) {
              if (index == 0) {
                // Header Card
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.volunteer_activism,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "تدوين النعم صيدٌ للشرود، وطمأنينة للقلب.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiri(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "ابدأ الآن بتدوين نعمة لامست قلبك اليوم.. لعلها تكون سبباً في انشراح صدرك.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final actualIndex = index - 1;
              final raw = state.blessings[actualIndex];
              final parts = raw.split('###');
              final text = parts[0];
              final time = parts.length > 1
                  ? parts[1]
                  : intl.DateFormat('hh:mm a').format(DateTime.now());

              return Dismissible(
                key: md5Key(raw + actualIndex.toString()), // Unique key
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  context.read<HamedCubit>().deleteBlessing(actualIndex);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                      right: BorderSide(
                        color: AppColors.primaryColor.withOpacity(0.5),
                        width: 4,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.share,
                              size: 20,
                              color: AppColors.primaryColor,
                            ),
                            onPressed: () => onShare(
                              "الحمد لله على نعمة: $text",
                              1,
                            ), // Pass 1 as count, or customized
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                time,
                                style: GoogleFonts.tajawal(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Key md5Key(String str) {
    return ValueKey(str.hashCode);
  }

  void _showAddBlessingDialog(BuildContext context) {
    final controller = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'نعمة جديدة',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'اكتب النعمة هنا...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الوقت: ${selectedTime.format(context)}',
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.access_time,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.tajawal(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      final timeStr = selectedTime.format(context);
                      final content =
                          "${controller.text}###$timeStr"; // Simple separator
                      context.read<HamedCubit>().addBlessing(content);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'حفظ',
                    style: GoogleFonts.tajawal(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
