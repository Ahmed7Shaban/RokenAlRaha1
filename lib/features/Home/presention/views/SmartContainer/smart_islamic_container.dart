import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/theme/app_colors.dart';
import 'cubit/smart_container_cubit.dart';
import 'widgets/atomic/smart_container_background.dart';
import 'widgets/atomic/smart_container_countdown.dart';
import 'widgets/atomic/smart_container_date_time.dart';
import 'widgets/atomic/smart_container_header.dart';
import 'widgets/atomic/smart_container_next_prayer.dart';

class SmartIslamicContainer extends StatelessWidget {
  const SmartIslamicContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SmartIslamicContainerContent();
  }
}

class _SmartIslamicContainerContent extends StatelessWidget {
  const _SmartIslamicContainerContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmartContainerCubit, SmartContainerState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          height: 260,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.primaryColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Layer
              Positioned.fill(
                child: SmartContainerBackground(
                  assetPath: state.currentBackground,
                ),
              ),

              // Overlay
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.4)),
              ),

              // Content Layer
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Top Row: Location & Settings
                    SmartContainerHeader(locationName: state.locationName),

                    const Spacer(flex: 2),

                    // 2. Date & Time Row
                    SmartContainerDateTime(
                      hijriDate: state.hijriDate,
                      currentTime: state.currentTime,
                    ),

                    const Spacer(flex: 3),

                    // 3. Countdowns Section
                    SmartContainerCountdown(
                      eventCountdowns: state.eventCountdowns,
                    ),

                    const Spacer(flex: 3),

                    // 4. Bottom Row: Next Prayer
                    SmartContainerNextPrayer(
                      prayerTimes: state.prayerTimes,
                      nextPrayer: state.nextPrayer,
                      timeUntilNextPrayer: state.timeUntilNextPrayer,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
