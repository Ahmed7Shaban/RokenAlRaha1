class KhatmaModel {
  final String id;
  final String name; // e.g. "Ramadan Khatma"
  final int durationDays;
  final DateTime startDate;
  final int startPage; // Usually 1
  final int endPage;
  final int lastReadPage;
  final bool isCompleted;
  final bool isArchived;

  // Restored fields
  final DateTime? lastReadDate;
  final String type; // 'fixed', 'continuous', 'special'

  // Verse Based Calculation
  final bool isVerseBased;
  final int totalVerses; // 6236
  final int lastReadVerse;

  // Delay Metrics
  final int delayedPages;

  // Notifications
  final bool remindersEnabled;
  final List<String> reminderTimes; // Format "HH:mm"
  final String? reminderDeadline; // Format "HH:mm"

  KhatmaModel({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.startDate,
    this.startPage = 1,
    this.endPage = 604,
    this.lastReadPage = 0,
    this.isCompleted = false,
    this.isArchived = false,
    this.lastReadDate,
    this.type = 'fixed',
    this.isVerseBased = false,
    this.totalVerses = 6236,
    this.lastReadVerse = 0,
    this.delayedPages = 0,
    this.remindersEnabled = false,
    this.reminderTimes = const [],
    this.reminderDeadline,
  });

  KhatmaModel copyWith({
    String? id,
    String? name,
    int? durationDays,
    DateTime? startDate,
    int? startPage,
    int? endPage,
    int? lastReadPage,
    bool? isCompleted,
    bool? isArchived,
    DateTime? lastReadDate,
    String? type,
    bool? isVerseBased,
    int? totalVerses,
    int? lastReadVerse,
    int? delayedPages,
    bool? remindersEnabled,
    List<String>? reminderTimes,
    String? reminderDeadline,
  }) {
    return KhatmaModel(
      id: id ?? this.id,
      name: name ?? this.name,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      startPage: startPage ?? this.startPage,
      endPage: endPage ?? this.endPage,
      lastReadPage: lastReadPage ?? this.lastReadPage,
      isCompleted: isCompleted ?? this.isCompleted,
      isArchived: isArchived ?? this.isArchived,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      type: type ?? this.type,
      isVerseBased: isVerseBased ?? this.isVerseBased,
      totalVerses: totalVerses ?? this.totalVerses,
      lastReadVerse: lastReadVerse ?? this.lastReadVerse,
      delayedPages: delayedPages ?? this.delayedPages,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      reminderDeadline: reminderDeadline ?? this.reminderDeadline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'durationDays': durationDays,
      'startDate': startDate.toIso8601String(),
      'startPage': startPage,
      'endPage': endPage,
      'lastReadPage': lastReadPage,
      'isCompleted': isCompleted,
      'isArchived': isArchived,
      'lastReadDate': lastReadDate?.toIso8601String(),
      'type': type,
      'isVerseBased': isVerseBased,
      'totalVerses': totalVerses,
      'lastReadVerse': lastReadVerse,
      'delayedPages': delayedPages,
      'remindersEnabled': remindersEnabled,
      'reminderTimes': reminderTimes,
      'reminderDeadline': reminderDeadline,
    };
  }

  factory KhatmaModel.fromJson(Map<String, dynamic> json) {
    return KhatmaModel(
      id: json['id'],
      name: json['name'],
      durationDays: json['durationDays'],
      startDate: DateTime.parse(json['startDate']),
      startPage: json['startPage'] ?? 1,
      endPage: json['endPage'] ?? 604,
      lastReadPage: json['lastReadPage'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      isArchived: json['isArchived'] ?? false,
      lastReadDate: json['lastReadDate'] != null
          ? DateTime.parse(json['lastReadDate'])
          : null,
      type: json['type'] ?? 'fixed',
      isVerseBased: json['isVerseBased'] ?? false,
      totalVerses: json['totalVerses'] ?? 6236,
      lastReadVerse: json['lastReadVerse'] ?? 0,
      delayedPages: json['delayedPages'] ?? 0,
      remindersEnabled: json['remindersEnabled'] ?? false,
      reminderTimes:
          (json['reminderTimes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      reminderDeadline: json['reminderDeadline'],
    );
  }
}
