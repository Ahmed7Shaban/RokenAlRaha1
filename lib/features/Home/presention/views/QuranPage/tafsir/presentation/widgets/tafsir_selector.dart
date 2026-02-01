import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import '../../data/models/translation_data.dart';
import '../cubit/tafsir_state.dart';

class TafsirSelector extends StatelessWidget {
  final List<TranslationData> tafsirs;
  final TranslationData? selectedTafsir;
  final Function(TranslationData) onSelect;
  final Function(TranslationData) onDownload;
  final Map<String, double> downloadProgress;
  final Map<String, DownloadStatus> downloadStatuses;

  const TafsirSelector({
    super.key,
    required this.tafsirs,
    required this.selectedTafsir,
    required this.onSelect,
    required this.onDownload,
    required this.downloadProgress,
    required this.downloadStatuses,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: tafsirs.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final tafsir = tafsirs[index];
          // Determine state
          final isSelected = selectedTafsir?.name == tafsir.name;
          final status = downloadStatuses[tafsir.name] ?? DownloadStatus.idle;
          final isDownloading = status == DownloadStatus.downloading;
          final isDownloaded =
              tafsir.isDownloaded || status == DownloadStatus.downloaded;
          final progress = downloadProgress[tafsir.name] ?? 0.0;

          return GestureDetector(
            onTap: () {
              if (isDownloaded) {
                onSelect(tafsir);
              } else if (!isDownloading) {
                onDownload(tafsir);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tafsir.name,
                    style: GoogleFonts.cairo(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 14.sp,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (isDownloading)
                    SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: progress > 0 ? progress : null,
                        valueColor: AlwaysStoppedAnimation(
                          isSelected ? Colors.white : AppColors.primaryColor,
                        ),
                      ),
                    )
                  else if (isDownloaded)
                    Icon(
                      Icons.check_circle_outline,
                      size: 16.sp,
                      color: isSelected ? Colors.white : Colors.green,
                    )
                  else
                    Icon(
                      Icons.download_rounded,
                      size: 18.sp,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
