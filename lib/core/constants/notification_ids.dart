class NotificationIds {
  // Prevent instantiation
  NotificationIds._();

  // --- Prayer Notifications (1-100) ---
  static const int fajr = 1;
  static const int sunrise = 2;
  static const int dhuhr = 3;
  static const int asr = 4;
  static const int maghrib = 5;
  static const int isha = 6;

  // --- Prayer Check Reminders (200-299) ---
  static const int prayerCheckBase = 500;
  // Ranges: 200 (Fajr) to 204 (Isha)

  // --- Hamed / Gratitude (300) ---
  static const int hamedReminder = 300;

  // --- Hadith (400-499) ---
  // Static daily notification
  static const int hadithDaily = 400;
  // Batch/Scheduled range start (e.g., 400000+) to allow large space?
  // Or just 1400? Let's keep them distinct.
  // The service uses ID * 1000. So if ID is 400, batch is 400000+. Safe.

  // --- Azkar (1000-1999) ---
  static const int morningAzkar = 1000;
  static const int eveningAzkar = 1100;
  static const int wakeUpAzkar = 1200;
  static const int sleepAzkar = 1300;

  // --- Masbaha (800-899) ---
  static const int tasbeehBase = 800; // 800-806 (7 days)
  static const int istighfarBase = 810; // 810-816 (7 days)

  // --- Custom User Reminders (10000+) ---
  static const int customBase = 10000;

  // --- Salat On Prophet (900-999) ---
  static const int salatOnProphetBase = 900;
}
