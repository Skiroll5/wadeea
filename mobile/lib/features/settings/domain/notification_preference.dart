class NotificationPreference {
  final bool noteAdded;
  final bool noteUpdated;
  final bool attendanceRecorded;
  final bool birthdayReminder;
  final bool inactiveStudent;
  final bool newUserRegistered;
  final int inactiveThresholdDays;
  final String birthdayNotifyTime; // Time in "HH:mm" format (e.g., "08:00")
  final int birthdayReminderDays; // How many days before birthday to remind

  NotificationPreference({
    required this.noteAdded,
    required this.noteUpdated,
    required this.attendanceRecorded,
    required this.birthdayReminder,
    required this.inactiveStudent,
    required this.newUserRegistered,
    required this.inactiveThresholdDays,
    required this.birthdayNotifyTime,
    required this.birthdayReminderDays,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    // Handle migration from old birthdayNotifyMorning to new birthdayNotifyTime
    String notifyTime = json['birthdayNotifyTime'] ?? '08:00';
    if (json.containsKey('birthdayNotifyMorning') &&
        !json.containsKey('birthdayNotifyTime')) {
      // Migrate from old format
      notifyTime = json['birthdayNotifyMorning'] == true ? '08:00' : '20:00';
    }

    return NotificationPreference(
      noteAdded: json['noteAdded'] ?? true,
      noteUpdated: json['noteUpdated'] ?? true,
      attendanceRecorded: json['attendanceRecorded'] ?? true,
      birthdayReminder: json['birthdayReminder'] ?? true,
      inactiveStudent: json['inactiveStudent'] ?? true,
      newUserRegistered: json['newUserRegistered'] ?? true,
      inactiveThresholdDays: json['inactiveThresholdDays'] ?? 14,
      birthdayNotifyTime: notifyTime,
      birthdayReminderDays: json['birthdayReminderDays'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noteAdded': noteAdded,
      'noteUpdated': noteUpdated,
      'attendanceRecorded': attendanceRecorded,
      'birthdayReminder': birthdayReminder,
      'inactiveStudent': inactiveStudent,
      'newUserRegistered': newUserRegistered,
      'inactiveThresholdDays': inactiveThresholdDays,
      'birthdayNotifyTime': birthdayNotifyTime,
      'birthdayReminderDays': birthdayReminderDays,
    };
  }

  NotificationPreference copyWith({
    bool? noteAdded,
    bool? noteUpdated,
    bool? attendanceRecorded,
    bool? birthdayReminder,
    bool? inactiveStudent,
    bool? newUserRegistered,
    int? inactiveThresholdDays,
    String? birthdayNotifyTime,
    int? birthdayReminderDays,
  }) {
    return NotificationPreference(
      noteAdded: noteAdded ?? this.noteAdded,
      noteUpdated: noteUpdated ?? this.noteUpdated,
      attendanceRecorded: attendanceRecorded ?? this.attendanceRecorded,
      birthdayReminder: birthdayReminder ?? this.birthdayReminder,
      inactiveStudent: inactiveStudent ?? this.inactiveStudent,
      newUserRegistered: newUserRegistered ?? this.newUserRegistered,
      inactiveThresholdDays:
          inactiveThresholdDays ?? this.inactiveThresholdDays,
      birthdayNotifyTime: birthdayNotifyTime ?? this.birthdayNotifyTime,
      birthdayReminderDays: birthdayReminderDays ?? this.birthdayReminderDays,
    );
  }
}
