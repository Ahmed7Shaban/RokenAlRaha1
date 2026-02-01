import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/smart_container_cubit.dart';
import '../prayer_tracking_sheet.dart';
import '../settings_sheet.dart';

class SmartContainerHeader extends StatelessWidget {
  final String locationName;

  const SmartContainerHeader({super.key, required this.locationName});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Location (Right)
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    locationName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Settings (Left)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.fact_check,
                  color: Colors.white,
                  size: 22,
                ),
                tooltip: "متابعة العبادات",
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => BlocProvider.value(
                      value: context.read<SmartContainerCubit>(),
                      child: const PrayerTrackingSheet(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.settings, color: Colors.white, size: 22),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => BlocProvider.value(
                      value: context.read<SmartContainerCubit>(),
                      child: const SmartContainerSettingsSheet(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
