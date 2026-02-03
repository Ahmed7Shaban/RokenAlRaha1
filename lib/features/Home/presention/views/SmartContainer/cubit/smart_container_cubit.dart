import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../source/app_images.dart';
import '../../../../../../core/services/notification_service.dart';
import '../../../../../FajrAlarm/services/fajr_alarm_service.dart';

part 'smart_container_state.dart';

class SmartContainerCubit extends Cubit<SmartContainerState> {
  Timer? _timer;
  Coordinates? _userCoordinates;
  final NotificationService _notificationService = NotificationService();

  SmartContainerCubit()
    : super(
        SmartContainerState(
          currentTime: DateTime.now(),
          hijriDate: HijriCalendar.now(),
          currentBackground: Assets.morning,
          timeUntilNextPrayer: Duration.zero,
          eventCountdowns: {},
          locationName: "جاري تحديد الموقع...",
        ),
      ) {
    _init();
  }

  void _init() async {
    HijriCalendar.setLocal('ar');
    emit(state.copyWith(isLoading: true));

    // Init Service
    await _notificationService.init();

    await _loadSettings();
    await _loadPrayerStats();
    await _determinePositionAndAddress();

    // Permission Request
    if (state.isAzanEnabled) {
      await _notificationService.requestPermissions();
    }

    _calculatePrayerTimes();
    _startTimer();
    _updateState();
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isAzanEnabled = prefs.getBool('isAzanEnabled') ?? true;
    final selectedMoazzen = prefs.getString('selectedMoazzen') ?? 'mohamd_gazy';

    // Load Fajr Alarm Status
    final settings = await FajrAlarmService().getSettings();
    final isFajrAlarmEnabled = settings['enabled'] ?? false;

    emit(
      state.copyWith(
        isAzanEnabled: isAzanEnabled,
        selectedMoazzen: selectedMoazzen,
        isFajrAlarmEnabled: isFajrAlarmEnabled,
      ),
    );
  }

  Future<void> toggleAzan(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAzanEnabled', value);
    emit(state.copyWith(isAzanEnabled: value));

    if (value) {
      if (state.prayerTimes != null) {
        await _notificationService.requestPermissions();
        await _notificationService.scheduleDailyAzan(
          state.prayerTimes!,
          state.selectedMoazzen,
        );
      }
    } else {
      await _notificationService.cancelAzanNotifications();
    }
  }

  Future<void> setMoazzen(String moazzen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedMoazzen', moazzen);
    emit(state.copyWith(selectedMoazzen: moazzen));

    if (state.isAzanEnabled && state.prayerTimes != null) {
      await _notificationService.scheduleDailyAzan(state.prayerTimes!, moazzen);
    }
  }

