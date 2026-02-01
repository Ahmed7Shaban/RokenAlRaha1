import 'package:flutter/material.dart';

class ReadingTheme {
  final int id;
  final Color backgroundColor;
  final Color textColor;
  final String name;

  const ReadingTheme({
    required this.id,
    required this.backgroundColor,
    required this.textColor,
    required this.name,
  });

  static const List<ReadingTheme> themes = [
    // --- Light / Cream / Sepia (Standard Reading) ---
    ReadingTheme(
      id: 1,
      backgroundColor: Color(0xFFFFFFFF),
      textColor: Colors.black,
      name: "White",
    ),
    ReadingTheme(
      id: 2,
      backgroundColor: Color(0xFFFFFDF5),
      textColor: Colors.black,
      name: "Cream",
    ), // Default
    ReadingTheme(
      id: 3,
      backgroundColor: Color(0xFFFAF7E1),
      textColor: Colors.black,
      name: "Paper",
    ),
    ReadingTheme(
      id: 4,
      backgroundColor: Color(0xFFF5F5DC),
      textColor: Colors.black,
      name: "Beige",
    ),
    ReadingTheme(
      id: 5,
      backgroundColor: Color(0xFFEBE2CD),
      textColor: Color(0xFF3E3221),
      name: "Sepia Light",
    ),
    ReadingTheme(
      id: 6,
      backgroundColor: Color(0xFFE0D6B9),
      textColor: Color(0xFF3E3221),
      name: "Sepia",
    ),
    ReadingTheme(
      id: 7,
      backgroundColor: Color(0xFFD6CDB2),
      textColor: Color(0xFF2D2418),
      name: "Sepia Dark",
    ),

    // --- Soft Tints (Eye Comfort) ---
    ReadingTheme(
      id: 8,
      backgroundColor: Color(0xFFEBF5FB),
      textColor: Color(0xFF143042),
      name: "Soft Blue",
    ),
    ReadingTheme(
      id: 9,
      backgroundColor: Color(0xFFF0F8EC),
      textColor: Color(0xFF1B3818),
      name: "Soft Green",
    ),
    ReadingTheme(
      id: 10,
      backgroundColor: Color(0xFFFCF2F4),
      textColor: Color(0xFF4A1F26),
      name: "Soft Pink",
    ),
    ReadingTheme(
      id: 11,
      backgroundColor: Color(0xFFF8F2FC),
      textColor: Color(0xFF331E40),
      name: "Soft Purple",
    ),

    // --- Medium / Dimmed ---
    ReadingTheme(
      id: 12,
      backgroundColor: Color(0xFFC4C4C4),
      textColor: Colors.black,
      name: "Grey Light",
    ),
    ReadingTheme(
      id: 13,
      backgroundColor: Color(0xFF9E9E9E),
      textColor: Colors.black,
      name: "Grey Medium",
    ),
    ReadingTheme(
      id: 14,
      backgroundColor: Color(0xFF7B858B),
      textColor: Colors.white,
      name: "Slate",
    ),
    ReadingTheme(
      id: 15,
      backgroundColor: Color(0xFF5D6D7E),
      textColor: Colors.white,
      name: "Blue Grey",
    ),

    // --- Dark / Night Mode ---
    ReadingTheme(
      id: 16,
      backgroundColor: Color(0xFF34495E),
      textColor: Colors.white,
      name: "Night Blue",
    ),
    ReadingTheme(
      id: 17,
      backgroundColor: Color(0xFF2C3E50),
      textColor: Color(0xFFEAECEE),
      name: "Midnight",
    ),
    ReadingTheme(
      id: 18,
      backgroundColor: Color(0xFF262626),
      textColor: Color(0xFFE0E0E0),
      name: "Dark Grey",
    ),
    ReadingTheme(
      id: 19,
      backgroundColor: Color(0xFF1A1A1A),
      textColor: Color(0xFFB0B0B0),
      name: "Almost Black",
    ),
    ReadingTheme(
      id: 20,
      backgroundColor: Color(0xFF000000),
      textColor: Color(0xFF9E9E9E),
      name: "AMOLED Black",
    ),
  ];

  static ReadingTheme get defaultTheme => themes[1]; // Cream
}
