import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/settings/presentation/providers/notification_settings_provider.dart';
import 'package:mobile/features/auth/data/auth_controller.dart';
import 'package:mobile/l10n/app_localizations.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsProvider);
    final user = ref.watch(authControllerProvider).value;
    final isAdmin = user?.role == 'ADMIN';
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.notificationSettings ?? 'Notification Settings'),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (prefs) {
          return ListView(
            children: [
              _buildSwitch(
                l10n?.notesNotification ?? '📝 Notes',
                prefs.noteAdded,
                (val) => ref
                    .read(notificationSettingsProvider.notifier)
                    .updatePreference(prefs.copyWith(noteAdded: val)),
              ),
              _buildSwitch(
                l10n?.attendanceNotification ?? '📊 Attendance',
                prefs.attendanceRecorded,
                (val) => ref
                    .read(notificationSettingsProvider.notifier)
                    .updatePreference(prefs.copyWith(attendanceRecorded: val)),
              ),
              _buildSwitch(
                l10n?.birthdayNotification ?? '🎂 Birthday Reminders',
                prefs.birthdayReminder,
                (val) => ref
                    .read(notificationSettingsProvider.notifier)
                    .updatePreference(prefs.copyWith(birthdayReminder: val)),
              ),
              _buildSwitch(
                l10n?.inactiveNotification ?? '⚠️ Inactive Students',
                prefs.inactiveStudent,
                (val) => ref
                    .read(notificationSettingsProvider.notifier)
                    .updatePreference(prefs.copyWith(inactiveStudent: val)),
              ),
              if (isAdmin)
                _buildSwitch(
                  l10n?.newUserNotification ?? '👤 New Registrations',
                  prefs.newUserRegistered,
                  (val) => ref
                      .read(notificationSettingsProvider.notifier)
                      .updatePreference(prefs.copyWith(newUserRegistered: val)),
                ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n?.settings ?? 'Settings',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: Text(l10n?.inactiveAfterDays ?? 'Inactive after (days)'),
                trailing: DropdownButton<int>(
                  value: prefs.inactiveThresholdDays,
                  items: [7, 14, 21, 30].map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(l10n?.daysUnit(e) ?? '$e days'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(notificationSettingsProvider.notifier)
                          .updatePreference(
                            prefs.copyWith(inactiveThresholdDays: val),
                          );
                    }
                  },
                ),
              ),
              ListTile(
                title: Text(l10n?.birthdayAlertTime ?? 'Birthday alert time'),
                subtitle: Text(
                  prefs.birthdayNotifyMorning
                      ? (l10n?.morningTime ?? 'Morning (8:00 AM)')
                      : (l10n?.eveningTime ?? 'Evening before (8:00 PM)'),
                ),
                trailing: Switch(
                  value: prefs.birthdayNotifyMorning,
                  onChanged: (val) {
                    ref
                        .read(notificationSettingsProvider.notifier)
                        .updatePreference(
                          prefs.copyWith(birthdayNotifyMorning: val),
                        );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSwitch(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