  Future<void> _determinePositionAndAddress() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check Service
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _useDefaultLocation("القاهرة (افتراضي)");
        return;
      }

      // Check Permission
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _useDefaultLocation("القاهرة (افتراضي)");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _useDefaultLocation("القاهرة (افتراضي)");
        return;
      }

      // Get Position
      Position position = await Geolocator.getCurrentPosition();
      _userCoordinates = Coordinates(position.latitude, position.longitude);

      // Get Address
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String city = place.locality ?? place.subAdministrativeArea ?? "";
          String country = place.country ?? "";
          // Simple cleanup
          String locName = "$city، $country";
          if (city.isEmpty) locName = country;

          emit(state.copyWith(locationName: locName));
        } else {
          emit(state.copyWith(locationName: "موقع غير معروف"));
        }
      } catch (e) {
        // Geocoding failed, but we have coordinates
        emit(state.copyWith(locationName: "موقعي الحالي"));
      }
    } catch (e) {
      _useDefaultLocation("القاهرة (افتراضي)");
    }
  }

  void _useDefaultLocation(String label) {
    // Cairo Coordinates
    _userCoordinates = Coordinates(30.0444, 31.2357);
    emit(state.copyWith(locationName: label));
  }

  void _calculatePrayerTimes() {
    if (_userCoordinates == null) return;

    final params = CalculationMethod.egyptian.getParameters();
    params.madhab = Madhab.shafi;

    final date = DateComponents.from(DateTime.now());
    final prayerTimes = PrayerTimes(_userCoordinates!, date, params);

    emit(state.copyWith(prayerTimes: prayerTimes));

    if (state.isAzanEnabled) {
      _notificationService.scheduleDailyAzan(
        prayerTimes,
        state.selectedMoazzen,
      );
    }

    // Also schedule prayer check reminders
    _schedulePrayerReminders(prayerTimes);

    // --- Schedule Smart Fajr Alarm ---
    // 1. Try Today's Fajr
    FajrAlarmService().scheduleAlarm(prayerTimes.fajr);

    // 2. Schedule Tomorrow's Fajr (to ensure continuity)
    final tomorrowDate = DateComponents.from(
      DateTime.now().add(const Duration(days: 1)),
    );
    final tomorrowPrayerTimes = PrayerTimes(
      _userCoordinates!,
      tomorrowDate,
      params,
    );
    FajrAlarmService().scheduleAlarm(tomorrowPrayerTimes.fajr);
  }

  void refreshFajrAlarm() async {
    // Reload state (enabled/disabled)
    final settings = await FajrAlarmService().getSettings();
    final isFajrAlarmEnabled = settings['enabled'] ?? false;
    emit(state.copyWith(isFajrAlarmEnabled: isFajrAlarmEnabled));

    _calculatePrayerTimes();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateState();
    });
  }

  void _updateState() {
    final now = DateTime.now();
    final hijri = HijriCalendar.now();

    Prayer? nextPrayer;
    Duration timeUntil = Duration.zero;

    if (state.prayerTimes != null) {
      nextPrayer = state.prayerTimes!.nextPrayer();

      // If none, it means next prayer is tomorrow's Fajr
      if (nextPrayer == Prayer.none) {
        // Create tomorrow's prayer times
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final date = DateComponents.from(tomorrow);
        final params = CalculationMethod.egyptian.getParameters();

        if (_userCoordinates != null) {
          final nextDayPrayerTimes = PrayerTimes(
            _userCoordinates!,
            date,
            params,
          );
          nextPrayer = Prayer.fajr;
          final nextTime = nextDayPrayerTimes.fajr;
          timeUntil = nextTime.difference(now);
        }
      } else {
        final nextPrayerTime = state.prayerTimes!.timeForPrayer(nextPrayer);
        if (nextPrayerTime != null) {
          timeUntil = nextPrayerTime.difference(now);
        }
      }
    }

    // Determine Background
    String background = _calculateBackground(now, hijri);

    // Calculate Countdowns
    Map<String, int> countdowns = _calculateCountdowns(hijri);

    emit(
      state.copyWith(
        currentTime: now,
        hijriDate: hijri,
        nextPrayer: nextPrayer,
        timeUntilNextPrayer: timeUntil,
        currentBackground: background,
        eventCountdowns: countdowns,
      ),
    );
  }

  String _calculateBackground(DateTime now, HijriCalendar hijri) {
    // Priority 1: Occasions
    if (hijri.hMonth == 9) {
      return Assets.ramadan;
    }
    if (hijri.hMonth == 12 && hijri.hDay >= 1 && hijri.hDay <= 13) {
      return Assets.hajj;
    }

    // Priority 2: Time of Day
    final hour = now.hour;
    if (hour >= 5 && hour < 12) {
      return Assets.morning;
    } else if (hour >= 12 && hour < 17) {
      return Assets.morning;
    } else if (hour >= 17 && hour < 20) {
      return Assets.sunset;
    } else {
      return Assets.night;
    }
  }

  Map<String, int> _calculateCountdowns(HijriCalendar hijri) {
    // 1. Ramadan (Month 9)
    int daysToRamadan = 0;
    if (hijri.hMonth < 9) {
      daysToRamadan = ((9 - hijri.hMonth) * 29.5).round() - hijri.hDay;
    } else if (hijri.hMonth == 9) {
      daysToRamadan = 0;
    } else {
      daysToRamadan = ((12 - hijri.hMonth + 9) * 29.5).round() - hijri.hDay;
    }

    // 2. Eid Al-Fitr (Month 10, Day 1)
    int daysToEidFitr = 0;
    if (hijri.hMonth < 10) {
      daysToEidFitr = ((10 - hijri.hMonth) * 29.5).round() - hijri.hDay;
    } else if (hijri.hMonth == 10 && hijri.hDay == 1) {
      daysToEidFitr = 0;
    } else {
      daysToEidFitr = ((12 - hijri.hMonth + 10) * 29.5).round() - hijri.hDay;
    }

    // 3. Eid Al-Adha (Month 12, Day 10)
    int daysToEidAdha = 0;
    if (hijri.hMonth < 12) {
      daysToEidAdha = ((12 - hijri.hMonth) * 29.5).round() + (10 - hijri.hDay);
    } else if (hijri.hMonth == 12 && hijri.hDay < 10) {
      daysToEidAdha = 10 - hijri.hDay;
    } else if (hijri.hMonth == 12 && hijri.hDay == 10) {
      daysToEidAdha = 0;
    } else {
      daysToEidAdha =
          ((12 - hijri.hMonth + 12) * 29.5 + 10).round() - hijri.hDay;
    }

    // 4. Mawlid Al-Nabi (Month 3, Day 12)
    int daysToMawlid = 0;
    if (hijri.hMonth < 3) {
      daysToMawlid = ((3 - hijri.hMonth) * 29.5).round() + (12 - hijri.hDay);
    } else if (hijri.hMonth == 3 && hijri.hDay < 12) {
      daysToMawlid = 12 - hijri.hDay;
    } else if (hijri.hMonth == 3 && hijri.hDay == 12) {
      daysToMawlid = 0;
    } else {
      daysToMawlid = ((12 - hijri.hMonth + 3) * 29.5 + 12).round() - hijri.hDay;
    }

    return {
      'Ramadan': daysToRamadan,
      'Eid Al-Fitr': daysToEidFitr,
      'Eid Al-Adha': daysToEidAdha,
      'Mawlid Al-Nabi': daysToMawlid,
    };
  }

  // --- Prayer Tracking Logic ---

  Future<void> _loadPrayerStats() async {
    final prefs = await SharedPreferences.getInstance();
    final bool reminderEnabled =
        prefs.getBool('isPrayerReminderEnabled') ?? true;
    final int delay = prefs.getInt('prayerReminderDelay') ?? 10;

    // Load Completed Prayers: Map<String, List<String>> -> e.g., "2024-05-20": ["Fajr", "Dhuhr"]
    // Saved as JSON string or multiple keys? JSON is better.
    // Simplifying for SharedPreferences: Using a prefix like "prayer_completed_{date}" logic
    // or just loading the current week's data if possible.
    // For MVP/simple persistence, let's load current state.

    // Actually, let's use a simpler loading for state. We need a Map for the UI dashboard.
    // We will load current week's data.
    Map<String, List<String>> stats = {};
    final now = DateTime.now();
    // Load last 7 days
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = "${date.year}-${date.month}-${date.day}";
      final List<String> prayers =
          prefs.getStringList('prayer_completed_$dateKey') ?? [];
      stats[dateKey] = prayers;
    }

    emit(
      state.copyWith(
        isPrayerReminderEnabled: reminderEnabled,
        prayerReminderDelay: delay,
        completedPrayers: stats,
      ),
    );
  }

  Future<void> togglePrayerReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPrayerReminderEnabled', value);
    emit(state.copyWith(isPrayerReminderEnabled: value));

    // Reschedule
    if (state.prayerTimes != null) {
      _schedulePrayerReminders(state.prayerTimes!);
    }
  }

  Future<void> setPrayerReminderDelay(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('prayerReminderDelay', minutes);
    emit(state.copyWith(prayerReminderDelay: minutes));

    // Reschedule
    if (state.prayerTimes != null) {
      _schedulePrayerReminders(state.prayerTimes!);
    }
  }

  Future<void> togglePrayerStatus(String prayerName, bool isCompleted) async {
    final now = DateTime.now();
    final dateKey = "${now.year}-${now.month}-${now.day}";

    final currentMap = Map<String, List<String>>.from(state.completedPrayers);
    final currentList = List<String>.from(currentMap[dateKey] ?? []);

    if (isCompleted) {
      if (!currentList.contains(prayerName)) {
        currentList.add(prayerName);
      }
    } else {
      currentList.remove(prayerName);
    }

    currentMap[dateKey] = currentList;

    // Save
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('prayer_completed_$dateKey', currentList);

    emit(state.copyWith(completedPrayers: currentMap));
  }

  void _schedulePrayerReminders(PrayerTimes times) {
    if (!state.isPrayerReminderEnabled) {
      _notificationService.cancelPrayerCheckReminders();
      return;
    }

    // Schedule checkups
    _notificationService.schedulePrayerCheckReminders(
      times,
      state.prayerReminderDelay,
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
