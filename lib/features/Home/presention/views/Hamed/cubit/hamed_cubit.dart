import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/services/notification_service.dart';
import 'hamed_state.dart';

class HamedCubit extends Cubit<HamedState> {
  HamedCubit() : super(HamedInitial());

  static const String _blessingsKey = 'hamed_blessings_list';
  static const String _reminderTimeKey = 'hamed_reminder_time';
  static const String _countsKey = 'hamed_dhikr_counts';
  static const String _totalPraisesKey = 'hamed_total_praises';

  Future<void> loadData() async {
    emit(HamedLoading());
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Blessings
      final List<String> blessings = prefs.getStringList(_blessingsKey) ?? [];

      // Load Reminder Time
      TimeOfDay? reminderTime;
      final String? timeStr = prefs.getString(_reminderTimeKey);
      if (timeStr != null) {
        final parts = timeStr.split(':');
        reminderTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }

      // Load Counts
      Map<int, int> dhikrCounts = {};
      final String? countsJson = prefs.getString(_countsKey);
      if (countsJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(countsJson);
        decoded.forEach((key, value) {
          dhikrCounts[int.parse(key)] = value as int;
        });
      }

      // Load Total
      final int totalPraises = prefs.getInt(_totalPraisesKey) ?? 0;

      emit(
        HamedLoaded(
          blessings: blessings,
          reminderTime: reminderTime,
          dhikrCounts: dhikrCounts,
          totalPraises: totalPraises,
        ),
      );
    } catch (e) {
      debugPrint("Error loading Hamed data: $e");
      emit(HamedLoaded()); // Fallback
    }
  }

  Future<void> addBlessing(String blessing) async {
    if (state is HamedLoaded) {
      final currentState = state as HamedLoaded;
      final updatedList = List<String>.from(currentState.blessings)
        ..insert(0, blessing); // Add to top

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_blessingsKey, updatedList);

      emit(currentState.copyWith(blessings: updatedList));
    }
  }

  Future<void> deleteBlessing(int index) async {
    if (state is HamedLoaded) {
      final currentState = state as HamedLoaded;
      final updatedList = List<String>.from(currentState.blessings);
      if (index >= 0 && index < updatedList.length) {
        updatedList.removeAt(index);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_blessingsKey, updatedList);

        emit(currentState.copyWith(blessings: updatedList));
      }
    }
  }

  Future<void> incrementDhikr(int index) async {
    if (state is HamedLoaded) {
      final currentState = state as HamedLoaded;
      final newCounts = Map<int, int>.from(currentState.dhikrCounts);

      final currentCount = newCounts[index] ?? 0;
      newCounts[index] = currentCount + 1;

      final newTotal = currentState.totalPraises + 1;

      // Save
      final prefs = await SharedPreferences.getInstance();
      // Convert integer keys to string keys for JSON
      final Map<String, int> jsonMap = {};
      newCounts.forEach((key, value) => jsonMap[key.toString()] = value);

      await prefs.setString(_countsKey, jsonEncode(jsonMap));
      await prefs.setInt(_totalPraisesKey, newTotal);

      emit(
        currentState.copyWith(dhikrCounts: newCounts, totalPraises: newTotal),
      );
    }
  }

  Future<void> setReminderTime(TimeOfDay? time) async {
    if (state is HamedLoaded) {
      final currentState = state as HamedLoaded;

      final prefs = await SharedPreferences.getInstance();

      if (time == null) {
        await prefs.remove(_reminderTimeKey);
        // Disable notification
        await NotificationService().scheduleHamedReminder(
          time: const TimeOfDay(hour: 0, minute: 0),
          isEnabled: false,
        );
      } else {
        await prefs.setString(_reminderTimeKey, "${time.hour}:${time.minute}");
        // Schedule
        await NotificationService().scheduleHamedReminder(
          time: time,
          isEnabled: true,
        );
      }

      emit(currentState.copyWith(reminderTime: time));
    }
  }
}
