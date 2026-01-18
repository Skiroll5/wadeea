class NotificationPreference {
  final bool noteAdded;
  final bool noteUpdated;
  final bool attendanceRecorded;
  final bool birthdayReminder;
  final bool inactiveStudent;
  final bool newUserRegistered;
  final int inactiveThresholdDays;
  final bool birthdayNotifyMorning;

  NotificationPreference({
    required this.noteAdded,
    required this.noteUpdated,
    required this.attendanceRecorded,
    required this.birthdayReminder,
    required this.inactiveStudent,
    required this.newUserRegistered,
    required this.inactiveThresholdDays,
    required this.birthdayNotifyMorning,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      noteAdded: json['noteAdded'] ?? true,
      noteUpdated: json['noteUpdated'] ?? true,
      attendanceRecorded: json['attendanceRecorded'] ?? true,
      birthdayReminder: json['birthdayReminder'] ?? true,
      inactiveStudent: json['inactiveStudent'] ?? true,
      newUserRegistered: json['newUserRegistered'] ?? true,
      inactiveThresholdDays: json['inactiveThresholdDays'] ?? 14,
      birthdayNotifyMorning: json['birthdayNotifyMorning'] ?? true,
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
      'birthdayNotifyMorning': birthdayNotifyMorning,
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
    bool? birthdayNotifyMorning,
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
      birthdayNotifyMorning:
          birthdayNotifyMorning ?? this.birthdayNotifyMorning,
    );
  }
}
