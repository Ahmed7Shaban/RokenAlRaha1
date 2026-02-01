import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/services/notification_service.dart';
import '../date/tasbeeh_list.dart';
import '../date/istighfar_list.dart';

part 'masbaha_state.dart';

class MasbahaCubit extends Cubit<MasbahaState> {
  MasbahaCubit() : super(MisbahaInitial());

  // --- Counter Logic ---
  Timer? _timer;
  Timer? _idleTimer;
  int _count = 0;
  int _seconds = 0;
  int _score = 0;
  List<Map<String, dynamic>> _customDhikrs = []; // Cache custom items

  // --- List & Custom Dhikr Logic ---

  Future<void> loadDhikrs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? customJson = prefs.getString('custom_dhikrs');

    List<Map<String, dynamic>> savedDhikrs = [];
    if (customJson != null) {
      try {
        savedDhikrs = List<Map<String, dynamic>>.from(json.decode(customJson));
      } catch (e) {
        debugPrint("Error loading custom dhikrs: $e");
      }
    }
    _customDhikrs = savedDhikrs;

    _emitListState();
  }

  Future<void> addCustomDhikr({
    required String text,
    required String type, // 'tasbeeh' or 'istighfar'
    TimeOfDay? notificationTime,
  }) async {
    final newItem = {
      'text': text,
      'type': type,
      'isCustom': true,
      'notificationTime': notificationTime != null
          ? "${notificationTime.hour}:${notificationTime.minute}"
          : null,
      // Fix: Ensure ID fits within 32-bit integer range (Max: 2147483647)
      'id': DateTime.now().millisecondsSinceEpoch % 2147483647,
    };

    _customDhikrs.add(newItem);
    await _saveCustomDhikrs();

    // Schedule Notification if time key exists
    if (notificationTime != null) {
      await NotificationService().scheduleDailyReminder(
        id: newItem['id'] as int,
        title: "تذكير بالورد اليومي",
        body: text,
        time: notificationTime,
        payload: 'masbaha_custom',
        isDaily: true,
      );
    }

    _emitListState();
  }

  Future<void> deleteCustomDhikr(String text) async {
    // 1. Find the item
    final index = _customDhikrs.indexWhere(
      (element) => element['text'] == text,
    );
    if (index == -1) return;

    final item = _customDhikrs[index];

    // 2. Remove from List and Update UI IMMEDIATELY
    // This prevents "Dismissible still part of tree" error
    // We remove it from the local list and emit state so the UI updates instantly
    _customDhikrs.removeAt(index);
    _emitListState();

    // 3. Perform Async Cleanup (Notification & Storage)
    if (item['id'] != null) {
      try {
        final int id = item['id'] as int;
        // Only attempt to cancel if ID is within valid 32-bit range
        if (id >= -2147483648 && id <= 2147483647) {
          await NotificationService().cancelNotification(id);
        } else {
          debugPrint("Skipping notification cancellation: Invalid ID $id");
        }
      } catch (e) {
        debugPrint("Error cancelling notification: $e");
      }
    }

    await _saveCustomDhikrs();
  }

  Future<void> _saveCustomDhikrs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_dhikrs', json.encode(_customDhikrs));
  }

  void _emitListState() {
    // Debug: Print custom dhikrs check
    debugPrint(
      "Broadcasting List State. Total Custom Dhikrs: ${_customDhikrs.length}",
    );

    // Filter Custom Items by Type
    final customTasbeeh = _customDhikrs
        .where((e) => e['type'] == 'tasbeeh')
        .map((e) => e['text'].toString())
        .toList();

    debugPrint("Custom Tasbeeh Count: ${customTasbeeh.length}");

    final customIstighfar = _customDhikrs
        .where((e) => e['type'] == 'istighfar')
        .map((e) => e['text'].toString())
        .toList();

    debugPrint("Custom Istighfar Count: ${customIstighfar.length}");

    // Merge: Custom items FIRST, then Static items
    emit(
      MasbahaListLoaded(
        tasbeehItems: [...customTasbeeh, ...tasbeehList],
        istighfarItems: [...customIstighfar, ...istighfarList],
        customItems: _customDhikrs,
      ),
    );
  }

  // --- Existing Counter Logic ---

  void increment() {
    _count++;
    _updateScore();
    _handleTimerActivity();
    _emitCounterState();
  }

  void decrement() {
    if (_count > 0) {
      _count--;
      _updateScore();
      _handleTimerActivity();
      _emitCounterState();
    }
  }

  void reset() {
    _count = 0;
    _seconds = 0;
    _score = 0;
    _timer?.cancel();
    _idleTimer?.cancel();
    _timer = null;
    _idleTimer = null;
    _emitCounterState();
  }

  void _updateScore() {
    // Score increases by 1 every 33 counts
    _score = _count ~/ 33;
  }

  void _handleTimerActivity() {
    // Reset idle timer
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 10), _pauseTimer);

    // Start main timer if not running
    if (_timer == null || !_timer!.isActive) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _seconds++;
      _emitCounterState();
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  void _emitCounterState() {
    emit(
      MisbahaUpdated(
        count: _count,
        seconds: _seconds,
        isMilestone: _count != 0 && _count % 33 == 0,
        score: _score,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _idleTimer?.cancel();
    return super.close();
  }
}
