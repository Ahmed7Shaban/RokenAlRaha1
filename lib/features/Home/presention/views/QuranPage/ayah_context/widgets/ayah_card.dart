import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

class AyahCard extends StatelessWidget {
  final int surahNumber;
  final int verseNumber;
  final bool isSelected;
  final VoidCallback onTap;

  const AyahCard({
    Key? key,
    required this.surahNumber,
    required this.verseNumber,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine background color based on selection
    final bgColor = isSelected
        ? Theme.of(context).primaryColor.withOpacity(0.1)
        : Colors.transparent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: Theme.of(context).primaryColor, width: 1)
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Verse Number and Selection Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xffF2F2F2),
                    child: Text(
                      "$verseNumber",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).primaryColor,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Arabic Text
              Text(
                quran.getVerse(surahNumber, verseNumber, verseEndSymbol: true),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: "Amiri",
                  fontSize: 22,
                  height: 2.0,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
