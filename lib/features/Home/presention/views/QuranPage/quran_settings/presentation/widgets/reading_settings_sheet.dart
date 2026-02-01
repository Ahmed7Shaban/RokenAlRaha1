import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../../../../core/theme/app_colors.dart';
import '../../data/models/reading_theme_model.dart';
import '../../logic/cubit/reading_settings_cubit.dart';
import '../../logic/cubit/reading_settings_state.dart';
import 'color_square_item.dart';

class ReadingSettingsSheet extends StatefulWidget {
  const ReadingSettingsSheet({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    final cubit = context.read<ReadingSettingsCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          BlocProvider.value(value: cubit, child: const ReadingSettingsSheet()),
    );
  }

  @override
  State<ReadingSettingsSheet> createState() => _ReadingSettingsSheetState();
}

enum _Panel { none, colors, scroll }

class _ReadingSettingsSheetState extends State<ReadingSettingsSheet> {
  _Panel _activePanel = _Panel.none;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header & Toggles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Scroll Mode Toggle
              _buildCircleOption(
                icon: Icons.layers_rounded,
                label: "التصفح",
                isSelected: _activePanel == _Panel.scroll,
                onTap: () {
                  setState(() {
                    _activePanel = _activePanel == _Panel.scroll
                        ? _Panel.none
                        : _Panel.scroll;
                  });
                },
              ),

              // Color Theme Toggle
              _buildCircleOption(
                icon: Icons.palette_rounded,
                label: "الألوان",
                isSelected: _activePanel == _Panel.colors,
                onTap: () {
                  setState(() {
                    _activePanel = _activePanel == _Panel.colors
                        ? _Panel.none
                        : _Panel.colors;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 2. Color Panel (Animated)
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "لون الخلفية",
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                BlocBuilder<ReadingSettingsCubit, ReadingSettingsState>(
                  builder: (context, state) {
                    int selectedId = ReadingTheme.defaultTheme.id;
                    if (state is ReadingSettingsLoaded) {
                      selectedId = state.theme.id;
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: ReadingTheme.themes.length,
                      itemBuilder: (context, index) {
                        final theme = ReadingTheme.themes[index];
                        return ColorSquareItem(
                          theme: theme,
                          isSelected: theme.id == selectedId,
                          onTap: () {
                            context.read<ReadingSettingsCubit>().updateTheme(
                              theme,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            crossFadeState: _activePanel == _Panel.colors
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),

          // 3. Scroll Mode Panel (Animated)
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "طريقة التصفح",
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                BlocBuilder<ReadingSettingsCubit, ReadingSettingsState>(
                  builder: (context, state) {
                    ReadingScrollMode currentMode = ReadingScrollMode.vertical;
                    if (state is ReadingSettingsLoaded) {
                      currentMode = state.scrollMode;
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _buildSelectionCard(
                            label: "رأسي",
                            icon: Icons.swap_vert_rounded,
                            isSelected:
                                currentMode == ReadingScrollMode.vertical,
                            onTap: () {
                              context
                                  .read<ReadingSettingsCubit>()
                                  .updateScrollMode(ReadingScrollMode.vertical);
                            },
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildSelectionCard(
                            label: "أفقي",
                            icon: Icons.swap_horiz_rounded,
                            isSelected:
                                currentMode == ReadingScrollMode.horizontal,
                            onTap: () {
                              context
                                  .read<ReadingSettingsCubit>()
                                  .updateScrollMode(
                                    ReadingScrollMode.horizontal,
                                  );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            crossFadeState: _activePanel == _Panel.scroll
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppColors.primaryColor
                  : Colors.grey.withOpacity(0.1),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black87,
              size: 28.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28.sp,
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade600,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? AppColors.primaryColor
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
