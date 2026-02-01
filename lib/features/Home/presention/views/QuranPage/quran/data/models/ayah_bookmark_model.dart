import 'dart:convert';
import 'package:flutter/material.dart';

class AyahBookmarkModel {
  final int surahNumber;
  final int verseNumber;
  final int colorValue;
  final DateTime timestamp;

  AyahBookmarkModel({
    required this.surahNumber,
    required this.verseNumber,
    required this.colorValue,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Unique ID for the bookmark (surah_verse)
  String get id => "${surahNumber}_$verseNumber";

  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {
      'surahNumber': surahNumber,
      'verseNumber': verseNumber,
      'colorValue': colorValue,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AyahBookmarkModel.fromMap(Map<String, dynamic> map) {
    return AyahBookmarkModel(
      surahNumber: map['surahNumber'] ?? 0,
      verseNumber: map['verseNumber'] ?? 0,
      colorValue: map['colorValue'] ?? 0xFFD4AF37,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AyahBookmarkModel.fromJson(String source) =>
      AyahBookmarkModel.fromMap(json.decode(source));

  AyahBookmarkModel copyWith({
    int? surahNumber,
    int? verseNumber,
    int? colorValue,
    DateTime? timestamp,
  }) {
    return AyahBookmarkModel(
      surahNumber: surahNumber ?? this.surahNumber,
      verseNumber: verseNumber ?? this.verseNumber,
      colorValue: colorValue ?? this.colorValue,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
