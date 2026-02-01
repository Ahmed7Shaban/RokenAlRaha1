import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import '../../QuranPage/audio/data/reciters_data.dart';
import '../cubit/audio_quran_cubit.dart';
import '../cubit/audio_quran_state.dart';

class ReciterSelector extends StatelessWidget {
  const ReciterSelector({super.key});

  @override
  Widget build(BuildContext context) {
    if (availableReciters.length <= 1) {
      return const SizedBox.shrink(); // Hide if only 1 reciter
    }

    return BlocBuilder<AudioQuranCubit, AudioQuranState>(
      buildWhen: (prev, curr) => prev.selectedReciter != curr.selectedReciter,
      builder: (context, state) {
        return Container(
          height: 60.h,
          margin: EdgeInsets.symmetric(vertical: 8.h),
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: availableReciters.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final reciter = availableReciters[index];
              final isSelected = state.selectedReciter.id == reciter.id;

              return _ReciterCard(
                reciter: reciter,
                isSelected: isSelected,
                onTap: () {
                  context.read<AudioQuranCubit>().changeReciter(reciter);
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _ReciterCard extends StatelessWidget {
  final Reciter reciter;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReciterCard({
    required this.reciter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          reciter.name,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
