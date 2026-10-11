/// Matches the existing `reminders` table exactly.
enum ReminderStatus { upcoming, completed, overdue }

extension ReminderStatusX on ReminderStatus {
  String get label {
    switch (this) {
      case ReminderStatus.upcoming:
        return 'upcoming';
      case ReminderStatus.completed:
        return 'completed';
      case ReminderStatus.overdue:
        return 'overdue';
    }
  }

  /// The `reminders.notification_status` column is a Postgres BOOLEAN:
  /// `true` = completed, `false` = not done yet. ("Overdue" is never stored;
  /// it is worked out from the date, see [Reminder.effectiveStatus].)
  /// Older text values ('completed' / 'overdue' / 'upcoming') are still read.
  static ReminderStatus fromDb(dynamic value) {
    if (value is bool) {
      return value ? ReminderStatus.completed : ReminderStatus.upcoming;
    }
    return fromLabel(value is String ? value : null);
  }

  /// Value to write to the boolean column.
  bool get dbValue => this == ReminderStatus.completed;

  static ReminderStatus fromLabel(String? value) {
    switch (value) {
      case 'completed':
        return ReminderStatus.completed;
      case 'overdue':
        return ReminderStatus.overdue;
      default:
        return ReminderStatus.upcoming;
    }
  }
}

class Reminder {
  final String id;
  final String catId;
  final String reminderType;
  final DateTime reminderDate;
  final ReminderStatus notificationStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Reminder({
    required this.id,
    required this.catId,
    required this.reminderType,
    required this.reminderDate,
    required this.notificationStatus,
    this.createdAt,
    this.updatedAt,
  });

  /// Derives the *effective* status: a stored "upcoming" reminder whose date
  /// has passed is treated as overdue without needing a background job.
  ReminderStatus get effectiveStatus {
    if (notificationStatus == ReminderStatus.completed) {
      return ReminderStatus.completed;
    }
    return reminderDate.isBefore(DateTime.now())
        ? ReminderStatus.overdue
        : ReminderStatus.upcoming;
  }

  int get daysLeft => reminderDate.difference(DateTime.now()).inDays;

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as String,
      catId: map['cat_id'] as String,
      reminderType: map['reminder_type'] as String? ?? '',
      reminderDate:
          DateTime.tryParse(map['reminder_date'] as String? ?? '') ??
              DateTime.now(),
      notificationStatus: ReminderStatusX.fromDb(map['notification_status']),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'cat_id': catId,
      'reminder_type': reminderType,
      'reminder_date': reminderDate.toIso8601String().split('T').first,
      'notification_status': notificationStatus.dbValue,
    };
  }
}
