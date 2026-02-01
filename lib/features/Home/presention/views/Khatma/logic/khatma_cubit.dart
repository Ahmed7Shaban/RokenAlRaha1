import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:bloc/bloc.dart';
import 'package:quran/quran.dart' as quran;
import '../../../../../../../core/services/notification_service.dart';
import 'package:roken_al_raha/core/theme/app_colors.dart';
import '../data/models/khatma_model.dart';
import '../data/models/daily_ward_model.dart';
import '../data/repositories/khatma_repository.dart';
import 'khatma_state.dart';

class KhatmaStatus {
  final String message;
  final Color color;
  const KhatmaStatus(this.message, this.color);
}

class KhatmaCubit extends Cubit<KhatmaState> {
  final KhatmaRepository _repository;

  KhatmaCubit(this._repository) : super(KhatmaInitial());

  KhatmaStatus calculateKhatmaStatus(KhatmaModel khatma) {
    if (khatma.isCompleted) {
      return const KhatmaStatus("أتممت الختمة بنجاح 🎉", Colors.green);
    }

    // Calculate wards based on current date to identify today's goal
    final wards = _calculateWards(khatma);

    // Find today's ward
    final todayWard = wards.firstWhere(
      (w) => w.isCurrentDay,
      orElse: () => wards.isNotEmpty
          ? wards.last
          : DailyWard(
              dayNumber: 0,
              date: DateTime.now(),
              startPage: 0,
              endPage: 0,
              isCompleted: false,
              isCurrentDay: false,
              startSurahName: '',
              endSurahName: '',
              status: '',
              pagesRead: 0,
              isLocked: false,
            ),
    );

    if (todayWard.dayNumber == 0) {
      return const KhatmaStatus("لا توجد خطة نشطة", Colors.grey);
    }

    int lastRead = khatma.lastReadPage;
    // Total Pages Required up to Yesterday = Start of Today (Cumulative) - 1
    int requiredUpToYesterday = todayWard.startPage - 1;

    // Case 1: Delayed
    // If (Read < Required)
    if (lastRead < requiredUpToYesterday) {
      int delayedPages = requiredUpToYesterday - lastRead;
      return KhatmaStatus("متبقي $delayedPages صفحة لتلحق بجدولك", Colors.red);
    }

    // Case 4: Ahead
    // If (Read > Required + Today's Ward) => Read > todayWard.endPage
    if (lastRead > todayWard.endPage) {
      int aheadPages = lastRead - todayWard.endPage;
      return KhatmaStatus(
        "سابق لجدولك بـ $aheadPages صفحة",
        const Color(0xFF9C27B0), // Purple/Blue
      );
    }

    // Case 3: Goal Achieved
    // If (Today's Ward is finished) => Read >= todayWard.endPage
    // Note: Since 'Ahead' (> endPage) is checked above, this covers == endPage.
    if (lastRead >= todayWard.endPage) {
      return const KhatmaStatus("أتممت ورد اليوم بنجاح 🔥", Colors.green);
    }

    // Case 2: On Track
    // If (Read == Required) AND (Today's Ward not finished) -> implied by reaching here
    // Covers range: Required <= Read < EndPage
    return const KhatmaStatus("أنت على المسار الصحيح", AppColors.goldenYellow);
  }

