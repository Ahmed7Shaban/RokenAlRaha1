import 'package:flutter/material.dart';

abstract class HamedState {}

class HamedInitial extends HamedState {}

class HamedLoading extends HamedState {}

class HamedLoaded extends HamedState {
  final List<String> blessings;
  final TimeOfDay? reminderTime;
  final Map<int, int> dhikrCounts; // index -> count
  final int totalPraises;

  HamedLoaded({
    this.blessings = const [],
    this.reminderTime,
    this.dhikrCounts = const {},
    this.totalPraises = 0,
  });

  HamedLoaded copyWith({
    List<String>? blessings,
    TimeOfDay? reminderTime,
    Map<int, int>? dhikrCounts,
    int? totalPraises,
  }) {
    return HamedLoaded(
      blessings: blessings ?? this.blessings,
      reminderTime: reminderTime ?? this.reminderTime,
      dhikrCounts: dhikrCounts ?? this.dhikrCounts,
      totalPraises: totalPraises ?? this.totalPraises,
    );
  }
}
