import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../cubit/smart_container_cubit.dart';

class MoazzenSelectionSheet extends StatefulWidget {
  const MoazzenSelectionSheet({super.key});

  @override
  State<MoazzenSelectionSheet> createState() => _MoazzenSelectionSheetState();
}

class _MoazzenSelectionSheetState extends State<MoazzenSelectionSheet> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingUrl;

  // Define the Moazzen List
  final List<Map<String, String>> _moazzens = [
    {
      'name': 'أحمد جلال يحيى - 1',
      'file': 'azan_ahmed_1',
      'desc': 'أذان هادئ وخاشع',
    },
    {
      'name': 'أحمد جلال يحيى - 2',
      'file': 'azan_ahmed_2',
      'desc': 'أذان بنبرة مميزة',
    },
    {
      'name': 'ياسر الدوسري',
      'file': 'azan_yaser',
      'desc': 'أذان الحرم المكي الشريف',
    },
    {'name': 'محمد جازي', 'file': 'mohamd_gazy', 'desc': 'أذان جميل ومؤثر'},
    // We keep Mishary as legacy option if needed, but since we default to Yaser if missing,
    // it's better to show only what we have or map properly.
    // Assuming Mishary file is missing, we might not want to list it or map it to something else in UI.
    // For now, listing valid ones.
  ];

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPreview(String fileName) async {
    try {
      if (_playingUrl == fileName) {
        // Stop if already playing this one
        await _audioPlayer.stop();
        setState(() {
          _playingUrl = null;
        });
      } else {
        // Stop previous
        await _audioPlayer.stop();

        setState(() {
          _playingUrl = fileName;
        });

        // PLAY Audio:
        // We assume the user has configured assets/Sounds/{fileName}.mp3 for preview.
        // If the file is only in raw/, we cannot play it via AssetSource easily.
        // But commonly devs put a copy in assets for in-app play.
        // If not, this might fail silently or log error.

        // Let's try to play from AssetSource assuming standard path.
        // Note: Filename in mapping doesn't have extension.
        // 'azan_ahmed_1' -> 'assets/Sounds/azan_ahmed_1.mp3'

        // Special check for 'mohamd_gazy' which is .webm in directory list BUT audio players usually prefer mp3/aac.
        // Let's rely on standard mp3 unless we know otherwise.
        // The directory list showed: "mohamd_gazy.webm".
        String extension = fileName.contains('gazy') ? 'webm' : 'mp3';

        await _audioPlayer.play(AssetSource('Sounds/$fileName.$extension'));

        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() {
              _playingUrl = null;
            });
          }
        });
      }
    } catch (e) {
      debugPrint("Error playing preview: $e");
      // Stop UI state if error
      if (mounted) {
        setState(() {
          _playingUrl = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7, // Max 70% height
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Handle Bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            "اختر صوت المؤذن",
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _moazzens.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final moazzen = _moazzens[index];
                final currentSelected = context
                    .watch<SmartContainerCubit>()
                    .state
                    .selectedMoazzen;
                // Handling mapping mismatch if any (legacy state)
                final isSelected = currentSelected == moazzen['file'];

                return Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor.withOpacity(0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.grey.shade200,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    onTap: () {
                      context.read<SmartContainerCubit>().setMoazzen(
                        moazzen['file']!,
                      );
                      Navigator.pop(context);
                    },
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? AppColors.primaryColor
                          : Colors.grey.shade100,
                      child: Icon(
                        Icons.mic,
                        color: isSelected ? Colors.white : Colors.grey,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      moazzen['name']!,
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      moazzen['desc']!,
                      style: GoogleFonts.tajawal(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    trailing: InkWell(
                      onTap: () {
                        // Prevent the tile tap from firing
                        _playPreview(moazzen['file']!);
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _playingUrl == moazzen['file']
                              ? Colors.red.withOpacity(0.1)
                              : AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _playingUrl == moazzen['file']
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          color: _playingUrl == moazzen['file']
                              ? Colors.red
                              : AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
