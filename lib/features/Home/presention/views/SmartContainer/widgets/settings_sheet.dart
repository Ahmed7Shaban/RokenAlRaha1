import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../cubit/smart_container_cubit.dart';

class SmartContainerSettingsSheet extends StatefulWidget {
  const SmartContainerSettingsSheet({super.key});

  @override
  State<SmartContainerSettingsSheet> createState() =>
      _SmartContainerSettingsSheetState();
}

class _SmartContainerSettingsSheetState
    extends State<SmartContainerSettingsSheet> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingFile;

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
    {
      'name': 'محمد جازي',
      'file': 'mohamd_gazy', // Matches mohamd_gazy.mp3
      'desc': 'أذان جميل ومؤثر',
    },
  ];

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPreview(String fileName) async {
    try {
      if (_playingFile == fileName) {
        // Stop if already playing this one
        await _audioPlayer.stop();
        setState(() {
          _playingFile = null;
        });
      } else {
        // Stop previous
        await _audioPlayer.stop();

        setState(() {
          _playingFile = fileName;
        });

        // Unified extension to .mp3 as requested.
        final String assetPath = 'Sounds/$fileName.mp3';
        debugPrint("🔊 Attempting to play preview via Settings: $assetPath");

        await _audioPlayer.play(AssetSource(assetPath));

        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() {
              _playingFile = null;
            });
          }
        });
      }
    } catch (e) {
      debugPrint("❌ Error playing preview via Settings: $e");
      if (mounted) {
        setState(() {
          _playingFile = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SmartContainerCubit, SmartContainerState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Container(
          // Allow sheet to take up to 85% of screen height to show list properly
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Text(
                  'إعدادات الصلاة',
                  style: GoogleFonts.tajawal(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),

                // 1. Azan Toggle Switch
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      'تفعيل تنبيهات الأذان',
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'إشعارات صوتية لكل صلاة',
                      style: GoogleFonts.tajawal(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    value: state.isAzanEnabled,
                    activeColor: AppColors.primaryColor,
                    onChanged: (value) {
                      context.read<SmartContainerCubit>().toggleAzan(value);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 2. Moazzen List (Only visible if Azan enabled)
                if (state.isAzanEnabled) ...[
                  Text(
                    'اختر المؤذن',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 30),
                      itemCount: _moazzens.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final moazzen = _moazzens[index];
                        final String fileKey = moazzen['file']!;
                        final bool isSelected =
                            state.selectedMoazzen == fileKey;
                        final bool isPlaying = _playingFile == fileKey;

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
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              context.read<SmartContainerCubit>().setMoazzen(
                                fileKey,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  // Radio / Selection Indicator
                                  Radio<String>(
                                    value: fileKey,
                                    groupValue: state.selectedMoazzen,
                                    activeColor: AppColors.primaryColor,
                                    onChanged: (val) {
                                      if (val != null) {
                                        context
                                            .read<SmartContainerCubit>()
                                            .setMoazzen(val);
                                      }
                                    },
                                  ),

                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          moazzen['name']!,
                                          style: GoogleFonts.tajawal(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          moazzen['desc']!,
                                          style: GoogleFonts.tajawal(
                                            color: Colors.grey,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Play Preview Button
                                  InkWell(
                                    onTap: () => _playPreview(fileKey),
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isPlaying
                                            ? Colors.red.withOpacity(0.1)
                                            : AppColors.primaryColor
                                                  .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isPlaying
                                            ? Icons.stop_rounded
                                            : Icons.play_arrow_rounded,
                                        color: isPlaying
                                            ? Colors.red
                                            : AppColors.primaryColor,
                                        size: 26,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  // Fallback/Space when hidden
                  const Spacer(),
                  Center(
                    child: Text(
                      "قم بتفعيل التنبيهات لاختيار المؤذن",
                      style: GoogleFonts.tajawal(color: Colors.grey),
                    ),
                  ),
                  const Spacer(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
