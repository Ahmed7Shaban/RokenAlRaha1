import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/services/notification_service.dart';
import '../data/fajr_question_model.dart';

class FajrAlarmService {
  static final FajrAlarmService _instance = FajrAlarmService._internal();
  factory FajrAlarmService() => _instance;
  FajrAlarmService._internal();

  static const String _prefEnabled = 'fajr_alarm_enabled';
  static const String _prefOffset = 'fajr_alarm_offset';

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  // --- Settings ---
  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool(_prefEnabled) ?? false,
      'offset': prefs.getInt(_prefOffset) ?? 20,
    };
  }

  Future<void> saveSettings({
    required bool enabled,
    required int offset,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabled, enabled);
    await prefs.setInt(_prefOffset, offset);
  }

  // --- Questions ---
  Future<List<FajrQuestion>> getQuestions(int count) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/fajr_smart_alarm_questions.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final questions = jsonList.map((j) => FajrQuestion.fromJson(j)).toList();

      if (questions.isEmpty) return [_getFallbackQuestion()];

      questions.shuffle();
      return questions.take(count).toList();
    } catch (e) {
      debugPrint("Error loading questions: $e");
      return [_getFallbackQuestion()];
    }
  }

  Future<FajrQuestion> getRandomQuestion() async {
    final questions = await getQuestions(1);
    return questions.first;
  }

  FajrQuestion _getFallbackQuestion() {
    return FajrQuestion(
      question: "كم عدد ركعات صلاة الفجر؟",
      answers: ["ركعتان", "ثلاث ركعات", "أربع ركعات"],
      correct: 0,
    );
  }

  // --- Audio ---
  Future<void> startAlarmSound() async {
    if (_isPlaying) return;
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // Try asking for the asset. If it fails, silent fail is better than crash.
      // We assume user has the asset or raw. AudioPlayers 'AssetSource' looks in assets/.
      // If user put it in 'raw', we might not reach it.
      // We'll use a standard asset path.

      // Attempt to play
      await _audioPlayer.play(AssetSource('Sounds/alarm.mp3'));
    } catch (e) {
      debugPrint("Audio Error: $e");
    }
    _isPlaying = true;
  }

  Future<void> stopAlarmSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {}
    _isPlaying = false;
  }

  // --- Scheduling ---
  Future<void> scheduleAlarm(DateTime fajrTime, {int dayOffset = 0}) async {
    final settings = await getSettings();
    final int alarmId = 10001 + dayOffset;

    if (!settings['enabled']) {
      await NotificationService().plugin.cancel(alarmId);
      return;
    }

    final int offset = settings['offset'];
    final DateTime alarmTime = fajrTime.subtract(Duration(minutes: offset));

    // Ensure we don't schedule in the past
    if (alarmTime.isBefore(DateTime.now())) {
      return;
    }

    // Schedule High Priority Notification via Service
    await NotificationService().scheduleFajrAlarm(
      id: alarmId,
      alarmTime: alarmTime,
      title: 'استيقظ لصلاة الفجر',
      body: 'حان موعد التحدي! أثبت استيقاظك 🕌',
      payload: 'fajr_alarm',
    );

    debugPrint("✅ Fajr Alarm Scheduled (ID: $alarmId) for $alarmTime");
  }

  Future<void> scheduleTestAlarm() async {
    final DateTime alarmTime = DateTime.now().add(const Duration(seconds: 10));

    await NotificationService().scheduleFajrAlarm(
      id: 9999, // Unique test ID
      alarmTime: alarmTime,
      title: 'تـجـربـة منبــه الفجــر',
      body: 'هذا اختبار للمنبه.. أجب عن الأسئلة لإيقافه! 🕌',
      payload: 'fajr_alarm',
    );

    debugPrint("✅ Test Alarm Scheduled for $alarmTime");
  }
}
