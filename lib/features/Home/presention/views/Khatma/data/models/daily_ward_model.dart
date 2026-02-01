class DailyWard {
  final int dayNumber;
  final DateTime date;
  final int startPage;
  final int endPage;
  final bool isCompleted;
  final bool isCurrentDay; // True if this ward corresponds to today
  final String startSurahName;
  final String endSurahName;
  final String status; // 'done', 'current', 'future', 'missed'
  final int pagesRead; // Pages read within this ward's range
  final bool isLocked;

  DailyWard({
    required this.dayNumber,
    required this.date,
    required this.startPage,
    required this.endPage,
    required this.isCompleted,
    required this.isCurrentDay,
    required this.startSurahName,
    required this.endSurahName,
    required this.status,
    this.pagesRead = 0,
    this.isLocked = false,
  });
}