  Future<void> loadKhatmas() async {
    emit(KhatmaLoading());
    try {
      final khatmas = await _repository.getKhatmas();

      // Calculate delay for each
      List<KhatmaModel> updatedKhatmas = [];
      for (var k in khatmas) {
        updatedKhatmas.add(_calculateDelay(k));
      }

      // Sort: Active first, then by date
      updatedKhatmas.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1; // Incomplete first
        }
        DateTime dateA = a.lastReadDate ?? a.startDate;
        DateTime dateB = b.lastReadDate ?? b.startDate;
        return dateB.compareTo(dateA);
      });

      KhatmaModel? active;
      if (updatedKhatmas.isNotEmpty) {
        active = updatedKhatmas.firstWhere(
          (element) => !element.isCompleted && !element.isArchived,
          orElse: () => updatedKhatmas.first,
        );
      }

      List<DailyWard> wards = [];
      if (active != null) {
        wards = _calculateWards(active);
      }

      final streak = await _repository.getStreak();
      final totalCompleted = await _repository
          .getTotalCompletedSaved(); // Use stored count as primary

      emit(
        KhatmaLoaded(
          khatmas: updatedKhatmas,
          activeKhatma: active,
          wards: wards,
          streak: streak,
          totalCompleted: totalCompleted,
        ),
      );

      // FIX: Ensure notifications are re-scheduled/refreshed on load
      // This protects against system clearing alarms or missing channels from previous bugs.
      if (active != null && active.remindersEnabled) {
        // We do this silently in background
        _scheduleKhatmaNotifications(active).catchError((e) {
          debugPrint("Error rescheduling khatma notifications: $e");
        });
      }
    } catch (e) {
      emit(KhatmaError("Failed to load Khatmas: $e"));
    }
  }

  KhatmaModel _calculateDelay(KhatmaModel k) {
    if (k.isCompleted) return k.copyWith(delayedPages: 0);

    final today = DateTime.now();
    final daysSinceStart = today.difference(k.startDate).inDays + 1;

    if (daysSinceStart <= 0) return k.copyWith(delayedPages: 0);
    if (daysSinceStart > k.durationDays) {
      // Should have finished
      return k.copyWith(delayedPages: k.endPage - k.lastReadPage);
    }

    // Expected progress
    int totalPages = k.endPage - k.startPage + 1;
    double pagesPerDay = totalPages / k.durationDays;
    int expectedPages = (pagesPerDay * daysSinceStart).ceil();
    int expectedPageNumber = k.startPage + expectedPages - 1;

    int delay = expectedPageNumber - k.lastReadPage;
    if (delay < 0) delay = 0;

    return k.copyWith(delayedPages: delay);
  }

  void setActiveKhatma(String id) {
    if (state is KhatmaLoaded) {
      final loaded = state as KhatmaLoaded;
      final index = loaded.khatmas.indexWhere((k) => k.id == id);
      if (index != -1) {
        final active = loaded.khatmas[index];
        final wards = _calculateWards(active);
        emit(loaded.copyWith(activeKhatma: active, wards: wards));
      }
    }
  }

  Future<void> createKhatma({
    required String name,
    required int durationDays,
    int startPage = 1,
    String type = 'fixed',
    bool isVerseBased = false,
    bool remindersEnabled = false,
    List<String> reminderTimes = const [],
    String? reminderDeadline,
  }) async {
    try {
      final newKhatma = KhatmaModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        durationDays: durationDays,
        startDate: DateTime.now(),
        startPage: startPage,
        endPage: 604,
        lastReadPage: startPage - 1,
        type: type,
        lastReadDate: DateTime.now(),
        isVerseBased: isVerseBased,
        totalVerses: 6236,
        lastReadVerse: 0,
        delayedPages: 0,
        remindersEnabled: remindersEnabled,
        reminderTimes: reminderTimes,
        reminderDeadline: reminderDeadline,
      );

      await _repository.saveKhatma(newKhatma);

      if (remindersEnabled) {
        await NotificationService().requestPermissions();
        await _scheduleKhatmaNotifications(newKhatma);
      }

      await loadKhatmas();
    } catch (e) {
      emit(KhatmaError("Failed to create Khatma: $e"));
    }
  }

  Future<void> _scheduleKhatmaNotifications(KhatmaModel khatma) async {
    if (!khatma.remindersEnabled) return;
    int baseId = khatma.id.hashCode & 0x7FFFFFFF;

    // Regular times
    for (int i = 0; i < khatma.reminderTimes.length; i++) {
      final timeStr = khatma.reminderTimes[i];
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final time = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
        await NotificationService().scheduleDailyReminder(
          id: baseId + 100 + i,
          title: "تذكير ورد القرآن: ${khatma.name}",
          body: "حان موعد قراءة وردك اليومي من القرآن الكريم.",
          time: time,
          payload: khatma.id,
          isDaily: true,
        );
      }
    }

    // Deadline
    if (khatma.reminderDeadline != null) {
      final parts = khatma.reminderDeadline!.split(':');
      if (parts.length == 2) {
        final time = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
        await NotificationService().scheduleDailyReminder(
          id: baseId + 999,
          title: "تنبيه: مهلة الورد اليومي",
          body: "تبقى قليل على نهاية اليوم، لا تنس وردك!",
          time: time,
          payload: khatma.id,
          isDaily: true,
        );
      }
    }
  }

  Future<void> _updateDeadlineNotification(
    KhatmaModel khatma,
    int pagesLeft,
  ) async {
    if (!khatma.remindersEnabled || khatma.reminderDeadline == null) return;
    int baseId = khatma.id.hashCode & 0x7FFFFFFF;

    final parts = khatma.reminderDeadline!.split(':');
    if (parts.length == 2) {
      final time = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      await NotificationService().scheduleDailyReminder(
        id: baseId + 999,
        title: "همسة: اقترب انتهاء اليوم",
        body: "باقي لك $pagesLeft صفحات لإنهاء ورد اليوم. استعن بالله!",
        time: time,
        payload: khatma.id,
        isDaily: true,
      );
    }
  }

  Future<void> _cancelTodayNotifications(KhatmaModel khatma) async {
    if (!khatma.remindersEnabled) return;
    int baseId = khatma.id.hashCode & 0x7FFFFFFF;

    // Cancel Deadline
    if (khatma.reminderDeadline != null) {
      await NotificationService().cancelNotification(baseId + 999);
    }

    // Cancel Regular Reminders
    for (int i = 0; i < khatma.reminderTimes.length; i++) {
      await NotificationService().cancelNotification(baseId + 100 + i);
    }
  }

  Future<void> _rescheduleForTomorrow(KhatmaModel khatma) async {
    if (!khatma.remindersEnabled) return;
    int baseId = khatma.id.hashCode & 0x7FFFFFFF;

    // Re-schedule Deadline for Tomorrow
    if (khatma.reminderDeadline != null) {
      final parts = khatma.reminderDeadline!.split(':');
      if (parts.length == 2) {
        final time = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
        await NotificationService().scheduleDailyReminder(
          id: baseId + 999,
          title: "تنبيه: مهلة الورد اليومي",
          body: "تبقى قليل على نهاية اليوم، لا تنس وردك!",
          time: time,
          payload: khatma.id,
          forceTomorrow: true,
          isDaily: true,
        );
      }
    }

    // Re-schedule Regular Reminders for Tomorrow
    for (int i = 0; i < khatma.reminderTimes.length; i++) {
      final timeStr = khatma.reminderTimes[i];
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final time = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
        await NotificationService().scheduleDailyReminder(
          id: baseId + 100 + i,
          title: "تذكير ورد القرآن: ${khatma.name}",
          body: "حان موعد قراءة وردك اليومي من القرآن الكريم.",
          time: time,
          payload: khatma.id,
          forceTomorrow: true,
          isDaily: true,
        );
      }
    }
  }

  Future<void> updateLastRead(String khatmaId, int lastReadPage) async {
    if (state is! KhatmaLoaded) return;
    final loaded = state as KhatmaLoaded;

    final index = loaded.khatmas.indexWhere((k) => k.id == khatmaId);
    if (index == -1) return;

    final oldKhatma = loaded.khatmas[index];

    // Check completion
    bool wasCompleted = oldKhatma.isCompleted;
    // Strict Completion: logic depends on pagesRead reaching the goal
    bool isCompleted = lastReadPage >= oldKhatma.endPage;

    // Update streak if page progressed
    if (lastReadPage > oldKhatma.lastReadPage) {
      await _repository.updateStreak(DateTime.now());
    }

    final updatedKhatma = _calculateDelay(
      oldKhatma.copyWith(
        lastReadPage: lastReadPage > oldKhatma.lastReadPage
            ? lastReadPage
            : oldKhatma.lastReadPage,
        isCompleted: isCompleted,
        lastReadDate: DateTime.now(),
      ),
    );

    // --- Smart Notification Update ---
    if (updatedKhatma.remindersEnabled) {
      final wards = _calculateWards(updatedKhatma);
      final todayWard = wards.firstWhere(
        (w) => w.isCurrentDay,
        orElse: () => wards.first,
      );

      // We only trigger "Success" if it WAS NOT completed before, and IS completed now.
      // But updateLastRead might be called multiple times.
      // We should check if we already handled this today?
      // Since local notifications are stateless, we can just re-run logic.
      // If we trigger "Success" every time they update progress while done, it might spam.
      // Ideally, we compare 'oldKhatma' status for today vs 'updatedKhatma'.

      // Check if previously done
      final oldWards = _calculateWards(oldKhatma);
      final oldToday = oldWards.firstWhere(
        (w) => w.isCurrentDay,
        orElse: () => oldWards.first,
      );

      bool justFinished = !oldToday.isCompleted && todayWard.isCompleted;

      // logic update for strict checking
      // The requirement: "Notification MUST ONLY trigger when the 'pagesRead' exactly equals 'totalPages' for the current active Ward."
      bool isStrictlyFinishedActiveWard = lastReadPage == todayWard.endPage;

      if (todayWard.isCompleted && isStrictlyFinishedActiveWard) {
        // We only notify if we just reached this state or if we haven't notified today (simplified by justFinished for now)
        // However, 'justFinished' is comparing old vs new isCompleted state.

        // If we strictly just landed on the exact equal page, we trigger.
        if (justFinished) {
          // 1. Cancel Reminders & Deadline
          await _cancelTodayNotifications(updatedKhatma);

          // 2. Show Success
          await NotificationService().showInstantNotification(
            id: (updatedKhatma.id.hashCode & 0x7FFFFFFF) + 888,
            title: "ختمة مباركة 🌙",
            body:
                "ما شاء الله، اكتمل ورد اليوم.. هنيئاً لك ما قرأت وتقبل الله طاعتك.",
          );

          // 3. Re-schedule for tomorrow
          // We explicitly schedule for tomorrow to ensure today is skipped.
          await _rescheduleForTomorrow(updatedKhatma);
        }
      } else {
        // Update deadline message
        int remaining = todayWard.endPage - lastReadPage;
        if (remaining > 0) {
          await _updateDeadlineNotification(updatedKhatma, remaining);
        }
      }
    }
    // --------------------------------

    // Update Total Completed if just finished
    if (!wasCompleted && isCompleted) {
      await _repository.incrementTotalCompleted();
    }

    await _repository.saveKhatma(updatedKhatma);

    // Refresh stats
    final streak = await _repository.getStreak();
    final totalCompleted = await _repository.getTotalCompletedSaved();

    List<KhatmaModel> newKhatmas = List.from(loaded.khatmas);
    newKhatmas[index] = updatedKhatma;

    KhatmaModel? newActive = loaded.activeKhatma?.id == khatmaId
        ? updatedKhatma
        : loaded.activeKhatma;

    List<DailyWard> newWards = loaded.wards;
    if (newActive != null && newActive.id == khatmaId) {
      newWards = _calculateWards(updatedKhatma);
    }

    emit(
      loaded.copyWith(
        khatmas: newKhatmas,
        activeKhatma: newActive,
        wards: newWards,
        streak: streak,
        totalCompleted: totalCompleted,
      ),
    );
  }

  Future<void> redistributeKhatma(String khatmaId) async {
    if (state is! KhatmaLoaded) return;
    final loaded = state as KhatmaLoaded;
    final index = loaded.khatmas.indexWhere((k) => k.id == khatmaId);
    if (index == -1) return;
    final khatma = loaded.khatmas[index];

    final originalEndDate = khatma.startDate.add(
      Duration(days: khatma.durationDays),
    );
    final now = DateTime.now();

    int remainingPages = khatma.endPage - khatma.lastReadPage;
    if (remainingPages <= 0) return;

    int remainingDays = originalEndDate.difference(now).inDays;
    if (remainingDays <= 0) remainingDays = 1;

    final updatedKhatma = khatma.copyWith(
      startDate: now,
      startPage: khatma.lastReadPage + 1,
      durationDays: remainingDays,
      type: 'redistributed',
      delayedPages: 0, // Reset delay
    );

    await _repository.saveKhatma(updatedKhatma);
    await loadKhatmas();
  }

  Future<void> deleteKhatma(String id) async {
    if (state is KhatmaLoaded) {
      final loaded = state as KhatmaLoaded;
      final k = loaded.khatmas.firstWhere(
        (element) => element.id == id,
        orElse: () => loaded.khatmas.first,
      );
      // If found (check if it's actually the one), cancel logic
      if (k.id == id && k.remindersEnabled) {
        int baseId = k.id.hashCode & 0x7FFFFFFF;
        // Cancel Deadline
        if (k.reminderDeadline != null) {
          await NotificationService().cancelNotification(baseId + 999);
        }
        // Cancel Regular Reminders
        for (int i = 0; i < k.reminderTimes.length; i++) {
          await NotificationService().cancelNotification(baseId + 100 + i);
        }
      }
    }

    await _repository.deleteKhatma(id);
    await loadKhatmas();
  }

  List<DailyWard> _calculateWards(KhatmaModel khatma) {
    List<DailyWard> wards = [];
    int totalPages = khatma.endPage - khatma.startPage + 1;
    if (totalPages <= 0) return [];

    int currentStart = khatma.startPage;
    int pagesRemaining = totalPages;
    DateTime dateIterator = khatma.startDate;

    for (int day = 0; day < khatma.durationDays; day++) {
      int daysRemaining = khatma.durationDays - day;
      int pagesForToday = (pagesRemaining / daysRemaining).ceil();

      int currentEnd = currentStart + pagesForToday - 1;
      if (currentEnd > khatma.endPage) currentEnd = khatma.endPage;

      String startSurah = _getSurahNameForPage(currentStart);
      String endSurah = _getSurahNameForPage(currentEnd);

      bool isCompleted = khatma.lastReadPage >= currentEnd;
      bool isCurrentDay = _isSameDay(dateIterator, DateTime.now());

      String status = 'future';
      if (isCompleted) {
        status = 'done';
      } else {
        if (dateIterator.isBefore(_today())) {
          status = 'missed';
        } else if (isCurrentDay) {
          status = 'current';
        }
      }

      // Locking Logic
      // Lock if previous ward exists and is NOT completed
      bool isLocked = false;
      if (wards.isNotEmpty) {
        // Previous is the last one added
        // "User should NOT be able to tap or open any future Ward until the current Ward is completed"
        // If day > 0 (not first ward), check if day-1 is completed
        if (!wards.last.isCompleted) {
          isLocked = true;
        }
      }

      wards.add(
        DailyWard(
          dayNumber: day + 1,
          date: dateIterator,
          startPage: currentStart,
          endPage: currentEnd,
          isCompleted: isCompleted,
          isCurrentDay: isCurrentDay,
          startSurahName: startSurah,
          endSurahName: endSurah,
          status: status,
          pagesRead: _calculatePagesReadInWard(
            khatma.lastReadPage,
            currentStart,
            currentEnd,
          ),
          isLocked: isLocked,
        ),
      );

      currentStart = currentEnd + 1;
      pagesRemaining -= pagesForToday;
      dateIterator = dateIterator.add(const Duration(days: 1));

      if (pagesRemaining <= 0 && day < khatma.durationDays - 1) {
        break;
      }
    }

    return wards;
  }

  int _calculatePagesReadInWard(int lastReadPage, int start, int end) {
    if (lastReadPage < start) return 0;
    if (lastReadPage >= end) return (end - start + 1);
    return lastReadPage - start + 1;
  }

  String _getSurahNameForPage(int page) {
    if (page < 1 || page > 604) return "";
    try {
      var pageData = quran.getPageData(page);
      if (pageData.isNotEmpty) {
        int surahNum = pageData[0]['surah'];
        return quran.getSurahNameArabic(surahNum);
      }
    } catch (e) {
      return "";
    }
    return "";
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
