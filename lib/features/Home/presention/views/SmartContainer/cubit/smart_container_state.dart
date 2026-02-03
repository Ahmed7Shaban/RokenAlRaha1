part of 'smart_container_cubit.dart';

class SmartContainerState extends Equatable {
  final DateTime currentTime;
  final HijriCalendar hijriDate;
  final PrayerTimes? prayerTimes;
  final Prayer? nextPrayer;
  final String currentBackground;
  final Duration timeUntilNextPrayer;
  final Map<String, int> eventCountdowns;
  final bool isAzanEnabled;
  final String selectedMoazzen;
  final String locationName;
  final bool isLoading;
  final bool isPrayerReminderEnabled;
  final int prayerReminderDelay;
  final Map<String, List<String>> completedPrayers;
  final bool isFajrAlarmEnabled;

  const SmartContainerState({
    required this.currentTime,
    required this.hijriDate,
    this.prayerTimes,
    this.nextPrayer,
    required this.currentBackground,
    required this.timeUntilNextPrayer,
    required this.eventCountdowns,
    this.isAzanEnabled = true,
    this.selectedMoazzen = 'Mishary Rashid',
    this.locationName = 'Determining Location...',
    this.isLoading = false,
    this.isPrayerReminderEnabled = false,
    this.prayerReminderDelay = 10,
    this.completedPrayers = const {},
    this.isFajrAlarmEnabled = false,
  });

  SmartContainerState copyWith({
    DateTime? currentTime,
    HijriCalendar? hijriDate,
    PrayerTimes? prayerTimes,
    Prayer? nextPrayer,
    String? currentBackground,
    Duration? timeUntilNextPrayer,
    Map<String, int>? eventCountdowns,
    bool? isAzanEnabled,
    String? selectedMoazzen,
    String? locationName,
    bool? isLoading,
    bool? isPrayerReminderEnabled,
    int? prayerReminderDelay,
    Map<String, List<String>>? completedPrayers,
    bool? isFajrAlarmEnabled,
  }) {
    return SmartContainerState(
      currentTime: currentTime ?? this.currentTime,
      hijriDate: hijriDate ?? this.hijriDate,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      currentBackground: currentBackground ?? this.currentBackground,
      timeUntilNextPrayer: timeUntilNextPrayer ?? this.timeUntilNextPrayer,
      eventCountdowns: eventCountdowns ?? this.eventCountdowns,
      isAzanEnabled: isAzanEnabled ?? this.isAzanEnabled,
      selectedMoazzen: selectedMoazzen ?? this.selectedMoazzen,
      locationName: locationName ?? this.locationName,
      isLoading: isLoading ?? this.isLoading,
      isPrayerReminderEnabled:
          isPrayerReminderEnabled ?? this.isPrayerReminderEnabled,
      prayerReminderDelay: prayerReminderDelay ?? this.prayerReminderDelay,
      completedPrayers: completedPrayers ?? this.completedPrayers,
      isFajrAlarmEnabled: isFajrAlarmEnabled ?? this.isFajrAlarmEnabled,
    );
  }

  @override
  List<Object?> get props => [
    currentTime,
    hijriDate,
    prayerTimes,
    nextPrayer,
    currentBackground,
    timeUntilNextPrayer,
    eventCountdowns,
    isAzanEnabled,
    selectedMoazzen,
    locationName,
    isLoading,
    isPrayerReminderEnabled,
    prayerReminderDelay,
    completedPrayers,
    isFajrAlarmEnabled,
  ];
}
